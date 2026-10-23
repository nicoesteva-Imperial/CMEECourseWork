# Assignment 2 formative feedback

This feedback is organised by the relevant computing bootcamp criteria. Use it to decide what is already working, what you need to investigate, and what to revise before the cumulative submission.

The full criteria are in the [Computing Bootcamp assessment rubric](https://github.com/MulQuaBio/MQB/blob/main/content/rubrics/Computing_Bootcamp_Rubric.md).

## 1. Repository organisation and workflow discipline

- Your root README, `.gitignore`, cleaning script, test script and supplied data files are in the expected locations. The supplied CSV and metadata are unchanged, giving you a reproducible starting point.

## 2. Code completeness and functional correctness

- **Verify output generation independently of existing results.** I could not verify output creation from an empty results folder because `results/silwood_trees_clean.csv` was already committed. The three generated tables were unavailable, so I could not inspect them. This does not mean that your script failed to produce them. Make a separate copy of your repository in a new folder using `git clone` and confirm that the generated CSV files are not already present. Run the script there, then inspect the newly generated tables to check whether the final writing step works.
- First remove the generated output files from Git tracking and commit that change. Then make a separate copy of your repository in a new folder using `git clone`, confirm that the output CSVs are absent, and run the script there.

## 3. Code quality and style

- Your `main()` function gives the program a clear overall structure by connecting loading, processing, summarising and writing. Keep these stages distinct as you revise; use descriptive names and add short comments where the reason for a validation check or data-cleaning step is not obvious.

## 4. Documentation

- Your root README is in place. Make it useful to someone opening the repository for the first time: explain what the cleaner does, how to run the script and tests from the repository root, and which three files it creates. Test the instructions in a newly cloned copy of your repository (a separate folder created with `git clone`): enter that folder and run each README command exactly as written. If something fails, correct the command or add the missing step.

## 5. Version-control practice

- Since the previous formative feedback was added, the saved history contains 7 non-merge commits. Your messages distinguish code, README and ignore-file work, but phrases such as `The "finished" code...` and `cleaned csv files that are the output of the code` do not state the specific behaviour changed or why generated files should be tracked.
- Before each commit, run `git diff --staged` to see exactly what will be recorded. Keep one coherent, working change per commit and write a concise message that names what changed—for example, the validation rule added, the failing test fixed or the README instruction clarified.
- `results/silwood_trees_clean.csv` is currently tracked by Git. After confirming that it is a generated file, run `git rm --cached results/silwood_trees_clean.csv`; this removes it from Git without deleting your local copy. Keep the results path in `.gitignore`, commit the change, and use `git status` to confirm that generated CSVs will not be included again.

## 8. Basic error handling and input validation

- Your separate test file includes assertion-style checks for record validation, the accepted/rejected partition and the oak summary. It ran successfully. This is a useful start; now check the important edge cases and the contents of the written tables.
- Inspect all three newly written CSVs: check headers, trace a valid and an invalid record through the workflow, and verify a small oak-summary example by hand. Turn any discrepancy into a focused regression test.

## 9. Problem-solving approach and method implementation

- **Extend testing to the final writing step.** The tests cover processing stages, but the current checks do not show that all three written tables contain the intended data. Add a small end-to-end check using a few understandable records, checking that accepted and rejected records reach the appropriate tables and that the oak summary uses the accepted collection.
- Before final submission, add or refine a small assertion-based test in `code/test_silwood_trees.py` using one valid and one invalid record. Check that `process_records()` places them in the cleaned and issues collections respectively, then pass the cleaned collection to `summarise_oaks()` and check that the invalid record does not contribute. Run the complete cleaner and inspect the three output files. Briefly explain this flow in your root README.
