"""
api/app.py
StudentOS FastAPI application.
All responses use the Flutter-compatible envelope:
  {"success": true,  "data": ...}
  {"success": false, "error": "..."}
"""

import os
import time
import shutil
from pathlib import Path
from typing import Any

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv

from tools.pdf_tool import extract_text_from_bytes
from tools.text_chunker import chunk_text_by_chars
from database.memory import store_document, document_count
from orchestrator.router import route_task
from agents.academic_agent import AcademicAgent

load_dotenv()

# ---------------------------------------------------------------------------
# App setup
# ---------------------------------------------------------------------------
app = FastAPI(
    title="StudentOS API",
    description="Multi-agent academic assistant backend",
    version="1.0.0",
)

# CORS — allow all origins for Flutter dev; tighten in production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

_academic_agent = AcademicAgent()


# ---------------------------------------------------------------------------
# Response helpers
# ---------------------------------------------------------------------------

def ok(data: Any) -> dict:
    return {"success": True, "data": data}


def err(message: str) -> dict:
    return {"success": False, "error": message}


# ---------------------------------------------------------------------------
# Pydantic request models
# ---------------------------------------------------------------------------

class AskRequest(BaseModel):
    question: str


class AgentRequest(BaseModel):
    task: str
    data: str = ""


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@app.get("/", tags=["Health"])
async def root():
    """Health-check endpoint."""
    return ok({"status": "running", "project": "StudentOS"})


@app.get("/status", tags=["Health"])
async def status():
    """Detailed status — useful for debugging."""
    return ok({
        "status": "running",
        "project": "StudentOS",
        "documents_in_memory": document_count(),
        "openrouter_key_set": bool(os.getenv("OPENROUTER_API_KEY")),
        "groq_key_set": bool(os.getenv("GROQ_API_KEY")),
        "timestamp": int(time.time()),
    })


@app.post("/upload-pdf", tags=["Documents"])
async def upload_pdf(file: UploadFile = File(...)):
    """
    Upload a PDF → extract text → chunk → store in memory → return summary.

    Returns:
        filename, summary, chunk_count
    """
    if not file.filename or not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are accepted.")

    try:
        pdf_bytes = await file.read()

        # 1. Extract text
        raw_text = extract_text_from_bytes(pdf_bytes)

        # 2. Chunk text
        chunks = chunk_text_by_chars(raw_text, chunk_size=1500, overlap=150)

        # 3. Store in memory with filename metadata
        store_document(chunks, metadata={"filename": file.filename})

        # 4. Generate summary via academic agent
        # Use the first 3000 chars for a fast summary
        summary_text = raw_text[:3000]
        summary = await _academic_agent.summarise(summary_text)

        # 5. Save file to disk (optional, for re-processing)
        save_path = UPLOAD_DIR / file.filename
        save_path.write_bytes(pdf_bytes)

        return ok({
            "filename": file.filename,
            "summary": summary,
            "chunks": len(chunks),
            "total_chars": len(raw_text),
        })

    except ValueError as ve:
        return err(str(ve))
    except Exception as e:
        return err(f"Failed to process PDF: {str(e)}")


@app.post("/ask", tags=["Academic"])
async def ask_question(request: AskRequest):
    """
    Answer a student question using documents stored in memory.

    Body:  {"question": "What is photosynthesis?"}
    """
    if not request.question.strip():
        return err("Question cannot be empty.")

    try:
        answer = await _academic_agent.answer_question(request.question)
        return ok({"answer": answer})
    except Exception as e:
        return err(f"Failed to answer question: {str(e)}")


@app.post("/agent", tags=["Agents"])
async def agent_endpoint(request: AgentRequest):
    """
    Generic multi-agent endpoint. Routes task to the right agent.

    Supported tasks:
        Academic  : summary | flashcards | quiz | ask
        Deadline  : deadline | extract | prioritise | reminder
        Content   : email | report | application | content

    Body: {"task": "summary", "data": "your text here"}
    """
    if not request.task.strip():
        return err("Task cannot be empty.")

    try:
        result = await route_task(task=request.task, data=request.data)
        return ok(result)
    except Exception as e:
        return err(f"Agent error: {str(e)}")


@app.get("/tasks", tags=["Agents"])
async def list_tasks():
    """Return all available task identifiers grouped by agent."""
    return ok({
        "agents": {
            "AcademicAgent": ["summary", "flashcards", "quiz", "ask"],
            "DeadlineAgent": ["deadline", "extract", "prioritise", "reminder"],
            "ContentAgent":  ["email", "report", "application", "content"],
        }
    })
