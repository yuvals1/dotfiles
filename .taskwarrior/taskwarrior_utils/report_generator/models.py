# report_generator/models.py
from typing import Optional

from pydantic import BaseModel


class FilterParams(BaseModel):
    tags: Optional[list[str]] = None
    start_time: Optional[str] = None  # Assuming ISO format 'YYYYMMDDTHHMMSSZ'
    end_time: Optional[str] = None


class AggregatedEntry(BaseModel):
    task_uuid: str
    description: str
    tags: str
    total_duration: int  # in seconds
