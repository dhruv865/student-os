"""
agents/academic_agent.py
Handles academic tasks: summarise notes, generate flashcards, answer questions,
and create quizzes from uploaded PDF content.
"""

from .base_agent import BaseAgent
from database.memory import search_documents

SYSTEM_PROMPT = (
    "You are AcademicBot, an expert study assistant for university students. "
    "You explain concepts clearly, generate well-structured study materials, "
    "and provide accurate answers based on the provided context. "
    "Always be concise, educational, and encouraging."
)


class AcademicAgent(BaseAgent):
    def __init__(self):
        super().__init__(name="AcademicAgent", system_prompt=SYSTEM_PROMPT)

    async def run(self, task: str, data: str = "") -> str:
        """
        Dispatch to the appropriate academic subtask.

        Supported tasks:
            summary    - Summarise provided notes or document text.
            flashcards - Generate Q&A flashcards from the text.
            quiz       - Create a multiple-choice quiz.
            ask        - Answer a question using memory context.
        """
        task = task.lower().strip()
        if task == "summary":
            return await self.summarise(data)
        elif task == "flashcards":
            return await self.generate_flashcards(data)
        elif task == "quiz":
            return await self.generate_quiz(data)
        elif task == "ask":
            return await self.answer_question(data)
        else:
            return await self.run_llm(
                f"The student asks: {data}\nProvide a helpful academic response."
            )

    async def summarise(self, text: str) -> str:
        if not text.strip():
            return "No text provided to summarise."
        prompt = (
            "Please summarise the following study material in a clear, structured way. "
            "Use bullet points for key concepts and keep it under 300 words.\n\n"
            f"CONTENT:\n{text[:4000]}"
        )
        return await self.run_llm(prompt)

    async def generate_flashcards(self, text: str) -> str:
        if not text.strip():
            return "No text provided for flashcard generation."
        prompt = (
            "Generate 8 to 10 study flashcards from the content below. "
            "Format each as:\nQ: <question>\nA: <answer>\n\n"
            f"CONTENT:\n{text[:4000]}"
        )
        return await self.run_llm(prompt)

    async def generate_quiz(self, text: str) -> str:
        if not text.strip():
            return "No text provided to generate a quiz."
        prompt = (
            "Create a 5-question multiple-choice quiz based on the content below. "
            "For each question provide 4 options (A, B, C, D) and indicate the correct answer.\n\n"
            f"CONTENT:\n{text[:4000]}"
        )
        return await self.run_llm(prompt)

    async def answer_question(self, question: str) -> str:
        """
        Search the in-memory document store for relevant context,
        then answer the student's question using that context.
        """
        if not question.strip():
            return "Please provide a question."

        # Retrieve top relevant chunks from memory
        results = search_documents(question, top_k=4)
        if results:
            context = "\n\n".join([r["text"] for r in results])
            prompt = (
                "Using ONLY the context provided below, answer the student's question "
                "accurately. If the context does not contain enough information, say so.\n\n"
                f"CONTEXT:\n{context}\n\n"
                f"QUESTION: {question}"
            )
        else:
            # No documents in memory — answer from general knowledge
            prompt = (
                f"Answer this academic question as best you can:\n\n{question}"
            )

        return await self.run_llm(prompt)
