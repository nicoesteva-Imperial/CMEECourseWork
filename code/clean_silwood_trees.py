#!/usr/bin/env python3
"""Validate and clean the synthetic Silwood tree survey."""

from __future__ import annotations

import csv
from pathlib import Path
from typing import Iterable
import math
import re
from collections import Counter

PROJECT_ROOT = Path(__file__).resolve().parents[1]
INPUT_PATH = PROJECT_ROOT / "data" / "silwood_trees_raw.csv"
RESULTS_DIR = PROJECT_ROOT / "results"

INPUT_FIELDS = [
    "record_id",
    "location",
    "genus",
    "species",
    "distance_m",
    "angle_degrees",
]
ISSUE_FIELDS = ["source_row", "record_id", "reasons"]
OAK_COUNT_FIELDS = ["species", "count"]


def load_records(path: Path = INPUT_PATH) -> list[dict[str, str]]:
    """Read the survey and check its column names."""
    with path.open(newline="", encoding="utf-8") as source:
        reader = csv.DictReader(source)
        if reader.fieldnames != INPUT_FIELDS:
            raise ValueError(
                f"Expected columns {INPUT_FIELDS}, found {reader.fieldnames}"
            )
        return list(reader)


def validate_record(
    row: dict[str, str],
    source_row: int,
    accepted_ids: set[str],
) -> tuple[dict[str, str] | None, list[str]]:
    """Clean one record, or return the reasons it cannot be used."""
    reasons = []  # every problem found goes in here
    clean = {}  # the tidied-up version of the row

    # Allowed locations: lowercase spelling -> correct spelling
    locations = {
        "silwood bottom": "Silwood Bottom",
        "nash's field": "Nash's Field",
        "manor house": "Manor House",
        "reactor wood": "Reactor Wood",
    }

    # record_id
    record_id = (row.get("record_id") or "").strip()
    if record_id == "":
        reasons.append("missing record_id")
    elif not re.fullmatch(r"ST[0-9]{3}", record_id):
        reasons.append("invalid record_id")
    elif record_id in accepted_ids:
        reasons.append("duplicate record_id")
    clean["record_id"] = record_id

    # location
    location = (row.get("location") or "").strip()
    if location == "":
        reasons.append("missing location")
    elif location.lower() not in locations:
        reasons.append("invalid location")
    else:
        clean["location"] = locations[location.lower()]

    # genus list
    genera = {
        "quercus": "Quercus",
        "acer": "Acer",
        "betula": "Betula",
        "fagus": "Fagus",
        "fraxinus": "Fraxinus",
    }

    # genera
    genus = (row.get("genus") or "").strip()
    if genus == "":
        reasons.append("missing genus")
    elif genus.lower() not in genera:
        reasons.append("invalid genus")
    else:
        clean["genus"] = genera[genus.lower()]

    # Species List
    species_names = {
        "robur": "robur",
        "petraea": "petraea",
        "pseudoplatanus": "pseudoplatanus",
        "pendula": "pendula",
        "sylvatica": "sylvatica",
        "excelsior": "excelsior",
    }

    # species
    species = (row.get("species") or "").strip()
    if species == "":
        reasons.append("missing species")
    elif species.lower() not in species_names:
        reasons.append("invalid species")
    else:
        clean["species"] = species_names[species.lower()]

    # genus/species combination
    # This will only work if both the genus and species above were accepted
    allowed_pairs = {
        ("Quercus", "robur"),
        ("Quercus", "petraea"),
        ("Acer", "pseudoplatanus"),
        ("Betula", "pendula"),
        ("Fagus", "sylvatica"),
        ("Fraxinus", "excelsior"),
    }

    if "genus" in clean and "species" in clean:
        if (clean["genus"], clean["species"]) not in allowed_pairs:
            reasons.append("invalid genus/species combination")

    # distance_m
    distance_text = (row.get("distance_m") or "").strip()
    if distance_text == "":
        reasons.append("missing distance_m")
    else:
        try:
            distance = float(distance_text)
        except ValueError:
            distance = None  # this is text that is not a number

        if distance is None or not math.isfinite(distance):
            reasons.append("invalid distance_m")
        elif not (0 < distance <= 100):
            reasons.append("distance_m out of range")
        else:
            clean["distance_m"] = str(distance)

    # angle_degrees
    angle_text = (row.get("angle_degrees") or "").strip()
    if angle_text == "":
        reasons.append("missing angle_degrees")
    else:
        try:
            angle = float(angle_text)
        except ValueError:
            angle = None  # this is text that is not a number

        if angle is None or not math.isfinite(angle):
            reasons.append("invalid angle_degrees")
        elif not (0 < angle < 90):
            reasons.append("angle_degrees out of range")
        else:
            clean["angle_degrees"] = str(angle)

    # accepatnce of rows (no issues were found)
    if reasons:
        return None, reasons
    return clean, []


def process_records(
    rows: Iterable[dict[str, str]],
) -> tuple[list[dict[str, str]], list[dict[str, str]]]:
    """Sort records into accepted rows and issue reports."""
    accepted = []  # tray for good rows       (a list, starts empty)
    issues = []  # tray for rejected rows   (a list, starts empty)
    accepted_ids = set()  # notepad of IDs used      (a set, starts empty)

    for source_row, row in enumerate(rows, start=2):
        clean, reasons = validate_record(row, source_row, accepted_ids)
        if reasons:
            issues.append(
                {
                    "source_row": str(source_row),
                    "record_id": (row.get("record_id") or "").strip(),
                    "reasons": "; ".join(reasons),
                }
            )
        else:
            # ``reasons`` being empty guarantees validation succeeded, but
            # make the optional return explicit for static type checkers.
            if clean is None:
                continue
            accepted.append(clean)
            accepted_ids.add(clean["record_id"])

    accepted.sort(key=lambda record: record["record_id"])
    return accepted, issues


def summarise_oaks(
    clean_records: Iterable[dict[str, str]],
) -> list[dict[str, str]]:
    """Count accepted oak records by species."""
    counts = Counter()
    for record in clean_records:
        if record["genus"] == "Quercus":
            counts[record["species"]] += 1

    oak_counts = []
    for species in sorted(counts):
        oak_counts.append({"species": species, "count": str(counts[species])})

    return oak_counts


def write_csv(
    path: Path,
    fieldnames: list[str],
    rows: Iterable[dict[str, str]],
) -> None:
    """Write rows to a CSV file, replacing an older copy."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as destination:
        writer = csv.DictWriter(destination, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    """Clean the survey and write the three result files."""
    clean_records, issues = process_records(load_records())
    oak_counts = summarise_oaks(clean_records)

    write_csv(
        RESULTS_DIR / "silwood_trees_clean.csv",
        INPUT_FIELDS,
        clean_records,
    )
    write_csv(
        RESULTS_DIR / "silwood_tree_issues.csv",
        ISSUE_FIELDS,
        issues,
    )
    write_csv(
        RESULTS_DIR / "oak_species_counts.csv",
        OAK_COUNT_FIELDS,
        oak_counts,
    )


if __name__ == "__main__":
    main()
