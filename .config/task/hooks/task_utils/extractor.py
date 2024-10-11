def extract_tags_from(json_obj):
    """Extracts tags and project from a task JSON object."""
    tags = []
    if "project" in json_obj:
        tags.append(json_obj["project"])
    if "tags" in json_obj:
        if isinstance(json_obj["tags"], str):
            tags.extend(json_obj["tags"].split(","))
        else:
            tags.extend(json_obj["tags"])
    return tags


def extract_description(json_obj):
    """Extracts the description from a task JSON object."""
    return json_obj.get("description", "")


def extract_uuid(json_obj):
    """Extracts the UUID from a task JSON object."""
    return json_obj.get("uuid", "")
