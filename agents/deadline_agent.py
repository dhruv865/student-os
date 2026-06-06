"""
agents/deadline_agent.py
Handles deadline and task management: extract deadlines, prioritise tasks,
and generate reminder messages.
"""

from .base_agent import BaseAgent

SYSTEM_PROMPT = (
    "You are DeadlineBot, a smart academic planner. "
    "You help students extract deadlines from messy notes, prioritise tasks "
    "by urgency and importance, and generate clear reminder messages. "
    "Always respond with structured, actionable output."
)


class DeadlineAgent(BaseAgent):
    def __init__(self):
        super().__init__(name="DeadlineAgent", system_prompt=SYSTEM_PROMPT)

    async def run(self, task: str, data: str = "") -> str:
        """
        Supported tasks:
            extract    - Extract deadlines from raw text.
            prioritise - Rank tasks by urgency.
            reminder   - Generate reminder messages for given deadlines.
            deadline   - Generic deadline/task helper.
        """
        task = task.lower().strip()
        if task in ("extract", "deadline"):
            return await self.extract_deadlines(data)
        elif task == "prioritise":
            return await self.prioritise_tasks(data)
        elif task == "reminder":
            return await self.generate_reminders(data)
        else:
            return await self.run_llm(
                f"Help the student manage this deadline or task information:\n\n{data}"
            )

    async def extract_deadlines(self, text: str) -> str:
        if not text.strip():
            return "No text provided. Please paste your notes or assignment description."
        prompt = (
            "Extract all deadlines, due dates, and important dates from the text below. "
            "Format the output as a numbered list with:\n"
            "- Task name\n- Due date/time\n- Subject/course (if mentioned)\n\n"
            f"TEXT:\n{text[:4000]}"
        )
        return await self.run_llm(prompt)

    async def prioritise_tasks(self, text: str) -> str:
        if not text.strip():
            return "Please provide a list of tasks to prioritise."
        prompt = (
            "Prioritise the following student tasks using the Eisenhower Matrix "
            "(Urgent+Important, Important+Not Urgent, Urgent+Not Important, "
            "Not Urgent+Not Important). "
            "Provide a clear numbered priority list with a brief reason for each ranking.\n\n"
            f"TASKS:\n{text[:4000]}"
        )
        return await self.run_llm(prompt)

    async def generate_reminders(self, text: str) -> str:
        if not text.strip():
            return "Please provide deadline information to generate reminders."
        prompt = (
            "Generate friendly but firm reminder messages for the following deadlines. "
            "For each deadline create:\n"
            "1. A 1-week-before reminder\n"
            "2. A 1-day-before reminder\n"
            "3. A day-of reminder\n\n"
            f"DEADLINES:\n{text[:4000]}"
        )
        return await self.run_llm(prompt)
