# Assignment 3 formative feedback

This feedback is organised using the [Computing Bootcamp rubric](https://mulquabio.github.io/MQB/rubrics/Computing_Bootcamp_Rubric.html). It does not award a mark; use it to decide what to revise and check before final submission.

## Criterion 1: Repository organisation & workflow discipline

- Before final submission, **Make fresh tree outputs distinguishable from committed results.** Both ordinary tree runs require review because `results/TreeHts.csv` and `results/trees_treeheights.csv` were already committed. Their generated-output archives were not collected, so their numerical contents remain unchecked—not demonstrated incorrect. Many other generated files are also tracked despite `results/` being ignored. Ignore rules do not remove files already tracked: remove generated results from Git tracking while retaining local copies, then check that both programs recreate their own outputs.

## Criterion 2: Code completeness & functional correctness

- Before final submission, **Make the test wrapper report genuine execution failures.** In the supplied shell source, failed R commands do not explicitly stop the tests, and printing `FAIL` does not ensure an unsuccessful final exit. Existing CSVs could therefore make later checks misleading. Add basic checks of each R command’s success and ensure a failed test gives an unsuccessful overall outcome. Try a deliberately unsuccessful run with an old output present to check that it cannot appear successful.

## Criterion 3: Code quality & style

As you revise, keep names descriptive, use comments to explain decisions rather than restating code, and avoid repeating the same calculation in several places.

## Criterion 4: Documentation

- All required paths are present, and the supplied data files are unchanged. Your README gives separate commands, inputs and outputs for the fixed and generalised tree-height routes, alongside useful explanations of validation and output naming.

## Criterion 5: Version-control practice

Commit each functional revision with a short message that says what changed; this makes your development easier to follow than one large final commit.

## Criterion 8: Basic error-handling & input validation

- The invalid tree-input runs stopped with relevant distance and non-finite-value messages. Your Git history also contains descriptive messages identifying documentation, validation and analysis changes.

## Criterion 9: Problem-solving approach & method implementation

- Your code shows the tree-height function taking angle first and distance second, converting degrees to radians before calculating height. Your README records an independent calculation and a toy check; these provide a useful checking approach, although their reported results were not independently verified in this run.
- The Pound Hill script ran and generated the required outputs. Its richness table had the expected rows, plot identifiers and richness values. Comments in your code explain the metadata-based treatment of blanks and the averaging of quadrats within plots. When I opened the figure, I found a clear title and axes, plot-level points and treatment means.
- Before final submission, **Tighten the link between Pound Hill results, documentation and interpretation.** Your interpretation appropriately avoids attributing everything to cultivation timing, but the wording about ranges is ambiguous. Compare each treatment’s minimum, maximum and spread in the generated table with the PDF, then state clearly which quantity you mean. The README also says species names are trimmed with `trimws()`, but that operation is absent from the supplied script. Reconcile the description and implementation so another reader can reproduce the stated method.

## Criterion 10: Learning progression demonstration

Use this feedback as a revision checklist. Make the changes in small, descriptive commits, then add a short README note explaining what you changed and how you checked it. This will make your development from this formative checkpoint visible in the final portfolio.

## Priorities before final submission

- From the directory containing `code/`, `data/` and the root `README.md`, rerun the fixed and generalised tree programs separately with fresh outputs. Check a height against a direct calculation, plus headers, row counts and replacement on rerun.
- Before final submission, rerun one ordinary and one invalid case for each tree route. Check stderr identifies the intended bad value and that no new result is written for invalid input; an expected exit alone is insufficient.
- Open `results/pound_hill_plot_richness.pdf` alongside its CSV to check plotted values and biological interpretation, not just file presence.
