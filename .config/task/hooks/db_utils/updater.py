def update_entry_end_time(conn, task_uuid, end_time):
    """Updates the end time of an existing time entry."""
    update_sql = """
    UPDATE time_entries
    SET end_time = ?
    WHERE task_uuid = ? AND end_time IS NULL;
    """
    cursor = conn.cursor()
    cursor.execute(update_sql, (end_time, task_uuid))
    conn.commit()


def update_entry_tags(conn, uuid, tags_str):
    """Updates the tags of an existing time entry."""
    update_sql = """
    UPDATE time_entries
    SET tags = ?
    WHERE task_uuid = ? AND end_time IS NULL;
    """
    cursor = conn.cursor()
    cursor.execute(update_sql, (tags_str, uuid))
    conn.commit()


def update_entry_description(conn, uuid, description):
    """Updates the description of an existing time entry."""
    update_sql = """
    UPDATE time_entries
    SET description = ?
    WHERE task_uuid = ? AND end_time IS NULL;
    """
    cursor = conn.cursor()
    cursor.execute(update_sql, (description, uuid))
    conn.commit()
