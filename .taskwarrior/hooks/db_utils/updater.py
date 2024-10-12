from sqlmodel import Session, select

from .models import TimeEntry


def update_entry_end_time(engine, task_uuid, end_time):
    """Updates the end time of an existing time entry."""
    with Session(engine) as session:
        statement = select(TimeEntry).where(
            TimeEntry.task_uuid == task_uuid, TimeEntry.end_time == None
        )
        result = session.exec(statement).first()
        if result:
            result.end_time = end_time
            session.add(result)
            session.commit()


def update_entry_tags(engine, task_uuid, tags_str):
    """Updates the tags of an existing time entry."""
    with Session(engine) as session:
        statement = select(TimeEntry).where(
            TimeEntry.task_uuid == task_uuid, TimeEntry.end_time == None
        )
        result = session.exec(statement).first()
        if result:
            result.tags = tags_str
            session.add(result)
            session.commit()


def update_entry_description(engine, task_uuid, description):
    """Updates the description of an existing time entry."""
    with Session(engine) as session:
        statement = select(TimeEntry).where(
            TimeEntry.task_uuid == task_uuid, TimeEntry.end_time == None
        )
        result = session.exec(statement).first()
        if result:
            result.description = description
            session.add(result)
            session.commit()
