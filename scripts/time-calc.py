import re
import sys
from datetime import datetime


def standardize_date_format(text):
    """
    Convert all date headings to use forward slashes (DD/MM/YYYY)
    """
    # Match headings with either periods or forward slashes
    pattern = r"##\s+(\d{1,2})[./](\d{1,2})[./](\d{4})"

    def replace_date(match):
        day = match.group(1)
        month = match.group(2)
        year = match.group(3)
        return f"## {day}/{month}/{year}"

    return re.sub(pattern, replace_date, text)


def parse_time(time_str):
    """
    Attempt to parse an HH:MM time string into a datetime.time object.
    Returns None if parsing fails.
    """
    try:
        return datetime.strptime(time_str, "%H:%M").time()
    except ValueError:
        return None


def calculate_minutes(start_str, end_str):
    """
    Given two HH:MM strings, return the difference in minutes (end - start)
    if end >= start on the same day. Otherwise, return 0.
    """
    t_start = parse_time(start_str)
    t_end = parse_time(end_str)
    if not t_start or not t_end:
        return 0  # Can't parse time, skip or treat as 0

    # Convert times to minutes since midnight
    start_minutes = t_start.hour * 60 + t_start.minute
    end_minutes = t_end.hour * 60 + t_end.minute

    # If the end time is before the start time, skip (or handle differently if needed)
    if end_minutes < start_minutes:
        return 0

    return end_minutes - start_minutes


def process_document(document_text):
    """
    Parse the entire document text, locate each date heading (## DD/MM/YYYY),
    parse the table rows that follow, and compute total time (in minutes).
    Returns a dictionary: { 'DD/MM/YYYY': total_minutes, ... }
    """
    # First standardize all date formats
    document_text = standardize_date_format(document_text)

    # Regex to match lines like '## DD/MM/YYYY'
    day_heading_pattern = r"^##\s+(\d{1,2}/\d{1,2}/\d{4})"
    # Regex to match table rows: | Activity | Start | End |
    row_pattern = r"^\|\s*(.*?)\s*\|\s*([\d:-]+)\s*\|\s*([\d:-]+)\s*\|"

    lines = document_text.splitlines()
    results = {}
    current_day = None

    for line in lines:
        # Check if this line is a heading for a new day
        day_match = re.match(day_heading_pattern, line.strip())
        if day_match:
            current_day = day_match.group(1)
            if current_day not in results:
                results[current_day] = 0
            continue

        # If we're in a current day, look for table rows
        if current_day:
            row_match = re.match(row_pattern, line.strip())
            if row_match:
                activity = row_match.group(1).strip()
                start_str = row_match.group(2).strip()
                end_str = row_match.group(3).strip()

                # Skip rows with '-' for end time or obviously invalid
                if end_str == "-" or end_str.startswith("-"):
                    continue

                # Calculate minutes
                minutes = calculate_minutes(start_str, end_str)
                results[current_day] += minutes

    return results


def create_or_update_markdown(results, filename="time_spent.md"):
    """
    Given a dictionary of date -> total_minutes,
    create/overwrite a markdown table with total time each day.
    """
    # Sort dates as actual datetimes (DD/MM/YYYY -> datetime)
    sorted_days = sorted(results.keys(), key=lambda d: datetime.strptime(d, "%d/%m/%Y"))

    lines = []
    lines.append("| Date       | Total Time (h:mm) |")
    lines.append("| ---------- | ----------------- |")

    for day in sorted_days:
        total_minutes = results[day]
        hours = total_minutes // 60
        mins = total_minutes % 60
        lines.append(f"| {day} | {hours}:{mins:02d} |")

    md_content = "\n".join(lines)

    with open(filename, "w", encoding="utf-8") as f:
        f.write(md_content)


def main():
    if len(sys.argv) < 2:
        doc_path = r"/Users/yuvalspiegel/iCloud~md~obsidian/Documents/Yuval/conscious-green-light.md"
    else:
        doc_path = sys.argv[1]

    # Read the document
    with open(doc_path, "r", encoding="utf-8") as f:
        document_text = f.read()

    # Process and compute totals
    results = process_document(document_text)

    # Create/update the output file
    create_or_update_markdown(
        results,
        r"/Users/yuvalspiegel/iCloud~md~obsidian/Documents/Yuval/green-light-total.md",
    )


if __name__ == "__main__":
    main()
