#!/bin/bash

# TODO 1: Check that exactly one argument is provided.

if [[ $# -ne 1 ]]; then
    printf "Usage: %s <file>\n" "$0" >&2
    exit 2
fi

# TODO 2: Check that the argument is a readable regular file.

if [[ ! -f "$1" || ! -r "$1" ]]; then
    printf "Error: '%s' is missing, not a file or not readable\n" "$1" >&2
    exit 1
fi

# Count the number of lines in the file.

NumLines=`wc -l < "$1"`

echo "The file $1 has $NumLines lines"
echo
