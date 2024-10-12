from typing import Optional

from sqlmodel import Field, SQLModel


class TimeEntry(SQLModel, table=True):
    __tablename__ = "timewarrior_intervals"  # Changed table name to avoid conflicts
    id: Optional[int] = Field(default=None, primary_key=True)
    task_uuid: str
    description: str
    start_time: str
    end_time: Optional[str] = None
    tags: str
