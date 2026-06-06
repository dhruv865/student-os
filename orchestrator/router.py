"""
orchestrator/router.py
Central dispatcher that routes tasks to the appropriate agent.
"""

from agents.academic_agent import AcademicAgent
from agents.deadline_agent import DeadlineAgent
from agents.content_agent import ContentAgent

# Singleton agent instances (created once, reused per request)
_academic = AcademicAgent()
_deadline = DeadlineAgent()
_content = ContentAgent()

# Task keyword → agent mapping
ACADEMIC_TASKS = {"summary", "flashcards", "quiz", "ask", "academic"}
DEADLINE_TASKS = {"deadline", "extract", "prioritise", "prioritize", "reminder", "reminders"}
CONTENT_TASKS  = {"email", "report", "application", "content", "draft"}


async def route_task(task: str, data: str = "") -> dict:
    """
    Route a task string to the correct agent and return a standardised result.

    Args:
        task: Short task identifier sent by the client.
        data: Payload/context text for the agent.

    Returns:
        dict with keys: agent (str), task (str), result (str)
    """
    normalised = task.lower().strip()

    if normalised in ACADEMIC_TASKS:
        agent = _academic
        agent_name = "AcademicAgent"
    elif normalised in DEADLINE_TASKS:
        agent = _deadline
        agent_name = "DeadlineAgent"
    elif normalised in CONTENT_TASKS:
        agent = _content
        agent_name = "ContentAgent"
    else:
        # Default: try academic agent for unknown tasks
        agent = _academic
        agent_name = "AcademicAgent (default)"

    result = await agent.run(task=normalised, data=data)
    return {
        "agent": agent_name,
        "task": task,
        "result": result,
    }
