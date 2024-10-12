# report_generator/main.py
from typing import List, Optional

import typer
from sqlmodel import Session

from db_utils.connection import connect_db

from .filtering import apply_filters
from .grouping import group_and_aggregate
from .models import FilterParams

app = typer.Typer()


@app.command()
def generate_report(
    tags: Optional[List[str]] = typer.Option(None, help="Filter by tags"),
    start_time: Optional[str] = typer.Option(
        None, help="Filter entries starting from this time (YYYYMMDDTHHMMSSZ)"
    ),
    end_time: Optional[str] = typer.Option(
        None, help="Filter entries up to this time (YYYYMMDDTHHMMSSZ)"
    ),
):
    """
    Generate a report of Taskwarrior time entries based on specified filters.
    """
    filter_params = FilterParams(
        tags=tags,
        start_time=start_time,
        end_time=end_time,
    )

    engine = connect_db()
    with Session(engine) as session:
        entries = apply_filters(session, filter_params)
        aggregated_entries = group_and_aggregate(entries)

        # Output the results
        typer.echo(
            f"{'Task UUID':36} | {'Description':20} | {'Tags':15} | {'Total Duration (s)':18}"
        )
        typer.echo("-" * 95)
        for entry in aggregated_entries:
            typer.echo(
                f"{entry.task_uuid:36} | {entry.description:20} | {entry.tags:15} | {entry.total_duration:18}"
            )


if __name__ == "__main__":
    app()
