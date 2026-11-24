"""Simple tests for clean_silwood_trees.py"""

import csv
import tempfile
from pathlib import Path

from clean_silwood_trees import (
    validate_record,
    process_records,
    summarise_oaks,
    write_csv,
    ISSUE_FIELDS,
    OAK_COUNT_FIELDS,
    INPUT_FIELDS,
)


def test_validate_record():
    """Check one row at a time."""
    good = {
        "record_id": " ST001 ",
        "location": "manor house",
        "genus": "QUERCUS",
        "species": "Robur",
        "distance_m": "12.5",
        "angle_degrees": "30",
    }

    # Messy but valid: spaces and capitals are cleaned
    record, reasons = validate_record(good, 2, set())
    assert reasons == []
    assert record is not None
    assert record["location"] == "Manor House"
    assert record["genus"] == "Quercus"

    # Missing value
    row = dict(good, location="")
    assert validate_record(row, 2, set())[1] == ["missing location"]

    # Unrecognised value (misspelling is not corrected)
    row = dict(good, genus="Quercas")
    assert validate_record(row, 2, set())[1] == ["invalid genus"]

    # Valid names, wrong pair
    row = dict(good, species="pendula")
    assert validate_record(row, 2, set())[1] == [
        "invalid genus/species combination"
    ]

    # Invalid measurements
    row = dict(good, distance_m="abc")
    assert validate_record(row, 2, set())[1] == ["invalid distance_m"]
    row = dict(good, distance_m="nan")
    assert validate_record(row, 2, set())[1] == ["invalid distance_m"]

    # Out of range (100 is allowed, 90 degrees is not)
    row = dict(good, distance_m="100")
    assert validate_record(row, 2, set())[1] == []
    row = dict(good, angle_degrees="90")
    assert validate_record(row, 2, set())[1] == ["angle_degrees out of range"]

    # Duplicate ID
    assert validate_record(good, 3, {"ST001"})[1] == ["duplicate record_id"]

    # Several problems at once, in metadata order
    row = dict(good, record_id="st003", location="", distance_m="nan")
    assert validate_record(row, 2, set())[1] == [
        "invalid record_id",
        "missing location",
        "invalid distance_m",
    ]


def test_process_records():
    """Check the loop: duplicates, line numbers and sorting."""
    good = {
        "location": "Manor House",
        "genus": "Acer",
        "species": "pseudoplatanus",
        "distance_m": "10",
        "angle_degrees": "45",
    }
    rows = [
        dict(good, record_id="ST002"),  # line 2: accepted
        dict(good, record_id="ST001", location="nowhere"),  # line 3: rejected
        dict(good, record_id="ST001"),  # line 4: accepted
        dict(good, record_id="ST002"),  # line 5: duplicate
    ]
    accepted, issues = process_records(rows)

    assert [r["record_id"] for r in accepted] == ["ST001", "ST002"]
    assert issues == [
        {
            "source_row": "3",
            "record_id": "ST001",
            "reasons": "invalid location",
        },
        {
            "source_row": "5",
            "record_id": "ST002",
            "reasons": "duplicate record_id",
        },
    ]


def test_summarise_oaks():
    """Check oak counting: exact name, near match, and no oaks."""
    rows = [
        {
            "record_id": "ST001",
            "location": "Manor House",
            "genus": "Quercus",
            "species": "robur",
            "distance_m": "10",
            "angle_degrees": "45",
        },
        {
            "record_id": "ST002",
            "location": "Manor House",
            "genus": " QUERCUS ",
            "species": "ROBUR",
            "distance_m": "10",
            "angle_degrees": "45",
        },
    ]
    accepted, _ = process_records(rows)
    assert summarise_oaks(accepted) == [{"species": "robur", "count": "2"}]

    no_oaks = [{"genus": "Betula", "species": "pendula"}]
    assert summarise_oaks(no_oaks) == []


def test_written_tables():
    """Check the end-to-end partition and all three CSV headers."""
    rows = [
        {
            "record_id": "ST001",
            "location": "manor house",
            "genus": "QUERCUS",
            "species": "robur",
            "distance_m": "10",
            "angle_degrees": "45",
        },
        {
            "record_id": "ST002",
            "location": "manor house",
            "genus": "Quercus",
            "species": "pendula",
            "distance_m": "10",
            "angle_degrees": "45",
        },
    ]
    cleaned, issues = process_records(rows)
    oak_counts = summarise_oaks(cleaned)

    assert [row["record_id"] for row in cleaned] == ["ST001"]
    assert issues[0]["reasons"] == "invalid genus/species combination"
    assert oak_counts == [{"species": "robur", "count": "1"}]

    with tempfile.TemporaryDirectory() as directory:
        output = Path(directory)
        for filename, fields, data in (
            ("clean.csv", INPUT_FIELDS, cleaned),
            ("issues.csv", ISSUE_FIELDS, issues),
            ("oaks.csv", OAK_COUNT_FIELDS, oak_counts),
        ):
            path = output / filename
            write_csv(path, fields, data)
            with path.open(newline="", encoding="utf-8") as source:
                reader = csv.DictReader(source)
                assert reader.fieldnames == fields
                written = list(reader)
                if filename == "clean.csv":
                    assert [row["record_id"] for row in written] == ["ST001"]
                elif filename == "issues.csv":
                    assert written[0]["source_row"] == "3"
                    assert written[0]["reasons"] == "invalid genus/species combination"
                else:
                    assert written == [{"species": "robur", "count": "1"}]


if __name__ == "__main__":
    test_validate_record()
    test_process_records()
    test_summarise_oaks()
    test_written_tables()
    print("All tests passed")
