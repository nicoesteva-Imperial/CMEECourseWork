# INPUT: observations with site, date and count
# Check that the expected fields are present; stop and report an error if not
# Identify exact duplicate records
# Keep one copy of each record for this example
# For each site:
#     report how many counts are missing
#     if at least one count is present:
#         add the counts that are present and report the known-count total
#     otherwise:
#         report that no known total is available
# OUTPUT: known-count total (or unavailable) and missing-count number per site

import csv


# This section is to load CSV rows as a list of dicts
def load_observations(path):
    with open(path, newline="", encoding="utf-8") as stream:
        return list(csv.DictReader(stream))


# This section to convert count text to int; None if blank, ValueError if invalid
def parse_count(count_text):
    if count_text == "":
        return None
    count = int(count_text)
    if count < 0:
        raise ValueError(f"Count cannot be negative: {count_text}")
    return count


# Load and print rows for inspection
rows = load_observations(
    "data/bootcamp_observations/bootcamp_observations.csv"
)
for row in rows:
    print(row)

# This section is to test that parse_count works as expected for valid inputs:
assert parse_count("2") == 2
assert parse_count("0") == 0
assert parse_count("") is None

# This section is to test that parse_count raises a ValueError for invalid inputs, so negative inputs as count < 0:

for bad in ["-1", "many"]:
    try:
        parse_count(bad)
        print(f"{bad!r}: did not raise ValueError")
    except ValueError as error:
        print(f"{bad!r}: raised ValueError as expected: {error}")

# INPUT: list of row dictionaries with site, date and count (all as text)
# FOr each row we need to check that it has the file dsite, date, and count.
#  Otherwsie it should raise ValueEroor.
#  Every value must be text; ValueError if not.
#  Site and date can't be empty; ValueError if they are.
#  Check that the count is valid using parse_count.
#  Identifyt exact duplicate (site, date, count)
#  Keep one copy of each of the records.
#   For the requested site:
#       report how many counts are missing
#       if at least one count is present, add the counts that are present and report the known-count total.
#   Otherwise, report that no known total is available.
# Output: known-count total (or unavailable) and missing-count number per site
#        Written as (known_total, missing_count)


def summarise_site(rows, site):
    seen = set()
    known_total = 0
    missing_count = 0
    found_known = False
    for row in rows:
        # Check that the expected fields are present; stop and report an error if not
        if set(row) != {"site", "date", "count"}:
            raise ValueError(f"Missing or extra field in row: {row}")
        for value in row.values():  # check for string instead of integer
            if not isinstance(value, str):
                raise ValueError(f"Non-text value in row: {row}")
        if (
            row["site"] == "" or row["date"] == ""
        ):  # site or date cannot be empty
            raise ValueError(f"Empty site or date in row: {row}")
        count = parse_count(row["count"])
        # Identify exact duplicate records
        key = (row["site"], row["date"], row["count"])
        if key in seen:
            continue  # Skip duplicates
        seen.add(key)
        # Keep one copy of each record for this example
        if row["site"] == site:
            if count is None:
                missing_count += 1
            else:
                known_total += count
                found_known = True
    if not found_known:
        return (None, missing_count)
    return (known_total, missing_count)
