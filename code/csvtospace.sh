#!/usr/bin/env bash
# Author: Nicolas Esteva <nee26@ic.ac.uk>
# Script: csvtospace.sh
# Desc: convert a comma-separated file to space-separated values,
# Arguments: 1-> comma separated .csv file
# Date: October 2026
# Limitations: simple comma substitution, not a full CSV parser.
#   Commas inside quoted fields would wrongly become spaces, and
#   fields that already contain spaces become ambiguous in the output.

# check that only one argument is given
if [ "$#" -ne 1 ]; then
    echo "Usage: bash csvtospace.sh <file.csv>" >&2
    exit 1
fi

# check input is readable file
if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "Error: '$1' is missing, not a file or not readable" >&2
    exit 1
fi

# results
outdir="$(cd "$(dirname "$0")" && pwd)/../results"
mkdir -p "$outdir" || exit 1
output="$outdir/$(basename "$1").txt"

# tr without -s keeps empty fields;
tr ',' ' ' < "$1" > "$output" || { echo "Error: conversion failed" >&2; exit 1; }

echo "Saved $output"