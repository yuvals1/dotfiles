import os

from sqlmodel import create_engine


def get_taskwarrior_db_path():
    """Retrieves the Taskwarrior database path."""
    home_dir = os.path.expanduser("~")
    taskwarrior_dir = os.path.join(home_dir, ".taskwarrior")
    db_path = os.path.join(taskwarrior_dir, "taskchampion.sqlite3")
    return db_path


def connect_db():
    """Connects to the Taskwarrior SQLite database and returns an engine."""
    db_path = get_taskwarrior_db_path()
    engine = create_engine(f"sqlite:///{db_path}", echo=False)
    return engine
