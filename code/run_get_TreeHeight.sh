#!/bin/bash
# The line above (the "shebang") tells the system to run this file with bash.
# Tests get_TreeHeight.R with trees.csv. Run from code/.

# Run the R script, passing it the input file path.
# This path is what commandArgs() picks up inside the R script.
Rscript get_TreeHeight.R ../data/trees.csv

# Print the first 3 lines of the output to check it worked.
head -n 3 ../results/trees_treeheights.csv