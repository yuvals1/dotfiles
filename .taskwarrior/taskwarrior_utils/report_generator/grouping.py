# report_generator/grouping.py
from collections import defaultdict
from typing import List

from db_utils.models import TaskTimeInterval

from .models import AggregatedEntry


def group_and_aggregate(entries: List[TaskTimeInterval]) -> List[AggregatedEntry]:
    grouped_data = defaultdict(list)

    # Group entries by task_uuid
    for entry in entries:
        grouped_data[entry.task_uuid].append(entry)

    aggregated_entries = []
    for task_uuid, task_entries in grouped_data.items():
        # Get the last entry by start_time
        last_entry = max(task_entries, key=lambda x: x.start_time)

        # Calculate total duration
        total_duration = sum(entry.duration_seconds or 0 for entry in task_entries)

        aggregated_entry = AggregatedEntry(
            task_uuid=task_uuid,
            description=last_entry.description,
            tags=last_entry.tags,
            total_duration=total_duration,
        )
        aggregated_entries.append(aggregated_entry)

    return aggregated_entries
