import subprocess


def update_timew_tags(old_tags, new_tags):
    """Updates the tags of the current time tracking session."""
    subprocess.call(["timew", "untag", "@1"] + old_tags + [":yes"])
    subprocess.call(["timew", "tag", "@1"] + new_tags + [":yes"])
