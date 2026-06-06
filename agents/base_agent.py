"""
agents/base_agent.py
Abstract base class for all StudentOS agents.
"""

from abc import ABC, abstractmethod
from tools.llm_tool import ask_llm


class BaseAgent(ABC):
    """
    Every agent inherits from BaseAgent.
    Provides a shared `run_llm` helper that routes through the LLM tool
    (OpenRouter → Groq fallback) and enforces a standard `run` interface.
    """

    def __init__(self, name: str, system_prompt: str = ""):
        self.name = name
        self.system_prompt = system_prompt

    async def run_llm(self, prompt: str) -> str:
        """Send a prompt through the LLM stack with this agent's system prompt."""
        return await ask_llm(prompt, system=self.system_prompt)

    @abstractmethod
    async def run(self, task: str, data: str = "") -> str:
        """
        Execute the agent's primary task.

        Args:
            task: A short task identifier (e.g. "summary", "flashcards").
            data: Optional text payload (e.g. document content, user notes).

        Returns:
            Agent response as a string.
        """
        ...
