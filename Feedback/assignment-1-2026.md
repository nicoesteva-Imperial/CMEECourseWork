# Assignment 1 feedback - Nicolas Esteva

**Formative feedback | Rubric 2026.2**

All five FASTA answers matched the independent checks, and the converter sources are concise, quoted and explicit about input and conversion errors. Resolving results from the script's location is useful: the scripts do not depend on the caller being inside code/. The history also records identifiable fixes and restructuring.

The main gap is making the repository as usable as the code. The README is still a single practice-repository sentence, and the required own TSV is absent. Add a small table with an empty field, then write exact repository-root commands, output locations and expected/observed tests. Include bc and any help used.

Four generated temperature outputs are tracked. Some corresponding fresh-output checks were therefore not launched; an existing result cannot show that the current script regenerates it correctly. Untrack the generated outputs, not the original CSVs, add a results ignore rule and repeat those checks from a clean checkout.

Two smaller corrections are worth making while you do this. Q1 should explicitly explain the missing final newlines in the two numbered files, and output-directory creation failure should have a clear diagnostic. Keep the straightforward conversion logic. The next revision should connect the useful implementation to a complete, reproducible submission rather than add more code.

---

## Project structure

Relevant tracked layout (simplified; missing required paths are marked):

```text
README.md
.gitignore
code/  unixPrac1.txt, tabtocsv.sh, csvtospace.sh
data/fasta/  3 required files present
data/temperatures/  4 required files present
data/tab-example.tsv [missing]
results/  4 files tracked
sandbox/  23 files tracked
```

The assessed code and supplied inputs are in the root layout, but the own TSV is missing. Four temperature-conversion outputs and numerous sandbox test files are tracked. The current ignore rules cover temporary files and Python caches, not results or sandbox.

Add the own TSV and untrack generated conversions and disposable tests. Keep the original input CSVs and any durable classwork. Add output/sandbox ignore rules and expand the root README into a guide to the existing structure. The script-anchored results path does not need replacing.

**Assessed snapshot:** `602bddc6e4b08a5f8949ba1d8a99104bbb5f101d`
