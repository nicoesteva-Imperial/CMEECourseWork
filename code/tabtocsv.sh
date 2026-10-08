#!/usr/bin/env bash
# Script: tabtocsv.sh
# Desc: substitute the tabs in the files with commas
#       saves the output into ../results/<filename>.csv
# Arguments: 1-> tab delimited file
# Date: Oct 2026

if [ "$#" -ne 1 ]; then
    echo "Usage: bash tabtocsv.sh <file>" >&2
    exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "Error: '$1' is missing, not a file or not readable" >&2
    exit 1
fi

# results
outdir="$(cd "$(dirname "$0")" && pwd)/../results"
mkdir -p "$outdir" || exit 1
output="$outdir/$(basename "$1").csv"

# tr without -s keeps empty fields
tr '\t' ',' < "$1" > "$output" || { echo "Error: conversion failed" >&2; exit 1; }

echo "Saved $output"

# ---- Previous version ----
# echo "Creating a comma delimited version of $1 ..."
# cat $1 | tr -s "\t" "," >> $1.csv
# echo "Done!"
# exit 0
