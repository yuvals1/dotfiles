import subprocess


def annotate_description(description):
    """Annotates the current time tracking session with the description."""
    subprocess.call(["timew", "annotate", "@1", description])


def annotate_uuid(uuid):
    """Annotates the current time tracking session with the task UUID."""
    if uuid:
        subprocess.call(["timew", "annotate", "@1", "UUID: " + uuid])
