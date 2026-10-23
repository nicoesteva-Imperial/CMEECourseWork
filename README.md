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

```bash
Rscript code/TreeHeight.R
```

- Input: `data/trees.csv` (supplied, unchanged; 120 rows: `Species`, `Distance.m`, `Angle.degrees`)
- Output: `results/TreeHts.csv` (regenerated on each run), header
  `Species,Distance.m,Angle.degrees,height_m`
- Height: `height_m = Distance.m * tan(Angle.degrees * pi / 180)`
- Input checks (the script stops with a clear error if any fail):
  required columns present; `Distance.m` and `Angle.degrees` numeric and finite
  (no NA, NaN or Inf, with the bad row numbers reported); `0 < Distance.m <= 100`;
  `0 < Angle.degrees < 90`
- Verified:
  - Row 1 (Populus tremula, 31.67 m at 41.28°):
    `31.6658337740228 * tan(41.2826361937914 * pi / 180)` = 27.80 m, matching the output
  - Toy check: `8 * tan(45 * pi / 180)` = 8 m
  - Output has 121 lines (header + 120 rows) in input order; rerunning replaces
    the file rather than appending

### get_TreeHeight.R (command-line input)
Run from the project root:

```bash
Rscript code/get_TreeHeight.R data/trees.csv
```

- Takes exactly one CSV path with the same three columns as `trees.csv`
- Output: `results/<input-basename>_treeheights.csv`, e.g. `results/trees_treeheights.csv`;
  replaced on rerun; the input file is never overwritten
- Clear errors for: no argument, more than one argument, missing file, and a header
  that is not exactly `Species,Distance.m,Angle.degrees`; the same value checks
  as `TreeHeight.R` follow
- Limitation: the output name uses only the input's basename, so two inputs with the
  same filename in different folders (e.g. `data/trees.csv` and `sandbox/trees.csv`)
  write to the same result file, and the second run overwrites the first

### Tests
Run from the project root:

```bash
bash code/run_get_TreeHeight.sh
```

Creates a one-row test CSV, `sandbox/toy_trees.csv` (8 m at 45°), then checks:
1. Output header is the four expected columns (`trees.csv` and the toy file)
2. Output row count matches the input for `trees.csv`
3. Toy height is 8 m to within 1e-6 (floating-point tolerance)
4. Rerunning replaces the output (line count unchanged)
5. Calling the script with no argument fails

All 6 checks pass.

### Fixed vs command-line input
The `TreeHeight()` function, the value checks and the four-column output are
identical in both scripts. What changes in `get_TreeHeight.R` is where the input
path comes from (`commandArgs()` instead of a hard-coded path), the extra checks
on the argument and the file before reading, and the output name, which is now
built from the input's basename instead of being fixed.

## Pound Hill species richness

Run from the project root:

```bash
Rscript code/pound_hill_analysis.R
```

**Question:** how does mean plant species richness per quadrat vary among the
March, May and October cultivation treatments?

- Inputs (unchanged): `data/pound_hill_data.csv`, `data/pound_hill_meta_data.csv`
- Outputs (regenerated on each run):
  - `results/pound_hill_plot_richness.csv`: one row per plot (12):
    `Cultivation, Block, Plot, MeanRichness`
  - `results/pound_hill_plot_richness.pdf`: plot values by treatment, with treatment means
  - Extension: `results/pound_hill_plot_abundance.csv` and `.pdf` (total individuals
    per quadrat, averaged per plot)

**Method**
1. Blank counts are converted to 0 because the metadata (`BlankSpeciesCount`) states
   that blanks record an observed absence. This is specific to this dataset; a blank
   is not assumed to mean zero elsewhere.
2. The data are transposed and reshaped to long form (one row per species per quadrat)
   with `tidyr::pivot_longer()`.
3. Quadrat richness = number of species with `Count > 0`. A quadrat is identified by
   `Cultivation`, `Block`, `Plot` and `Quadrat` together (`Q1` alone is not unique).
4. Plot richness = mean of its quadrats' richness. Plots are the treatment-level
   replicates and have different numbers of quadrats, so averaging within plots first
   stops plots with more quadrats from carrying more weight.

**Checks**
- Counts are numeric, have no NA and are non-negative (the script stops otherwise)
- 41 species, 59 quadrats, 12 plots; the long table is 2419 × 6 (59 × 41)
- Data note: several species names in the raw file have a trailing space
  (e.g. `"Vulpia myuros "`); these are stripped with `trimws()`
- Reproducibility: closed R and ran the script twice from the project root; both runs
  recreated the same CSV and PDF without errors

**Interpretation:** see the comments at the end of `code/pound_hill_analysis.R`.

## Use of AI (tree heights and Pound Hill)
Tool: Claude (Anthropic), 19–23 October 2026.
Used as a tutor to point me to relevant sections of the course notes, explain errors,
and review my code step by step. I wrote the validation checks in `TreeHeight.R` with
guidance. Claude wrote parts directly as examples, which I then ran, checked and
edited: the argument and file checks in `get_TreeHeight.R`, the checks in
`run_get_TreeHeight.sh`, the summary and figure code in `pound_hill_analysis.R`,
and a draft of this README. The interpretation in `pound_hill_analysis.R` is my own.
I verified results by hand calculation (tree heights) and by checking counts and
outputs at each step (Pound Hill).