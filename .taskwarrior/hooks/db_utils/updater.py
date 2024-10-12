from datetime import datetime

from sqlmodel import Session, select

from .models import TaskTimeInterval


def update_entry_end_time(engine, task_uuid, end_time):
    """Updates the end time and duration of an existing time entry."""
    with Session(engine) as session:
        statement = select(TaskTimeInterval).where(
            TaskTimeInterval.task_uuid == task_uuid, TaskTimeInterval.end_time == None
        )
        result = session.exec(statement).first()
        if result:
            result.end_time = end_time
            end_datetime = datetime.strptime(end_time, "%Y%m%dT%H%M%SZ")
            start_datetime = datetime.strptime(result.start_time, "%Y%m%dT%H%M%SZ")
            result.duration_seconds = int(
                (end_datetime - start_datetime).total_seconds()
            )
            session.add(result)
            session.commit()


def update_entry_tags(engine, task_uuid, tags_str):
    """Updates the tags of an existing time entry."""
    with Session(engine) as session:
        statement = select(TaskTimeInterval).where(
            TaskTimeInterval.task_uuid == task_uuid, TaskTimeInterval.end_time == None
        )
        result = session.exec(statement).first()
        if result:
            result.tags = tags_str
            session.add(result)
            session.commit()


def update_entry_description(engine, task_uuid, description):
    """Updates the description of an existing time entry."""
    with Session(engine) as session:
        statement = select(TaskTimeInterval).where(
            TaskTimeInterval.task_uuid == task_uuid, TaskTimeInterval.end_time == None
        )
        result = session.exec(statement).first()
        if result:
            result.description = description
            session.add(result)
            session.commit()
