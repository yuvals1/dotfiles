def has_task_started(old, new):
    """Determines if the task has just started."""
    return "start" in new and "start" not in old


def has_task_stopped(old, new):
    """Determines if the task has just stopped."""
    return ("start" not in new or "end" in new) and "start" in old


def have_tags_changed(old_tags, new_tags):
    """Checks if the tags have changed."""
    return old_tags != new_tags


def has_description_changed(old_description, new_description):
    """Checks if the description has changed."""
    return old_description != new_description
