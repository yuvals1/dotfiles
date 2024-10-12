from typing import Optional

from sqlmodel import Field, SQLModel


class TimeEntry(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    task_uuid: str
    description: str
    start_time: str
    end_time: Optional[str] = None
    tags: str
