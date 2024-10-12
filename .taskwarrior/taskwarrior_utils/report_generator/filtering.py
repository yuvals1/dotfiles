# report_generator/filtering.py
from typing import List

from sqlmodel import Session, select

from db_utils.models import TaskTimeInterval

from .models import FilterParams


def apply_filters(session: Session, params: FilterParams) -> List[TaskTimeInterval]:
    statement = select(TaskTimeInterval)

    if params.tags:
        for tag in params.tags:
            statement = statement.where(TaskTimeInterval.tags.contains(tag))
    if params.start_time:
        statement = statement.where(TaskTimeInterval.start_time >= params.start_time)
    if params.end_time:
        statement = statement.where(TaskTimeInterval.end_time <= params.end_time)

    results = session.exec(statement).all()
    return results
