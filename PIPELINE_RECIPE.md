# Pipeline Recipe: Adding New AI Agent Annotation Sets

This documents the exact steps to integrate new AI agent annotation rounds
into the Gold Standard semantic similarity pipeline, as performed on 2026-04-07
to add Round 2 annotations (claude-4.6-high R2 and gpt-5.4-xhigh R2).

All commands are run from `src/` unless otherwise noted.

---

## Prerequisites

- Java 21 (or compatible), with enough system RAM for `-Xmx40G`
- `uv` (Python runner)
- Per-character annotation files in `test-output/round-N/<agent-name>/char_001.tsv` through `char_203.tsv`
- Fixed ontology already in place (`Ontologies/MergedOntology_GS_Relations.owl` with disjointness axioms removed)

---

## Step 1: Merge per-character files into MappedAnnotations

Edit `src/merge_ai_annotations.py` to add new source directories and output
filenames in the `sources` list. The naming convention is:

```python
sources = [
    # Round 1
    ("test-output/round-1/claude-4.6-high", "AI--Claude_46.tsv"),
    ("test-output/round-1/gpt-5.4-high", "AI--GPT_54.tsv"),
    # Round 2
    ("test-output/round-2/claude-4.6-high", "AI--Claude_46_R2.tsv"),
    ("test-output/round-2/gpt-5.4-xhigh", "AI--GPT_54_R2.tsv"),
]
```

Run:

```bash
uv run python merge_ai_annotations.py
```

This reads all `char_*.tsv` files from each directory, fixes column count
issues (padding short rows to 10 columns, truncating long rows), and writes
merged TSVs into `data/MappedAnnotations/`.

---

## Step 2: Check for missing terms in the subsumers table

New annotations may use ontology terms that no previous annotator used. These
terms won't have ancestors in `data/AnnotationSubsumers_Relations.txt`, which
means their similarity scores will be artificially low.

To check, extract all unique atomic ontology IDs (UBERON, PATO, BSPO, etc.)
from the new annotation files and compare against the first column of the
subsumers file. Ignore relation IDs (BFO\_, RO\_) which are used in expression
syntax, not as standalone class terms.

If any real class terms are missing, you must re-run GetAncestors (Step 3).
If all terms are already covered, skip to Step 4.

---

## Step 3: Re-run GetAncestors (only if missing terms found)

### 3a. Regenerate AllAnnotations.tsv

Concatenate a header line plus all annotation files (no headers) from
`data/MappedAnnotations/`:

```bash
cd /path/to/goldstandard
{
  head -1 data/MappedAnnotations/GS_Dataset.tsv
  for f in data/MappedAnnotations/*.tsv; do
    tail -n +2 "$f"
  done
} > data/AllAnnotations.tsv
```

### 3b. Compile GetAncestors

```bash
cd src
javac -cp "../data/org.semanticweb.owl.owlapi-4.1.jar:../data/elk-owlapi.jar:../data/log4j-1.2.17.jar:." \
  reasoning/DLQueryEngine.java reasoning/DLQueryPrinter.java reasoning/GetAncestors.java
```

Warnings about unchecked operations are expected and harmless.

### 3c. Run GetAncestors

```bash
java -Xmx40G \
  -cp "../data/org.semanticweb.owl.owlapi-4.1.jar:../data/elk-owlapi.jar:../data/log4j-1.2.17.jar:." \
  reasoning.GetAncestors
```

This loads `Ontologies/MergedOntology_GS_Relations.owl` (~1.3 GB), classifies
it with ELK (~17 GB RSS), then processes all expressions and atomic IDs from
`data/AllAnnotations.tsv`. Writes output to
`data/AnnotationSubsumers_Relations.txt`.

- Runtime: ~15 minutes on a 12-core machine with 64 GB RAM
- Expect ~40 parse errors for AI expressions using `part_of` instead of
  `BFO_0000050` — these are logged and skipped
- "No Ancestors Found" messages for top-level terms (e.g., UBERON\_0001062)
  are normal — they only have owl:Thing above them

### 3d. Deduplicate the subsumers file

GetAncestors produces duplicates (same atomic IDs processed multiple times
from different annotation lines):

```bash
cd /path/to/goldstandard
sort -u data/AnnotationSubsumers_Relations.txt > data/AnnotationSubsumers_Relations.txt.dedup
mv data/AnnotationSubsumers_Relations.txt.dedup data/AnnotationSubsumers_Relations.txt
```

### 3e. Verify coverage

Re-run the missing terms check from Step 2 to confirm new terms are covered.
The only expected remaining gaps are `UBERON_0010008` (hangs) and any
malformed IDs in agent annotations.

---

## Step 4: Regenerate grouped ancestors for all annotation files

Clear the AllAncestors\_Combinations.txt file first (populateGroupedAncestors
appends to it):

```bash
> ../data/AllAncestors_Combinations.txt
```

Then run `populateGroupedAncestors.py` for every file in MappedAnnotations.
Each run produces a `Classes-*.tsv` and `Ancestors-*.tsv` in `data/` and
appends to `AllAncestors_Combinations.txt`:

```bash
cd src
for f in ../data/MappedAnnotations/*.tsv; do
  fname=$(basename "$f")
  prefix="EQ_"
  if [[ "$fname" == AI--* ]]; then
    prefix="AI_EQ_"
  elif [[ "$fname" == Transformed_* ]]; then
    prefix="CP_EQ_"
  fi
  echo "Processing: $fname"
  uv run python populateGroupedAncestors.py "$f" 1 unused "$prefix"
done
```

The `prefix` argument sets the EQ number prefix in `Classes-*.tsv` — it must
be consistent across runs but the exact value doesn't affect similarity scores.

---

## Step 5: Update analysis scripts

### computeSim.py

Add `compute()` calls in `main()` for each new annotation file vs GS:

```python
compute("../data/MappedAnnotations/AI--Claude_46_R2.tsv",
        "../data/MappedAnnotations/GS_Dataset.tsv", 1, ic_dict)
compute("../data/MappedAnnotations/AI--GPT_54_R2.tsv",
        "../data/MappedAnnotations/GS_Dataset.tsv", 1, ic_dict)
```

### compute-PR-PP.py

Add lines in `AI_GS()` for the new PerEQ files (filenames are derived
automatically by computeSim.py):

```python
infile="../data/CombinedComparisons/PerEQ_AI--Claude_46_R2--GS_Dataset.tsv"
simjmeanpp,simjmeanpr=compute(infile)
print("Claude R2 vs GS PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3))

infile="../data/CombinedComparisons/PerEQ_AI--GPT_54_R2--GS_Dataset.tsv"
simjmeanpp,simjmeanpr=compute(infile)
print("GPT R2 vs GS PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3))
```

---

## Step 6: Run the analysis

```bash
cd src
uv run python computeSim.py
uv run python compute-PR-PP.py
```

`computeSim.py` outputs Mean SimJ and Mean NIC for each comparison.
`compute-PR-PP.py` outputs Partial Precision and Partial Recall.

Results files are written to `data/CombinedComparisons/`.

---

## Notes

- **Why re-run all 18 files in Step 4, not just the new ones?**
  AllAncestors\_Combinations.txt is a corpus used for IC (information content)
  computation. Adding new annotations changes the corpus, so IC values change.
  All files must be regenerated from the same corpus for consistent scoring.

- **The composed expression lookup in populateGroupedAncestors is a no-op.**
  `getExpression()` builds expressions with `inheres_in`/`towards` but the
  subsumers file uses OWL property IRIs. The lookup via `getqueryresult()`
  always returns empty. The actual ancestor computation works by decomposing
  annotations into atomic E1/Q1/E2 terms, looking up each in subsumers, and
  computing cross-product ancestor combinations. This is consistent across
  all annotators.

- **Known limitations:**
  - AI expressions using `part_of` instead of `BFO:0000050` in composed
    related entities are unparseable by the DLQueryEngine and get skipped
    as nested expressions (their atomic components are still processed).
