"""Scratch checks for validate_record. Not part of the submission."""

import sys

from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "code"))
from clean_silwood_trees import validate_record  # type: ignore

# Each test: a fake row, then the result I EXPECT written as a comment

row = {
    "record_id": "ST001",
    "location": "manor house",
    "genus": "QUERCUS",
    "species": "Robur",
}
print(validate_record(row, 2, set()))
# expect: (None, [])

row = {
    "record_id": "ST001",
    "location": "manor house",
    "genus": "Quercus",
    "species": "pendula",
}
print(validate_record(row, 2, set()))
# expect: (None, ['invalid genus/species combination'])

row = {
    "record_id": "st003",
    "location": "",
    "genus": "Quercas",
    "species": "robur",
}
print(validate_record(row, 2, set()))
# expect:

row = {
    "record_id": " ST001 ",
    "location": "manor house",
    "genus": "QUERCUS",
    "species": "Robur",
    "distance_m": "12.5",
    "angle_degrees": "30",
}
print(validate_record(row, 2, set()))
