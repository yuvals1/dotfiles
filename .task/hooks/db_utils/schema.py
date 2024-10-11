def create_table(conn):
    """Creates the necessary table in the database."""
    create_table_sql = """
    CREATE TABLE IF NOT EXISTS time_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_uuid TEXT,
        description TEXT,
        start_time TEXT,
        end_time TEXT,
        tags TEXT
    );
    """
    cursor = conn.cursor()
    cursor.execute(create_table_sql)
    cursor.execute(
        "CREATE INDEX IF NOT EXISTS idx_task_uuid ON time_entries(task_uuid);"
    )
    cursor.execute(
        "CREATE INDEX IF NOT EXISTS idx_start_time ON time_entries(start_time);"
    )
    conn.commit()
