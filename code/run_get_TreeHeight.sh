#!/bin/bash
# The line above (the "shebang") tells the system to run this file with bash.
# Tests get_TreeHeight.R with trees.csv. Run from the project root: bash code/run_get_TreeHeight.sh

# Run the R script, passing it the input file path.
# This path is what commandArgs() picks up inside the R script.
Rscript code/get_TreeHeight.R data/trees.csv > /dev/null

# Test file (that I already created internally as toy_trees.csv designed at 8m at 45 degrees in order to reciever height of 8m m)
mkdir -p sandbox
printf "Species,Distance.m,Angle.degrees\nTest species,8,45\n" > sandbox/toy_trees.csv
Rscript code/get_TreeHeight.R sandbox/toy_trees.csv > /dev/null

# Check 1: Matching header
Expected_header="Species,Distance.m,Angle.degrees,height_m"
if [ "$(head -1 results/trees_treeheights.csv)" = "$Expected_header" ];then
    echo "PASS: trees header"
else
    echo "FAIL: trees header"
fi

if [ "$(head -1 results/toy_trees_treeheights.csv)" = "$Expected_header" ]; then
    echo "PASS: toy header"
else
    echo "FAIL: toy header"
fi

# Check#2 output rows matches input rows
in_rows=$(awk 'END {print NR}' data/trees.csv)
out_rows=$(awk 'END {print NR}' results/trees_treeheights.csv)

if [ "$in_rows" -eq "$out_rows" ];then
    echo "PASS: trees row count ($out_rows lines)"
else
    echo "FAIL: trees row count (input $in_rows, output $out_rows)"
fi

# Check 3: toy height from the csv toy_trees.csv should be 8
if awk -F, 'NR == 2 { d = $4 - 8; if (d<0) d = -d; exit (d < 1e-6 ? 0 : 1) }' results/toy_trees_treeheights.csv; then
    echo "PASS: toy height is 8 m"
else
    echo "FAIL: toy height is not 8 m"
fi

# Check 4: rerunning replaces the output. NO APPEND
before=$(awk 'END {print NR}' results/toy_trees_treeheights.csv)
Rscript code/get_TreeHeight.R sandbox/toy_trees.csv > /dev/null
after=$(awk 'END {print NR}' results/toy_trees_treeheights.csv)

if [ "$before" -eq "$after" ]; then
    echo "PASS: rerun replaces output ($after lines)"
else
    echo "FAIL: rerun changed the line count ($before -> $after)"
fi

# Check 5: calling with no argument must fail
if Rscript code/get_TreeHeight.R > /dev/null 2>&1; then #No input file given after the script name, so get_TreeHeight.R should stop() with an error
    echo "FAIL: script ran without an input file"
else
    echo "PASS: missing argument is rejected"
fi

