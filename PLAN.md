# Plan: Extending Gold Standard Analysis with AI Agent Annotations

## Goal

Re-annotate the same 203 characters (463 character states) using AI agents, then
run the full analysis pipeline to compare AI annotations against the Gold Standard,
human curators, and CharaParser (SCP). Produce updated figures and statistics.

---

## Phase 0: Reproduce Original Results

Before extending, verify the pipeline works by reproducing existing results.

### 0.1 Port Python scripts to Python 3

All 10 Python files need mechanical changes. No complex logic changes required.

**Changes needed across all files:**
- `print "x"` → `print("x")` (~58 instances across 7 files)
- `.iteritems()` → `.items()` (2 instances in `src/compute-PR-PP.py`)
- `file.next()` → `next(file)` (1 instance in `src/compute-PR-PP.py`)
- Fix mixed tabs/spaces in `src/populateGroupedAncestors.py` lines 217-221
  and `Intercurator-Consistency/src/populategroupedancestors.py` lines 219-223

**Files to modify (src/):**
1. `computeSim.py` — print statements only
2. `compute-PR-PP.py` — print, iteritems, file.next
3. `stats.py` — print statements only
4. `convertUBERONTEMP.py` — one print statement
5. `populateGroupedAncestors.py` — print, MySQLdb removal, indentation fix

**Files to modify (Intercurator-Consistency/src/):**
6. `computeSim.py` — already Python 3 compatible (no changes)
7. `getIC-combination.py` — one print statement
8. `populategroupedancestors.py` — MySQLdb removal, indentation fix
9. `stats.py` — print statements only
10. `transform.py` — already Python 3 compatible (no changes)

### 0.2 Replace MySQL with in-memory Python dict

Only 2 files use MySQL: the two `populateGroupedAncestors.py` variants.

**Approach:** Load `AnnotationSubsumers_Relations.txt` (574K lines, tab-delimited
`term\tancestor`) into a `dict[str, set[str]]` at startup. Replace the
`MySQLdb.connect()` + `SELECT ancestor FROM ... WHERE term=...` with a simple
dict lookup. This eliminates the MySQL dependency entirely.

The replacement code is roughly:
```python
def load_subsumers(filepath):
    subsumers = {}
    with open(filepath) as f:
        for line in f:
            term, ancestor = line.strip().split("\t")
            subsumers.setdefault(term, set()).add(ancestor)
    return subsumers
```

Then replace each `cursor.execute(...)` / `cursor.fetchall()` with `subsumers.get(term, set())`.

### 0.3 Reconstruct AllAncestors_Combinations.txt

This file is needed by `computeSim.py` for IC (Information Content) computation.
It doesn't currently exist on disk but can be reconstructed by unzipping and
concatenating all 14 `Ancestors-*.tsv.zip` files:

```bash
cd data
for z in Ancestors-*.tsv.zip; do unzip -p "$z"; done > AllAncestors_Combinations.txt
```

**Note:** Verify the reconstructed file produces the same IC values as the original
by comparing computed similarity scores against existing results in
`data/CombinedComparisons/`.

### 0.4 Verify reproduction

Run the ported pipeline against existing data and compare outputs to the existing
`data/CombinedComparisons/` results. Scores should match exactly (or within
floating-point tolerance).

```bash
cd src
python3 computeSim.py
python3 compute-PR-PP.py
python3 stats.py
```

Compare output files against the existing ones before overwriting.

---

## Phase 1: Prepare Inputs for AI Annotation

The AI annotation itself will be performed by a separate coding agent in its own
directory. This phase prepares the input files that agent will need.

### 1.1 Extract character states list

Create a TSV file containing only the character/state information (without EQ
annotations) that the AI agent needs to annotate. Extract from
`data/MappedAnnotations/GS_Dataset.tsv`, keeping only unique combinations of:
- Character number
- Character label
- State symbol
- State label

Output: `ai-annotation/input/character_states.tsv`

### 1.2 Create annotation format specification

Write a specification document for the coding agent describing:
- The EQ (Entity-Quality) annotation model and its purpose
- Column schema (10 columns: Character, Character Label, State Symbol, State Label,
  Entity ID, Entity Label, Quality ID, Quality Label, Related Entity ID,
  Related Entity Label)
- That multiple EQ rows per character state are expected
- Post-composition syntax for complex expressions:
  `UBERON:X and (BFO:0000050 some UBERON:Y)` with corresponding labels
  `'term X' and (part_of some 'term Y')`
- The relations used: `part_of` (BFO:0000050), `inheres_in`, `towards`, etc.
- Conventions: labels are single-quoted, IDs use CURIE format (PREFIX:NUMBER)
- Example annotations (a representative sample from the Gold Standard showing
  simple and post-composed annotations)
- Instructions on proposing new terms: the agent should strongly prefer existing
  ontology terms, but may propose new terms when no suitable term exists. Proposed
  terms should be clearly marked (e.g., with a `NEW:` prefix or in a separate log)
  so they can be reviewed.

Output: `ai-annotation/input/annotation_spec.md`

### 1.3 Convert ontologies from OWL to OBO format

OBO is a plain-text format with `[Term]` stanzas that is much easier for AI
agents to search with standard text tools (grep, etc.) than OWL/XML.

Convert the four ontologies used in the analysis:
- `Ontologies/uberon.owl` → `ai-annotation/input/ontologies/uberon.obo`
- `Ontologies/pato-simple.owl` → `ai-annotation/input/ontologies/pato.obo`
- `Ontologies/bspo.owl` → `ai-annotation/input/ontologies/bspo.obo`
- `Ontologies/go.owl` → `ai-annotation/input/ontologies/go.obo`

Use ROBOT or OWLTools for conversion:
```bash
robot convert --input Ontologies/uberon.owl --output ai-annotation/input/ontologies/uberon.obo
```

Note: Some of these ontologies may already have OBO versions available from their
upstream sources, which could be used instead of converting.

For the Merged round, also convert `BestMerged.owl` (or build a merged OBO that
includes the additional terms from all curators):
- `Ontologies/BestMerged.owl` → `ai-annotation/input/ontologies/best_merged.obo`

### 1.4 Set up the annotation directory

Two annotation rounds, mirroring the original study's ontology completeness design:

**Round 1 — Initial Ontologies** (analogous to Naive Round / SCP-Initial):
The AI uses only the base ontologies that curators started with. Tests annotation
ability given incomplete ontology coverage.

**Round 2 — Merged Ontology** (analogous to Knowledge Round / SCP-Merged):
The AI uses the Merged ontology containing all curator-added terms. Tests
annotation ability given complete ontology coverage.

In both rounds, the AI may propose new terms when no suitable existing term can
be found, but should strongly prefer existing terms. Proposed terms will be logged
separately for review.

Directory structure:
```
ai-annotation/
├── input/
│   ├── character_states.tsv          # What to annotate (shared across rounds)
│   ├── annotation_spec.md            # How to annotate (shared across rounds)
│   └── ontologies/
│       ├── uberon.obo                # Base anatomy ontology (Initial)
│       ├── pato.obo                  # Base quality ontology (Initial)
│       ├── bspo.obo                  # Base spatial ontology (Initial)
│       ├── go.obo                    # Base biological process ontology (Initial)
│       └── best_merged.obo           # Merged ontology (all curator terms added)
├── round1-initial/                   # AI annotates with Initial ontologies only
│   ├── AI_Initial.tsv                # Output annotations
│   └── proposed_terms.txt            # Any new terms the AI proposed
└── round2-merged/                    # AI annotates with Merged ontology
    ├── AI_Merged.tsv                 # Output annotations
    └── proposed_terms.txt            # Any new terms the AI proposed
```

---

## Phase 2: Process AI Annotations Through the Pipeline

### 2.1 Copy AI annotation files into the pipeline

Copy completed annotation files from the annotation directory into the pipeline:
```bash
cp ai-annotation/round1-initial/AI_Initial.tsv data/MappedAnnotations/
cp ai-annotation/round2-merged/AI_Merged.tsv data/MappedAnnotations/
```

### 2.2 Handle proposed terms (if any)

If the AI proposed new terms (especially in the Initial round), these need to be
added to the reasoning ontology before ancestor computation will work for those
terms. Options:
- Add proposed terms to a copy of the ontology and re-run the Java reasoning
  pipeline (heavy — requires OWLTools + ELK + 80GB heap)
- Or, if few terms were proposed, manually map them to the closest existing terms
  and note this in the analysis

This step may be skippable if the AI used only existing terms.

### 2.3 Generate grouped ancestors for AI annotations

Run the (now Python 3, dict-based) `populateGroupedAncestors.py` on each AI
annotation file:

```bash
cd src
python3 populateGroupedAncestors.py ../data/MappedAnnotations/AI_Initial.tsv 1 unused C_EQ_
python3 populateGroupedAncestors.py ../data/MappedAnnotations/AI_Merged.tsv 1 unused C_EQ_
```

Note: The third argument (table name) becomes vestigial after the MySQL
replacement — kept for CLI compatibility.

This produces:
- `data/Classes-AI_Initial.tsv` + `data/Ancestors-AI_Initial.tsv`
- `data/Classes-AI_Merged.tsv` + `data/Ancestors-AI_Merged.tsv`

### 2.4 Rebuild AllAncestors_Combinations.txt

The IC corpus should include the AI annotations for fair comparison. Concatenate
all existing Ancestors files plus the new AI ones:

```bash
cd data
for z in Ancestors-*.tsv.zip; do unzip -p "$z"; done > AllAncestors_Combinations.txt
cat Ancestors-AI_Initial.tsv >> AllAncestors_Combinations.txt
cat Ancestors-AI_Merged.tsv >> AllAncestors_Combinations.txt
```

**Important consideration:** Adding AI annotations to the corpus changes IC values
for ALL terms, meaning all comparison scores will shift slightly. Two options:

- **Option A (recommended for paper):** Include AI in the corpus. This is the
  methodologically correct approach — all annotation sources contribute to IC.
  All comparisons must be recomputed.
- **Option B (for quick validation):** Keep the original corpus. AI scores are
  computed but not strictly comparable to the published results.

### 2.5 Add AI comparisons to computeSim.py

Add new `compute()` calls in the `main()` function of `src/computeSim.py`:

```python
# AI (Initial ontology) vs Gold Standard
compute("../data/MappedAnnotations/AI_Initial.tsv",
        "../data/MappedAnnotations/GS_Dataset.tsv", 1, ic_dict)

# AI (Merged ontology) vs Gold Standard
compute("../data/MappedAnnotations/AI_Merged.tsv",
        "../data/MappedAnnotations/GS_Dataset.tsv", 1, ic_dict)

# AI (Initial) vs Curators - Naive Round
compute("../data/MappedAnnotations/AI_Initial.tsv",
        "../data/MappedAnnotations/NR--WD_38484.tsv", 1, ic_dict)
compute("../data/MappedAnnotations/AI_Initial.tsv",
        "../data/MappedAnnotations/NR--AD_40674.tsv", 1, ic_dict)
compute("../data/MappedAnnotations/AI_Initial.tsv",
        "../data/MappedAnnotations/NR--NI_40676.tsv", 1, ic_dict)

# AI (Merged) vs Curators - Knowledge Round
compute("../data/MappedAnnotations/AI_Merged.tsv",
        "../data/MappedAnnotations/KR--NI_40716.tsv", 1, ic_dict)
compute("../data/MappedAnnotations/AI_Merged.tsv",
        "../data/MappedAnnotations/KR--WD_40717.tsv", 1, ic_dict)
compute("../data/MappedAnnotations/AI_Merged.tsv",
        "../data/MappedAnnotations/KR--AD_40718.tsv", 1, ic_dict)

# AI vs CharaParser (matched ontology conditions)
compute("../data/MappedAnnotations/AI_Merged.tsv",
        "../data/MappedAnnotations/Transformed_CP_best.tsv", 1, ic_dict)
```

The `compute()` function generates output file names automatically from input
file names, so no further changes are needed for output handling.

### 2.6 Run compute-PR-PP.py

Add corresponding entries in `src/compute-PR-PP.py` to compute Partial Precision
and Partial Recall for the new AI comparison pairs. The script currently has
hardcoded file lists — extend them with the AI comparison files.

### 2.7 Run stats.py

Add statistical tests for AI annotations:
- AI-Initial vs GS compared to Curator-Naive vs GS (matched ontology condition)
- AI-Merged vs GS compared to Curator-Knowledge vs GS (matched ontology condition)
- AI-Merged vs GS compared to SCP-Merged vs GS (does AI outperform CharaParser?)
- AI-Initial vs GS compared to AI-Merged vs GS (effect of ontology completeness
  on AI, paralleling the SCP ontology completeness analysis)

### 2.8 Update R figure scripts

Create new figure scripts (or extend existing ones) to include AI results:
- **New figure:** AI vs GS similarity (Initial vs Merged), analogous to Figure 4
  which showed the effect of ontology completeness on SCP
- **Extended figure3:** Add AI violin plots alongside curator results
- **Extended figure5:** Add AI data points alongside inter-curator and SCP
  consistency scores, showing where AI falls relative to humans and SCP

---

## Phase 3: Execution Order Summary

```
Phase 0 (reproduce):
  0.1  Port all Python scripts to Python 3
  0.2  Replace MySQL with dict-based lookups in populateGroupedAncestors.py
  0.3  Reconstruct AllAncestors_Combinations.txt from zip files
  0.4  Run pipeline, verify results match existing outputs

Phase 1 (prepare AI annotation inputs):
  1.1  Extract character/state list from GS_Dataset.tsv
  1.2  Write annotation format specification document
  1.3  Convert ontologies from OWL to OBO format (Initial + Merged)
  1.4  Set up ai-annotation/ directory with round1-initial/ and round2-merged/
  --- User runs AI annotation separately in two rounds ---

Phase 2 (analysis):
  2.1  Copy AI annotation TSVs to data/MappedAnnotations/
  2.2  Handle any proposed terms (if AI proposed new ontology terms)
  2.3  Run populateGroupedAncestors.py on both AI annotation files
  2.4  Rebuild AllAncestors_Combinations.txt with AI data
  2.5  Add AI comparisons to computeSim.py, run it
  2.6  Add AI comparisons to compute-PR-PP.py, run it
  2.7  Add AI comparisons to stats.py, run it
  2.8  Update/create R figure scripts, generate new figures
```

---

## Decisions Made

- **Python version:** Port to Python 3 (mechanical changes, low risk)
- **MySQL:** Replace with in-memory Python dict (eliminates dependency)
- **Post-composition:** AI agent should produce post-composed OWL expressions
  to match what human curators did
- **Ontology format for AI:** Convert OWL to OBO (text-friendly for agent tools)
- **AI annotation process:** User will run separately in `ai-annotation/` directory
- **Ontology versions:** Two rounds — Initial ontologies (base uberon/pato/bspo/go)
  and Merged ontology (BestMerged.owl with all curator-added terms). This parallels
  the original study's ontology completeness analysis.
- **New term proposals:** AI may propose new terms when no suitable existing term
  exists, but should strongly prefer existing terms. Proposals logged separately.

## Open Questions

1. **How many AI annotation runs per round?** One run, or multiple (e.g., different
   models, different prompting strategies, multiple runs for consistency)?
2. **IC corpus decision:** Include AI in the corpus (methodologically correct but
   changes all scores, requiring full recomputation) or keep original corpus
   (simpler, preserves original scores)?
