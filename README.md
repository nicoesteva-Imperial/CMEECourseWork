My Git practice repository

# Silwood tree-survey cleaning

## Input and outputs
Input: `data/silwood_trees_raw.csv` (this should be never edited, good practice/ This is because you don't want to edit data when it's past collection point, as things can be forgotten or changed)
 Outputs (in `results/`, regenerated on each run):
  - `silwood_trees_clean.csv`: accepted records, cleaned, sorted by record_id
  - `silwood_tree_issues.csv`: rejected rows, with their line number and reasons
  - `oak_species_counts.csv`: number of accepted Quercus records per species

## Plan (pseudocode)
```
load all rows from the raw CSV
start with: empty accepted list, empty issues list, empty set of accepted IDs

The layout below will be followed for all of the validation cases. The idea here is for it to be easy and to follow, easily replicable, and 

for each row, numbered from line 2:
    validate the row:
        tidy each field (strip spaces, match names ignoring case)
        check each field in turn; note every problem found
    if there are no problems:
        add the cleaned row to acceptedgode .giti   
        remember its ID
    otherwise:
        add (line number, ID, reasons) to issues

sort accepted by ID
count the oak species among accepted rows
write the three CSV files
```

## How to run
```bash
python3 code/clean_silwood_trees.py
python3 code/test_silwood_trees.py
```

## A useful test
... (e.g. a Quercus/pendula row should give "invalid genus/species
combination"; this caught a typo, "spcies", that silently skipped the check. This is an error I made many times as a typo, but is a great example of things that can go unnoticed)

## Limitations
- `float()` also accepts forms like `1e2` and `1_0`, so these are treated as numbers.
- Very small numbers may be written in scientific notation (e.g. `1e-05`).

## Use of AI
Tool: Claude (Anthropic), 12–17 October 2026.
Used as a tutor to explain the starter code and metadata, explain errors,
and review my code. It also wrote some code directly as examples that was then edited. it helped a lot with the Counter function and helped laying out the logic and syntax of the code.
I checked suggestions by running small test rows in sandbox/ and comparing
them against results I had worked out by hand from the metadata.

## Tree heights

### TreeHeight.R (fixed input)
Run from the project root:
    Rscript code/TreeHeight.R
- Input: `data/trees.csv` (supplied, unchanged)
- Output: `results/TreeHts.csv` (regenerated on each run)
- Checks in the script: [list the 5 input checks]
- Verified: [the row 1 calculation you checked], toy 8 m at 45° = 8 m,
  output has 120 data rows, rerun replaces rather than appends.

### get_TreeHeight.R (command-line input)
Run from the project root:
    Rscript code/get_TreeHeight.R data/trees.csv
- Output: `results/<input-basename>_treeheights.csv`
- Errors for: [no argument, extra arguments, missing file, wrong header]
- Limitation: [what happens with two inputs that share a basename]

### Tests
    bash code/run_get_TreeHeight.sh
- [What the 6 checks cover; the toy CSV in `sandbox/`]

### Fixed vs command-line input
[Your Part 4 answer: what stays the same, what changes]

## Pound Hill species richness

Run from the project root:
    Rscript code/pound_hill_analysis.R
- Inputs: `data/pound_hill_data.csv`, `data/pound_hill_meta_data.csv` (unchanged)
- Outputs: `results/pound_hill_plot_richness.csv` and `.pdf`,
  plus the abundance extension: `results/pound_hill_plot_abundance.csv` and `.pdf`
- Blanks converted to zeros because [metadata justification]
- Checks: [counts numeric, non-negative, no NA; 41 species, 59 quadrats, 12 plots]
- Data note: [the trailing spaces you found in species names]
- Rerun check: [what you did and saw]
- Interpretation: see the comments at the end of the script.