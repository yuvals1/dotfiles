def insert_entry(conn, task_uuid, description, start_time, end_time, tags):
    """Inserts a new time entry into the database."""
    insert_sql = """
    INSERT INTO time_entries (task_uuid, description, start_time, end_time, tags)
    VALUES (?, ?, ?, ?, ?);
    """
    cursor = conn.cursor()
    cursor.execute(insert_sql, (task_uuid, description, start_time, end_time, tags))
    conn.commit()
