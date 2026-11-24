#!/bin/bash

# Check that exactly three arguments are provided.

if [[ $# -ne 3 ]]; then
    printf "Usage: %s <input1> <input2> <output>\n" "$0" >&2
    exit 2
fi

# Check that the first input is a readable regular file.

if [[ ! -f "$1" || ! -r "$1" ]]; then
    printf "Error: '%s' is missing, not a file or not readable\n" "$1" >&2
    exit 1
fi

# Check that the second input is a readable regular file.

if [[ ! -f "$2" || ! -r "$2" ]]; then
    printf "Error: '%s' is missing, not a file or not readable\n" "$2" >&2
    exit 1
fi

# Check that the output is not the same file as either input.

if [[ "$3" -ef "$1" || "$3" -ef "$2" ]]; then
    printf "Error: output '%s' must differ from both inputs\n" "$3" >&2
    exit 1
fi

# Merge the two input files into the output file.

cat "$1" > "$3"
cat "$2" >> "$3"

echo "Merged File is"
cat "$3"
