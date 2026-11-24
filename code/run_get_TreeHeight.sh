#!/bin/bash
# Run from the project root: bash code/run_get_TreeHeight.sh
set -euo pipefail

failures=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1" >&2; failures=$((failures + 1)); }

mkdir -p sandbox

if Rscript code/get_TreeHeight.R data/trees.csv >/dev/null 2>&1; then
    pass "ordinary R command executed"
else
    fail "ordinary R command failed"
fi

printf "Species,Distance.m,Angle.degrees\nTest species,8,45\n" \
    > sandbox/toy_trees.csv
if Rscript code/get_TreeHeight.R sandbox/toy_trees.csv >/dev/null 2>&1; then
    pass "toy R command executed"
else
    fail "toy R command failed"
fi

# Check 1: Matching header
Expected_header="Species,Distance.m,Angle.degrees,height_m"
if [ "$(head -1 results/trees_treeheights.csv)" = "$Expected_header" ];then
    pass "trees header"
else
    fail "trees header"
fi

if [ "$(head -1 results/toy_trees_treeheights.csv)" = "$Expected_header" ]; then
    pass "toy header"
else
    fail "toy header"
fi

# Check#2 output rows matches input rows
in_rows=$(awk 'END {print NR}' data/trees.csv)
out_rows=$(awk 'END {print NR}' results/trees_treeheights.csv)

if [ "$in_rows" -eq "$out_rows" ];then
    pass "trees row count ($out_rows lines)"
else
    fail "trees row count (input $in_rows, output $out_rows)"
fi

# Check 3: toy height from the csv toy_trees.csv should be 8
if awk -F, 'NR == 2 { d = $4 - 8; if (d<0) d = -d; exit (d < 1e-6 ? 0 : 1) }' results/toy_trees_treeheights.csv; then
    pass "toy height is 8 m"
else
    fail "toy height is not 8 m"
fi

# Check 4: rerunning replaces the output. NO APPEND
before=$(awk 'END {print NR}' results/toy_trees_treeheights.csv)
if Rscript code/get_TreeHeight.R sandbox/toy_trees.csv >/dev/null 2>&1; then
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

# Check 5: calling with no argument must fail
if Rscript code/get_TreeHeight.R >/dev/null 2>&1; then
    fail "script ran without an input file"
else
    pass "missing argument is rejected"
fi

printf "Species,Distance.m,Angle.degrees\nBad tree,-1,45\n" \
    > sandbox/invalid_trees.csv
printf "old output must remain unchanged\n" > results/invalid_trees_treeheights.csv
before_invalid=$(sha256sum results/invalid_trees_treeheights.csv)
if Rscript code/get_TreeHeight.R sandbox/invalid_trees.csv \
    > sandbox/invalid_stdout.txt 2> sandbox/invalid_stderr.txt; then
    fail "invalid distance was accepted"
else
    pass "invalid distance is rejected"
fi
if grep -q "Distance.m must be greater than 0" sandbox/invalid_stderr.txt; then
    pass "invalid distance diagnostic is clear"
else
    fail "invalid distance diagnostic is missing"
fi
after_invalid=$(sha256sum results/invalid_trees_treeheights.csv)
if [ "$before_invalid" = "$after_invalid" ]; then
    pass "invalid input left an old output unchanged"
else
    fail "invalid input changed an old output"
fi

exit "$failures"

