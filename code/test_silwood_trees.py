"""Simple tests for clean_silwood_trees.py"""

from clean_silwood_trees import (
    validate_record,
    process_records,
    summarise_oaks,
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


if __name__ == "__main__":
    test_validate_record()
    test_process_records()
    test_summarise_oaks()
    print("All tests passed")
