from datetime import datetime

from sqlmodel import Session

from .models import TaskTimeInterval


def insert_entry(engine, task_uuid, description, start_time, end_time, tags):
    """Inserts a new time entry into the database."""
    with Session(engine) as session:
        start_datetime = datetime.strptime(start_time, "%Y%m%dT%H%M%SZ")
        duration_seconds = None
        if end_time:
            end_datetime = datetime.strptime(end_time, "%Y%m%dT%H%M%SZ")
            duration_seconds = int((end_datetime - start_datetime).total_seconds())

        time_entry = TaskTimeInterval(
            task_uuid=task_uuid,
            description=description,
            start_time=start_time,
            end_time=end_time,
            duration_seconds=duration_seconds,
            tags=tags,
        )
        session.add(time_entry)
        session.commit()
