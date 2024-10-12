# report_generator/utils.py
from datetime import datetime


def parse_time(time_str: str) -> datetime:
    return datetime.strptime(time_str, "%Y%m%dT%H%M%SZ")
