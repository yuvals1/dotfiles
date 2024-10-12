from datetime import timedelta
from typing import Optional

from sqlmodel import Field, SQLModel


class TaskTimeInterval(SQLModel, table=True):
    __tablename__ = "timewarrior_intervals"
    id: Optional[int] = Field(default=None, primary_key=True)
    task_uuid: str
    description: str
    start_time: str
    end_time: Optional[str] = None
    duration: Optional[timedelta] = None
    tags: str
