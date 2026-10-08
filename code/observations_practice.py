import csv


def load_observations(path):
    with open(path, newline="", encoding="utf-8") as stream:
        return list(csv.DictReader(stream))


if __name__ == "__main__":
    rows = load_observations(
        "data/bootcamp_observations/bootcamp_observations.csv"
    )
    print(rows[0])
    print(rows[2])


def parse_count(count_text):
    if not isinstance(count_text, str):
        raise ValueError(f"Count must be text: {count_text!r}")
    if count_text == "":
        return None
    count = int(count_text)
    if count < 0:
        raise ValueError(f"Count cannot be negative: {count_text}")
    return count
