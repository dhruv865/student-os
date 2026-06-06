"""
agents/content_agent.py
Handles formal content generation: emails, reports, applications,
and other professional documents for students.
"""

from .base_agent import BaseAgent

SYSTEM_PROMPT = (
    "You are ContentBot, an expert academic writing assistant. "
    "You draft professional emails, formal reports, university applications, "
    "and other formal content for students. "
    "Always use appropriate tone, structure, and language for the target audience. "
    "Output should be polished and ready to use with minimal editing."
)


class ContentAgent(BaseAgent):
    def __init__(self):
        super().__init__(name="ContentAgent", system_prompt=SYSTEM_PROMPT)

    async def run(self, task: str, data: str = "") -> str:
        """
        Supported tasks:
            email       - Draft a formal or informal email.
            report      - Draft a structured academic/professional report.
            application - Write a university or job application letter.
            content     - Generic formal content generation.
        """
        task = task.lower().strip()
        if task == "email":
            return await self.draft_email(data)
        elif task == "report":
            return await self.draft_report(data)
        elif task == "application":
            return await self.draft_application(data)
        else:
            return await self.run_llm(
                f"Generate professional formal content for a student based on:\n\n{data}"
            )

    async def draft_email(self, instructions: str) -> str:
        if not instructions.strip():
            return "Please describe the email you need (recipient, purpose, tone)."
        prompt = (
            "Draft a professional email based on the following instructions. "
            "Include a subject line, greeting, body paragraphs, and a closing.\n\n"
            f"INSTRUCTIONS:\n{instructions[:3000]}"
        )
        return await self.run_llm(prompt)

    async def draft_report(self, instructions: str) -> str:
        if not instructions.strip():
            return "Please describe the report topic and key points to cover."
        prompt = (
            "Draft a formal academic or professional report based on the instructions below. "
            "Include: Title, Executive Summary, Introduction, Main Body (with sections), "
            "Conclusion, and Recommendations if applicable.\n\n"
            f"INSTRUCTIONS:\n{instructions[:3000]}"
        )
        return await self.run_llm(prompt)

    async def draft_application(self, instructions: str) -> str:
        if not instructions.strip():
            return "Please describe the application (position/program, your background, goals)."
        prompt = (
            "Write a compelling formal application letter based on the information below. "
            "It should include a strong opening, relevant background and achievements, "
            "motivation statement, and a confident closing.\n\n"
            f"INSTRUCTIONS:\n{instructions[:3000]}"
        )
        return await self.run_llm(prompt)
