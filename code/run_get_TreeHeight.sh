#!/usr/bin/env bash
# Run from the project root: bash code/run_get_TreeHeight.sh
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf -- "$test_root"' EXIT

mkdir -p "$test_root/data" "$test_root/results" "$test_root/sandbox"
cp "$repo_root/data/trees.csv" "$test_root/data/trees.csv"
cd "$test_root"

failures=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1" >&2; failures=$((failures + 1)); }

fixed_script="$repo_root/code/TreeHeight.R"
general_script="$repo_root/code/get_TreeHeight.R"
expected_header="Species,Distance.m,Angle.degrees,height_m"

if Rscript "$fixed_script" >sandbox/fixed_stdout.txt 2>sandbox/fixed_stderr.txt; then
    pass "fixed-input R command executed"
else
    fail "fixed-input R command failed"
fi

if [ "$(head -n 1 results/TreeHts.csv)" = "$expected_header" ]; then
    pass "fixed-input output header"
else
    fail "fixed-input output header"
fi

fixed_input_rows=$(awk 'END {print NR}' data/trees.csv)
fixed_output_rows=$(awk 'END {print NR}' results/TreeHts.csv)
if [ "$fixed_input_rows" -eq "$fixed_output_rows" ]; then
    pass "fixed-input row count ($fixed_output_rows lines)"
else
    fail "fixed-input row count (input $fixed_input_rows, output $fixed_output_rows)"
fi

if awk -F, 'NR == 2 { d = $4 - 27.8; if (d < 0) d = -d; exit (d < 0.01 ? 0 : 1) }' \
    results/TreeHts.csv; then
    pass "fixed-input height matches the independent 27.80 m check"
else
    fail "fixed-input first height does not match 27.80 m"
fi

if Rscript "$general_script" data/trees.csv \
    >sandbox/general_stdout.txt 2>sandbox/general_stderr.txt; then
    pass "generalized R command executed"
else
    fail "generalized R command failed"
fi

if [ "$(head -n 1 results/trees_treeheights.csv)" = "$expected_header" ]; then
    pass "generalized output header"
else
    fail "generalized output header"
fi

general_output_rows=$(awk 'END {print NR}' results/trees_treeheights.csv)
if [ "$fixed_input_rows" -eq "$general_output_rows" ]; then
    pass "generalized row count ($general_output_rows lines)"
else
    fail "generalized row count (input $fixed_input_rows, output $general_output_rows)"
fi

printf "Species,Distance.m,Angle.degrees\nTest species,8,45\n" \
    > sandbox/toy_trees.csv
if Rscript "$general_script" sandbox/toy_trees.csv \
    >sandbox/toy_stdout.txt 2>sandbox/toy_stderr.txt; then
    pass "toy R command executed"
else
    fail "toy R command failed"
fi

if [ "$(head -n 1 results/toy_trees_treeheights.csv)" = "$expected_header" ]; then
    pass "toy output header"
else
    fail "toy output header"
fi

if awk -F, 'NR == 2 { d = $4 - 8; if (d < 0) d = -d; exit (d < 1e-6 ? 0 : 1) }' \
    results/toy_trees_treeheights.csv; then
    pass "toy height is 8 m"
else
    fail "toy height is not 8 m"
fi

before=$(awk 'END {print NR}' results/toy_trees_treeheights.csv)
if Rscript "$general_script" sandbox/toy_trees.csv \
    >sandbox/rerun_stdout.txt 2>sandbox/rerun_stderr.txt; then
    pass "rerun R command executed"
else
    fail "rerun R command failed"
fi
after=$(awk 'END {print NR}' results/toy_trees_treeheights.csv)
if [ "$before" -eq "$after" ]; then
    pass "rerun replaces output ($after lines)"
else
    fail "rerun changed the line count ($before -> $after)"
fi

if Rscript "$general_script" >sandbox/no_argument_stdout.txt \
    2>sandbox/no_argument_stderr.txt; then
    fail "script ran without an input file"
else
    pass "missing argument is rejected"
fi

if Rscript "$general_script" data/trees.csv sandbox/toy_trees.csv \
    >sandbox/extra_argument_stdout.txt 2>sandbox/extra_argument_stderr.txt; then
    fail "script accepted more than one input file"
else
    pass "extra argument is rejected"
fi

printf "Species,Distance.m,Angle.degrees\nBad tree,-1,45\n" \
    > sandbox/invalid_trees.csv
printf "old output must remain unchanged\n" > results/invalid_trees_treeheights.csv
before_invalid=$(cat results/invalid_trees_treeheights.csv)
if Rscript "$general_script" sandbox/invalid_trees.csv \
    >sandbox/invalid_stdout.txt 2>sandbox/invalid_stderr.txt; then
    fail "generalized script accepted invalid distance"
else
    pass "generalized script rejects invalid distance"
fi
if grep -q "Distance.m must be greater than 0" sandbox/invalid_stderr.txt; then
    pass "generalized invalid-distance diagnostic is clear"
else
    fail "generalized invalid-distance diagnostic is missing"
fi
after_invalid=$(cat results/invalid_trees_treeheights.csv)
if [ "$before_invalid" = "$after_invalid" ]; then
    pass "generalized invalid input left an old output unchanged"
else
    fail "generalized invalid input changed an old output"
fi

printf "old fixed output must remain unchanged\n" > results/TreeHts.csv
before_fixed_invalid=$(cat results/TreeHts.csv)
printf "Species,Distance.m,Angle.degrees\nBad tree,-1,45\n" > data/trees.csv
if Rscript "$fixed_script" >sandbox/fixed_invalid_stdout.txt \
    2>sandbox/fixed_invalid_stderr.txt; then
    fail "fixed-input script accepted invalid distance"
else
    pass "fixed-input script rejects invalid distance"
fi
if grep -q "Distance.m must be greater than 0" sandbox/fixed_invalid_stderr.txt; then
    pass "fixed-input invalid-distance diagnostic is clear"
else
    fail "fixed-input invalid-distance diagnostic is missing"
fi
after_fixed_invalid=$(cat results/TreeHts.csv)
if [ "$before_fixed_invalid" = "$after_fixed_invalid" ]; then
    pass "fixed-input invalid input left an old output unchanged"
else
    fail "fixed-input invalid input changed an old output"
fi

exit "$failures"
