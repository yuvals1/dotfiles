from sqlmodel import Session

from .models import TaskTimeInterval


def insert_entry(engine, task_uuid, description, start_time, end_time, tags):
    """Inserts a new time entry into the database."""
    with Session(engine) as session:
        time_entry = TaskTimeInterval(
            task_uuid=task_uuid,
            description=description,
            start_time=start_time,
            end_time=end_time,
            tags=tags,
        )
        session.add(time_entry)
        session.commit()
