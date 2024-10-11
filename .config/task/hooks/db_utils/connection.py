import os
import sqlite3


def get_data_directory():
    """Retrieves the Timewarrior data directory."""
    home_dir = os.path.expanduser("~")
    timew_data_dir = os.path.join(home_dir, ".timewarrior", "data")
    os.makedirs(timew_data_dir, exist_ok=True)
    return timew_data_dir


def connect_db(db_path):
    """Connects to the SQLite database."""
    conn = sqlite3.connect(db_path)
    return conn
