"""
tools/llm_tool.py
Core LLM interface with OpenRouter as primary provider and Groq as fallback.
"""

import os
import httpx
from dotenv import load_dotenv

load_dotenv()

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "")
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")

OPENROUTER_BASE_URL = "https://openrouter.ai/api/v1"
OPENROUTER_DEFAULT_MODEL = "minimax/minimax-m3"

GROQ_BASE_URL = "https://api.groq.com/openai/v1"
GROQ_DEFAULT_MODEL = "llama3-8b-8192"


async def ask_openrouter(prompt: str, system: str = "") -> str:
    """
    Send a prompt to OpenRouter using the minimax/minimax-m3 model.
    Returns the text response or raises an exception on failure.
    """
    if not OPENROUTER_API_KEY:
        raise ValueError("OPENROUTER_API_KEY is not set")

    messages = []
    if system:
        messages.append({"role": "system", "content": system})
    messages.append({"role": "user", "content": prompt})

    async with httpx.AsyncClient(timeout=60.0) as client:
        response = await client.post(
            f"{OPENROUTER_BASE_URL}/chat/completions",
            headers={
                "Authorization": f"Bearer {OPENROUTER_API_KEY}",
                "Content-Type": "application/json",
                "HTTP-Referer": "https://studentos.app",
                "X-Title": "StudentOS",
            },
            json={
                "model": OPENROUTER_DEFAULT_MODEL,
                "messages": messages,
                "temperature": 0.7,
                "max_tokens": 2048,
            },
        )
        response.raise_for_status()
        data = response.json()
        return data["choices"][0]["message"]["content"].strip()


async def ask_groq(prompt: str, system: str = "") -> str:
    """
    Send a prompt to Groq (llama3-8b-8192).
    Used as fallback when OpenRouter fails.
    """
    if not GROQ_API_KEY:
        raise ValueError("GROQ_API_KEY is not set")

    messages = []
    if system:
        messages.append({"role": "system", "content": system})
    messages.append({"role": "user", "content": prompt})

    async with httpx.AsyncClient(timeout=60.0) as client:
        response = await client.post(
            f"{GROQ_BASE_URL}/chat/completions",
            headers={
                "Authorization": f"Bearer {GROQ_API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": GROQ_DEFAULT_MODEL,
                "messages": messages,
                "temperature": 0.7,
                "max_tokens": 2048,
            },
        )
        response.raise_for_status()
        data = response.json()
        return data["choices"][0]["message"]["content"].strip()


async def ask_llm(prompt: str, system: str = "") -> str:
    """
    Primary LLM entry point.
    Tries OpenRouter first; on any error falls back to Groq.
    """
    try:
        return await ask_openrouter(prompt, system)
    except Exception as e:
        print(f"[LLM] OpenRouter failed ({e}), falling back to Groq...")
        try:
            return await ask_groq(prompt, system)
        except Exception as groq_err:
            raise RuntimeError(
                f"Both LLM providers failed. OpenRouter: {e} | Groq: {groq_err}"
            )
