"""Load bootcamp observations and summarise counts by site."""

import csv


def load_observations(path):
    with open(path, newline="", encoding="utf-8") as stream:
        return list(csv.DictReader(stream))


def parse_count(count_text):
    if not isinstance(count_text, str):
        raise ValueError(f"Count must be text: {count_text!r}")
    if count_text == "":
        return None
    count = int(count_text)
    if count < 0:
        raise ValueError(f"Count cannot be negative: {count_text}")
    return count


def validate_row(row):
    """Raise ValueError if row is not a valid observation record."""
    if not isinstance(row, dict):
        raise ValueError("Each observation must be a dictionary")
    if set(row) != {"site", "date", "count"}:
        raise ValueError("Observation must have exactly site, date, and count")
    if not all(isinstance(value, str) for value in row.values()):
        raise ValueError("Every observation value must be text")
    if row["site"] == "":
        raise ValueError("Observation site must not be empty")
    if row["date"] == "":
        raise ValueError("Observation date must not be empty")

    parse_count(row["count"])


def summarise_site(rows, site):
    """Return (known_total, missing_count) for one site."""
    if not isinstance(rows, list):
        raise ValueError("rows must be a list")
    if not isinstance(site, str) or site == "":
        raise ValueError("site must be non-empty text")

    seen = set()
    total = 0
    missing = 0
    has_known_count = False
    for row in rows:
        validate_row(row)
        record = (row["site"], row["date"], row["count"])
        if record in seen:
            continue
        seen.add(record)

        if row["site"] == site:
            count = parse_count(row["count"])
            if count is None:
                missing += 1
            else:
                total += count
                has_known_count = True
    if not has_known_count:
        total = None
    return total, missing


if __name__ == "__main__":
    rows = load_observations("data/bootcamp_observations.csv")
    for site in sorted({row["site"] for row in rows}):
        total, missing = summarise_site(rows, site)
        print(f"{site}: known total={total}, missing counts={missing}")
