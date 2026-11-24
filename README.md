# CMEE Coursework

Coursework and practice exercises in Unix, Bash, Python and R. Commands below
are written for a terminal opened at the repository root unless stated
otherwise.

## Repository layout

This is the tracked project layout. `results/` and `sandbox/` are ignored
working directories: scripts create results as needed, and scratch/test files
belong in the sandbox. Generated files are not part of a fresh clone.

```text
.
├── .gitignore
├── .vscode/
│   └── launch.json
├── Feedback/
│   ├── assignment-1-2026.md
│   ├── assignment-2-2026.md
│   └── assignment-3-2026.md
├── README.md
├── code/
│   ├── apply1.R
│   ├── apply2.R
│   ├── basic_io.R
│   ├── boilerplate.py
│   ├── boilerplate.R
│   ├── boilerplate.sh
│   ├── break.R
│   ├── browse.R
│   ├── buggy_function.R
│   ├── cfexercises1.py
│   ├── cfexercises2.py
│   ├── CheckLabel.sh
│   ├── clean_silwood_trees.py
│   ├── ConcatenateTwoFiles.sh
│   ├── control_flow.py
│   ├── control_flow.R
│   ├── CountLines.sh
│   ├── csvtospace.sh
│   ├── data_wrang.R
│   ├── data_wrang_tidy.R
│   ├── debugme.py
│   ├── example.py
│   ├── get_TreeHeight.R
│   ├── loops.py
│   ├── MyExampleScript.py
│   ├── MyExampleScript.sh
│   ├── next.R
│   ├── observations_practice.py
│   ├── observations_practice.R
│   ├── pound_hill_analysis.R
│   ├── preallocate.R
│   ├── Python_Practice.py
│   ├── Python_with_strings.py
│   ├── r_conditionals.R
│   ├── ricker.R
│   ├── run_get_TreeHeight.sh
│   ├── sample.R
│   ├── sql_in_r.R
│   ├── sysargv.py
│   ├── tabtocsv.sh
│   ├── test_control_flow.py
│   ├── test_observations_practice.py
│   ├── test_silwood_trees.py
│   ├── tiff2_png.sh
│   ├── TreeHeight.R
│   ├── try.R
│   ├── unixPrac1.txt
│   ├── using_name.py
│   ├── variables.sh
│   └── Vectorize1.R
└── data/
    ├── bootcamp_observations.csv
    ├── bootcamp_observations_boundary.csv
    ├── bootcamp_observations_invalid.csv
    ├── bootcamp_observations/
    │   ├── bootcamp_observations.csv
    │   ├── bootcamp_observations_boundary.csv
    │   └── bootcamp_observations_invalid.csv
    ├── ecol_archives_e_089_51_d_1.csv
    ├── fasta/
    │   ├── 407228326.fasta
    │   ├── 407228412.fasta
    │   └── e_coli.fasta
    ├── pound_hill_data.csv
    ├── pound_hill_meta_data.csv
    ├── resource.csv
    ├── silwood_trees_metadata.md
    ├── silwood_trees_raw.csv
    ├── spawannxs.txt
    ├── tab-example.tsv
    ├── temperatures/
    │   ├── 1800.csv
    │   ├── 1801.csv
    │   ├── 1802.csv
    │   └── 1803.csv
    └── trees.csv
```

### What the other project files contain

- `.gitignore` excludes generated results, scratch files, Python caches and
  local R plots from version control.
- `.vscode/launch.json` contains VS Code Python debugger launch configurations.
- `Feedback/assignment-1-2026.md`, `Feedback/assignment-2-2026.md` and
  `Feedback/assignment-3-2026.md` contain formative feedback for the three
  earlier assignments.
- `data/fasta/407228326.fasta`, `data/fasta/407228412.fasta` and
  `data/fasta/e_coli.fasta` are DNA sequence inputs for the Unix exercises.
- `data/tab-example.tsv` is a tab-separated sample table with an empty field.
- `data/temperatures/1800.csv`, `data/temperatures/1801.csv`,
  `data/temperatures/1802.csv` and `data/temperatures/1803.csv` are yearly
  climate-data inputs.
- `data/trees.csv` contains tree species, distance and angle measurements.
- `data/silwood_trees_raw.csv` contains raw survey records;
  `data/silwood_trees_metadata.md` describes the cleaning rules.
- `data/pound_hill_data.csv` contains species counts;
  `data/pound_hill_meta_data.csv` describes the sampling fields.
- `data/bootcamp_observations.csv`, `data/bootcamp_observations_boundary.csv`
  and `data/bootcamp_observations_invalid.csv` are the ordinary, boundary and
  invalid observation examples used by the practice scripts.
- `data/bootcamp_observations/bootcamp_observations.csv`,
  `data/bootcamp_observations/bootcamp_observations_boundary.csv` and
  `data/bootcamp_observations/bootcamp_observations_invalid.csv` are the
  corresponding nested copies; the scripts use the top-level files.
- `data/resource.csv` contains resource records loaded into SQLite by
  `sql_in_r.R`.
- `data/ecol_archives_e_089_51_d_1.csv` contains predator–prey interaction
  records.
- `data/spawannxs.txt` is a protected marine and coastal species list.

## Software

- Bash and standard Unix tools; `bc` is needed for the AT/GC ratio exercise.
- Python 3 (the Python scripts and tests use the standard library).
- R with `Rscript`. Extra R packages are `reshape2` for `data_wrang.R`,
  `tidyr` and `dplyr` for `data_wrang_tidy.R`, `tidyr`, `dplyr` and `ggplot2`
  for `pound_hill_analysis.R`, and `DBI` and `RSQLite` for `sql_in_r.R`.
- ImageMagick's `convert` command is needed for `tiff2_png.sh`.

Install any missing R packages from R with
`install.packages(c("reshape2", "tidyr", "dplyr", "ggplot2", "DBI", "RSQLite"))`.
Individual scripts only need the packages listed for them above.

## Main workflows 

### Silwood tree survey

```text
read the CSV and confirm that its header has the six required fields
start empty collections for accepted records, rejected-record issues and used IDs
for each CSV record, keeping its source line number:
    trim text fields and normalize recognized names without guessing misspellings
    check the ID, location, genus/species pair, distance and angle
    collect every validation problem found for this record
    if there are no problems:
        add the cleaned record to accepted records and remember its ID
    otherwise:
        add its line number, ID and reasons to the issues report
sort accepted records by ID
count Quercus species among accepted records only
write the accepted records, issues and oak counts to three separate CSVs
```

### Tree heights

```text
read data/trees.csv, or take one CSV path from the command line
check the required header and confirm distance and angle values are finite
require 0 < distance <= 100 metres and 0 < angle < 90 degrees
convert each angle from degrees to radians
calculate height = distance * tan(angle in radians)
write the original columns plus height_m to results/
```

The fixed-input script always writes `TreeHts.csv`; the command-line script
uses the input basename, such as `trees_treeheights.csv`.

### Bootcamp observations

```text
read each row as text and require exactly site, date and count
reject empty site/date values and counts that are not blank or non-negative integers
remove exact duplicate records
for each site:
    sum known integer counts
    count blank counts separately (a blank is not the same as zero)
    if every count is blank, report the known total as missing rather than zero
write the R summary table and figure; the Python version prints its report
```

### Pound Hill richness and abundance

```text
read the data and metadata; use the metadata rule that blank counts mean zero
transpose the table, trim species-name whitespace and reshape to one row
per species per quadrat
identify each quadrat by cultivation, block, plot and quadrat together
for each quadrat:
    richness = number of species with count > 0
    abundance = sum of all species counts
for each plot, average its quadrat richness and abundance
write one 12-plot CSV and one PDF figure for each measure
```

## Run and check the scripts

The tables give each script's purpose, inputs and outputs, and a command to run
or check it. File paths in commands are relative to the project root except
where a script explicitly operates on files in its current directory.

### Unix and Bash

| File | What it does; input → output | Run/check |
|---|---|---|
| `code/unixPrac1.txt` | Five FASTA command-line answers: count lines, print/measure the *E. coli* sequence, count `ATGC`, and calculate AT/GC. Reads `data/fasta/*`; prints to terminal. | Run the five commands individually from `code/` as written in the file (`cd code` first). The final answer requires `bc`. |
| `code/tabtocsv.sh` | Replaces tabs with commas; one readable TSV → `results/<input-name>.csv`. | `bash code/tabtocsv.sh data/tab-example.tsv` |
| `code/csvtospace.sh` | Replaces commas with spaces; one readable CSV → `results/<input-name>.txt`. This is a simple character replacement, not a quoted-CSV parser. | `bash code/csvtospace.sh data/trees.csv` |
| `code/variables.sh` | Demonstrates script arguments, variables and reading text/two integers from standard input. | `printf 'new text\n3 4\n' \| bash code/variables.sh first second` |
| `code/boilerplate.sh` | Minimal shell-script example; no input → greeting on the terminal. | `bash code/boilerplate.sh` |
| `code/MyExampleScript.sh` | Prints a greeting using the current user's name; no input → terminal text. | `bash code/MyExampleScript.sh` |
| `code/CheckLabel.sh` | Accepts the label `oak` or `pine`; argument → selected-label message or an error. | `bash code/CheckLabel.sh oak` |
| `code/CountLines.sh` | Counts newline-terminated lines in one readable file → terminal message. | `bash code/CountLines.sh data/spawannxs.txt` |
| `code/ConcatenateTwoFiles.sh` | Joins two readable text files into a third file and prints it; two inputs plus output path. | `mkdir -p results && bash code/ConcatenateTwoFiles.sh data/tab-example.tsv data/spawannxs.txt results/concatenated.txt` |
| `code/tiff2_png.sh` | Converts every `*.tif` in the current directory to a same-basename PNG beside it; requires ImageMagick. No TIFF fixture is stored in `data/`. | `mkdir -p sandbox/tiff-check && convert -size 1x1 xc:white sandbox/tiff-check/check.tif && (cd sandbox/tiff-check && bash ../../code/tiff2_png.sh)` |

### Python

| File | What it does; input → output | Run/check |
|---|---|---|
| `code/loops.py` | Demonstrates `for`/`while` loops, iteration and a running sum; no input → terminal values. | `python3 code/loops.py` |
| `code/cfexercises1.py` | Small conditional/loop functions for square root, maximum, sorting and factorials; built-in examples include 0! and 1! → terminal results. | `python3 code/cfexercises1.py` |
| `code/cfexercises2.py` | Demonstrates loops, conditions and `break`; fixed examples → terminal messages. | `python3 code/cfexercises2.py` |
| `code/control_flow.py` | Reusable parity, divisor, prime and threshold-count functions; built-in examples → terminal results. | `python3 code/control_flow.py` |
| `code/test_control_flow.py` | Assertions for normal, boundary and invalid function inputs; imports `control_flow.py` → silent success or assertion failure. | `python3 code/test_control_flow.py` |
| `code/observations_practice.py` | Reads `data/bootcamp_observations.csv`; deduplicates records and reports each site's known-count total and number of missing counts → terminal summary. | `python3 code/observations_practice.py` |
| `code/test_observations_practice.py` | Tests count parsing, validation, duplicates, missing/zero counts and all three observation fixtures → silent success or assertion failure. | `python3 code/test_observations_practice.py` |
| `code/clean_silwood_trees.py` | Reads `data/silwood_trees_raw.csv`; validates/sorts records and counts accepted oaks → three CSVs in `results/`. | `python3 code/clean_silwood_trees.py` |
| `code/test_silwood_trees.py` | Tests record validation, accepted/rejected rows, oak counts and CSV writing in a temporary directory → test report. | `python3 code/test_silwood_trees.py` |
| `code/MyExampleScript.py` | Defines and calls a square function; no input → terminal result. | `python3 code/MyExampleScript.py` |
| `code/boilerplate.py` | Import-safe Python program skeleton; no input → terminal message. | `python3 code/boilerplate.py` |
| `code/using_name.py` | Demonstrates the module `__name__` value; no input → terminal message. | `python3 code/using_name.py` |
| `code/sysargv.py` | Prints script name and supplied command-line arguments; optional arguments → terminal report. | `python3 code/sysargv.py alpha beta` |
| `code/debugme.py` | Demonstrates `try`/`except` handling while decrementing a number; fixed input `20` → diagnostic messages. | `python3 code/debugme.py` |
| `code/example.py` | Defines `square()` with a doctest; no file input or output when run as a script. | `python3 -m doctest code/example.py` |
| `code/Python_Practice.py` | Minimal string-length expression example; no input or printed output. | `python3 code/Python_Practice.py` |
| `code/Python_with_strings.py` | Demonstrates string replacement, splitting, trimming and case conversion; expressions are evaluated but not printed. | `python3 code/Python_with_strings.py` |

### R

| File | What it does; input → output | Run/check |
|---|---|---|
| `code/TreeHeight.R` | Reads `data/trees.csv`, validates measurements and calculates `distance × tan(angle in radians)` → `results/TreeHts.csv`. | `Rscript code/TreeHeight.R` |
| `code/get_TreeHeight.R` | Same calculation for one CSV argument with columns `Species,Distance.m,Angle.degrees` → `results/<input-basename>_treeheights.csv`. | `Rscript code/get_TreeHeight.R data/trees.csv` |
| `code/run_get_TreeHeight.sh` | Runs fixed/general tree-height checks in a temporary directory: headers, row counts, a known and toy height, reruns and invalid inputs. | `bash code/run_get_TreeHeight.sh` |
| `code/pound_hill_analysis.R` | Reads Pound Hill data/metadata; counts species richness and abundance per quadrat, averages per plot → two CSVs and two PDFs in `results/`. Needs `tidyr`, `dplyr`, `ggplot2`. | `Rscript code/pound_hill_analysis.R` |
| `code/data_wrang.R` | Reshapes Pound Hill data from wide to long form; reads both Pound Hill CSVs → `results/pound_hill_long.csv`. Needs `reshape2`. | `Rscript code/data_wrang.R` |
| `code/data_wrang_tidy.R` | Same long-form transformation using `pivot_longer`; reads both Pound Hill CSVs → `results/pound_hill_long_tidy.csv` and checks dimensions/count total. Needs `tidyr`, `dplyr`. | `Rscript code/data_wrang_tidy.R` |
| `code/observations_practice.R` | Validates ordinary, boundary and invalid observation data, summarizes known/missing counts → `results/observations_by_site.csv` and `.pdf`. Uses base R. | `Rscript code/observations_practice.R` |
| `code/sql_in_r.R` | Loads `data/resource.csv`, creates/query SQLite example tables → `results/sql_in_r.sqlite` and printed query results. Needs `DBI`, `RSQLite`. | `Rscript code/sql_in_r.R` |
| `code/basic_io.R` | Reads `data/trees.csv` and demonstrates CSV writing, appending and row/column-name options → `results/MyData.csv`. | `Rscript code/basic_io.R` |
| `code/apply1.R` | Applies row/column means and variances to a random matrix; no input → values on the terminal. | `Rscript code/apply1.R` |
| `code/apply2.R` | Applies a function to random matrix rows, multiplying rows with positive sums by 100; no input → matrix on the terminal. | `Rscript code/apply2.R` |
| `code/boilerplate.R` | Defines and calls a two-argument function; fixed values → argument classes and returned values on the terminal. | `Rscript code/boilerplate.R` |
| `code/control_flow.R` | Demonstrates R conditionals, `for` loops and a `while` loop; no input → random comparisons and loop results. | `Rscript code/control_flow.R` |
| `code/r_conditionals.R` | Defines and demonstrates even/odd, power-of-two and prime conditionals; fixed values → terminal results. | `Rscript code/r_conditionals.R` |
| `code/break.R` | Counts in a `while` loop until `break`; no input → values 0–9. | `Rscript code/break.R` |
| `code/next.R` | Demonstrates skipping even numbers in a loop; no input → odd values 1–9. | `Rscript code/next.R` |
| `code/ricker.R` | Simulates and plots a 10-generation Ricker population model; no input → plot (`Rplots.pdf` when run non-interactively). | `Rscript code/ricker.R` |
| `code/sample.R` | Compares loop/preallocation and `lapply`/`sapply` sampling methods; fixed random seed → histogram and timings (`Rplots.pdf` when run non-interactively). | `Rscript code/sample.R` |
| `code/preallocate.R` | Compares growing and preallocated vectors; no input → values, object sizes and timings. | `Rscript code/preallocate.R` |
| `code/Vectorize1.R` | Compares nested-loop summation with vectorized `sum()` on a random matrix; no input → timings. | `Rscript code/Vectorize1.R` |
| `code/try.R` | Demonstrates caught errors using repeated random samples; no input → sample means and caught-error messages. | `Rscript code/try.R` |
| `code/browse.R` | Interactive exponential-growth example with a `browser()` breakpoint; no file input → inspect values in the debugger, then a plot. | Start R with `R`; enter `source("code/browse.R")`; inspect `N[t]` and `N[t-1]` at a breakpoint, check the recurrence `N[t] = N[t-1] * exp(r)`, then type `c` to continue. |
| `code/buggy_function.R` | Defines a deliberately broken function that references `unknown_variable`; sourcing only defines it, calling it demonstrates an R error. | Define only: `Rscript code/buggy_function.R`. To demonstrate the error: `Rscript -e 'source("code/buggy_function.R"); buggy_function(1)'` (expected failure). |

`tiff2_png.sh` is the only listed utility that depends on files not supplied in
this repository. `browse.R` is interactive. The `buggy_function.R` example is
deliberately erroneous; its failing call is not a successful test.

## Coursework checks and evidence

Run the focused checks from the repository root:

```bash
python3 code/test_control_flow.py
python3 code/test_observations_practice.py
python3 code/test_silwood_trees.py
bash code/run_get_TreeHeight.sh
```


- All three Python test commands above passed.
- `run_get_TreeHeight.sh` passed its fixed-input, generalized-input, toy,
  rerun, argument-error and invalid-distance checks.
- Running the Silwood cleaner produced 24 accepted records, 12 issue rows and
  two oak-species rows; the output headers and sample rows were inspected.
- Running the Pound Hill analysis reported 41 species, 59 quadrats and 12
  plots. Both plot-level CSVs had 12 data rows and both PDFs were generated.
- The richness PDF was opened beside its CSV. The plot points match the 12
  plot means; the treatment means are March 7.808, May 9.650 and October
  7.613. The plot-mean ranges and spreads also match the CSV: March
  6.333–10.000 (3.667), May 7.400–11.600 (4.200), October 6.400–10.250
  (3.850).
- The other non-interactive script examples in the tables completed
  successfully from the repository root. TIFF conversion was checked using
  the generated 1×1 fixture above; `browse.R` was run through its breakpoints.


Changes made in response to formative feedback and checked:

- Added the tab-separated example, documented the FASTA newline detail and
  clarified converter input/output errors. `tabtocsv.sh` and `csvtospace.sh`
  preserve empty fields and write to `results/`.
- Extended Silwood tests through CSV writing, including a valid and invalid
  record, and verified that only accepted oaks are counted.
- Strengthened tree-height validation and the test wrapper so failed R runs,
  bad inputs and stale output files cannot pass as successful checks. Added
  an independent height calculation and toy case.
- Trimmed Pound Hill species labels before reshaping, averaged quadrat
  richness within plots, and clarified that reported ranges are ranges of
  plot means.
- Added checks for the control-flow and observation practice functions,
  including boundary and invalid values.
- Generated results and scratch files are ignored; a fresh clone starts
  without those outputs.

## AI assistance

- **Claude (Anthropic), 12–17 October 2026:** used to understand the tree-survey
  starter code and metadata, troubleshoot errors and review the cleaning
  workflow. Suggestions were checked with small test rows in `sandbox/` and
  by comparing expected values with the metadata.
- **Claude (Anthropic), 19–23 October 2026:** used for explanations of the
  course material, debugging and review of the tree-height and Pound Hill
  work. Suggested examples were edited and checked with a hand-calculated
  tree height, test-wrapper cases, output dimensions and the generated
  analysis tables; the ecological interpretation was written by the author.
- **Claude (Anthropic), 24 November 2026:** used to compare the revised
  practice scripts with the current course notes and to explain errors and
  test cases. Assistance included hints and examples for control-flow,
  observation and tidy-data practice; the functions, outputs and checks were
  tested from the project root against the supplied fixtures.
- **Copilot in VS Code, 24 November 2026:** used in this task to inventory the
  repository, compare it with the assignment briefs and formative feedback. File paths and commands were checked against the
  source and the focused test commands; no program code was changed.
