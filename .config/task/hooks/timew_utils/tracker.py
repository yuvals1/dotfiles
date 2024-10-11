import subprocess


def start_time_tracking(tags):
    """Starts time tracking with the given tags."""
    subprocess.call(["timew", "start"] + tags + [":yes"])


def stop_time_tracking():
    """Stops the current time tracking session."""
    subprocess.call(["timew", "stop", ":yes"])
