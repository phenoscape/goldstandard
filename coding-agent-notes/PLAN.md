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

The AI annotation is performed by specialized biocurator agents, each annotating
one character at a time. The `ai-annotation/` directory is a self-contained
workspace with agent definitions, ontologies, input files, and validation tools.

### 1.1 Per-character input files

**[DONE]** Split `data/MappedAnnotations/GS_Dataset.tsv` into 203 per-character
input files, one per character. Each file has 4 columns (Character, Character
Label, State Symbol, State Label) with one row per state — the raw material for
annotation, without EQ columns.

Script: `ai-annotation/scripts/split_characters.py` (reproducible).
Output: `ai-annotation/input/characters/char_001.tsv` through `char_203.tsv`.

### 1.2 Annotation knowledge (three-layer architecture)

**[DONE]** Created a three-layer knowledge architecture:

- **Agent definition** (`ai-annotation/.claude/agents/biocurator.md`) — always
  loaded into context. Contains: EQ formalism, ontology sources, output format,
  post-composition syntax (OWL Manchester), 10 essential conventions, common
  PATO terms table. Distilled to minimize token cost per invocation.

- **Skill definition** (`ai-annotation/.claude/skills/phenotype-eq-annotation.md`)
  — the annotation procedure. 6 steps: understand phenotype → find Entity terms
  (using name, def, synonym fields) → find Quality terms → determine Related
  Entity → write EQ rows → handle unannotatable states. Emphasizes ID/label
  correspondence and synonym/definition-based term selection.

- **Reference file** (`ai-annotation/input/annotation_guide.md`) — full
  annotation guide adapted from the Phenoscape Guide to Character Annotation.
  All examples converted from Phenex caret notation to OWL Manchester syntax.
  Includes: complete relations table (22 relations), PATO attribute categories,
  detailed patterns for size comparisons, negation, spatial refinement, bilaterally
  paired structures, skeletal conventions, etc. Read on-demand by the agent.

**Design rationale:** The agent definition and skill are round-agnostic — they
contain no knowledge of annotation rounds or ontology enhancement. The
appropriate ontology files are provided at invocation time. This cleanly
separates the curation task from the experimental design.

### 1.3 Convert ontologies from OWL to OBO format

**[DONE]** Converted using ROBOT 1.9.8:

| Ontology | Source | Terms | Typedefs | OBO Size |
|----------|--------|-------|----------|----------|
| UBERON | `Ontologies/uberon.owl` | 14,237 | 200 | 12 MB |
| PATO | `Ontologies/pato-simple.owl` | 2,494 | 23 | 545 KB |
| BSPO | `Ontologies/bspo.owl` | 146 | 58 | 71 KB |
| GO | `Ontologies/go.owl.zip` | 43,154 | 10 | 31 MB |
| BestMerged | `Ontologies/BestMerged.owl` | 17,068 | 209 | 11 MB |

Note: BestMerged required `--check false` (duplicate `name` tag on BSPO:0000127
from merging). Output: `ai-annotation/input/ontologies/*.obo`.

### 1.4 ID/label validation script

**[DONE]** Created `ai-annotation/scripts/validate_annotations.py` — a
hallucination detection script that parses OBO files and checks every annotation
TSV for: unknown term IDs, obsolete terms, unbalanced parentheses, missing
ID/label pairs, and label mismatches (ID paired with wrong name).

Validated against Gold Standard: 0 unknown IDs, 0 obsolete terms, 0 structural
errors. 22 false-positive label mismatches from edge cases in the alignment
algorithm (multi-word names containing `and`, relation synonyms).

### 1.5 Split best_merged.obo for round 2

**[TODO]** For round 2 (Merged ontology), need to determine whether to provide
`best_merged.obo` as-is or split it back into per-source ontology files with
curator-added terms included. The merged OBO has ~2,800 additional terms beyond
the base ontologies from curator contributions.

### 1.6 Annotation orchestration

**[TODO]** Two annotation rounds, mirroring the original study's ontology
completeness design:

**Round 1 — Initial Ontologies** (analogous to Naive Round / SCP-Initial):
The AI uses only the base ontologies. Tests annotation with incomplete coverage.

**Round 2 — Merged Ontology** (analogous to Knowledge Round / SCP-Merged):
The AI uses the Merged ontology with curator-added terms. Tests annotation with
complete coverage.

Each round annotates all 203 characters. A driver script dispatches one
biocurator agent per character file and collects results.

**Orchestration approaches:**

- **Claude Agent SDK (Python):** Write a driver script that programmatically
  spawns biocurator agents per character, with batching for rate-limit management.
  The agent definition and skill from `ai-annotation/.claude/` provide the system
  prompt and procedure. This is the recommended approach for 203 files.

- **Claude Code CLI (interactive):** For small batches or debugging, the main
  agent can spawn biocurator sub-agents via the Agent tool within a session.

**Cross-platform portability:** The content layer (input files, ontologies,
annotation guide, validation script, output format) is entirely LLM-agnostic.
To run the same experiment with a different AI system (e.g., Qwen, Codex), only
a thin orchestration adapter is needed — the per-character input/output contract
and the validation script work unchanged. This enables comparing annotation
quality across AI systems.

**Assembly:** After annotation, per-character output files are concatenated into
a single annotation TSV per round:
- `round1-initial/characters/char_*.tsv` → `AI_Initial.tsv`
- `round2-merged/characters/char_*.tsv` → `AI_Merged.tsv`

Directory structure:
```
ai-annotation/
├── .claude/
│   ├── agents/
│   │   └── biocurator.md              # Agent definition (domain knowledge)
│   └── skills/
│       └── phenotype-eq-annotation.md  # Annotation procedure
├── input/
│   ├── characters/
│   │   ├── char_001.tsv               # 203 per-character input files
│   │   └── ...
│   ├── annotation_guide.md            # Full reference (Manchester syntax)
│   └── ontologies/
│       ├── uberon.obo                 # Base anatomy (Initial round)
│       ├── pato.obo                   # Base quality (Initial round)
│       ├── bspo.obo                   # Base spatial (Initial round)
│       ├── go.obo                     # Base biological process (Initial round)
│       └── best_merged.obo           # Merged ontology (Merged round)
├── round1-initial/
│   └── characters/                    # Per-character output (round 1)
├── round2-merged/
│   └── characters/                    # Per-character output (round 2)
└── scripts/
    ├── split_characters.py            # Reproducible input generation
    └── validate_annotations.py        # ID/label hallucination check
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
Phase 0 (reproduce):                                          [DONE]
  0.1  Port all Python scripts to Python 3                    [DONE]
  0.2  Replace MySQL with dict-based lookups                  [DONE]
  0.3  Reconstruct AllAncestors_Combinations.txt              [DONE]
  0.4  Run pipeline, verify results match existing outputs    [DONE]

Phase 1 (prepare AI annotation inputs):
  1.1  Split GS_Dataset.tsv into per-character input files    [DONE]
  1.2  Create annotation knowledge (agent, skill, guide)      [DONE]
  1.3  Convert ontologies from OWL to OBO format              [DONE]
  1.4  Create ID/label validation script                      [DONE]
  1.5  Split best_merged.obo for round 2                      [TODO]
  1.6  Build annotation orchestration / driver script         [TODO]
  --- Run AI annotation: 203 characters × 2 rounds ---

Phase 2 (analysis):
  2.1  Assemble + validate per-character outputs into TSVs
  2.2  Copy AI annotation TSVs to data/MappedAnnotations/
  2.3  Handle any proposed terms (if AI proposed new terms)
  2.4  Run populateGroupedAncestors.py on both AI files
  2.5  Rebuild AllAncestors_Combinations.txt with AI data
  2.6  Add AI comparisons to computeSim.py, run it
  2.7  Add AI comparisons to compute-PR-PP.py, run it
  2.8  Add AI comparisons to stats.py, run it
  2.9  Update/create R figure scripts, generate new figures
```

---

## Decisions Made

- **Python version:** Port to Python 3 (mechanical changes, low risk)
- **MySQL:** Replace with in-memory Python dict (eliminates dependency)
- **Post-composition:** AI agent should produce post-composed OWL Manchester
  syntax expressions to match what human curators did (not Phenex caret notation)
- **Ontology format for AI:** Convert OWL to OBO (text-friendly for agent tools)
- **AI annotation workspace:** Self-contained `ai-annotation/` directory with
  its own `.claude/` structure, so it can serve as an independent project
- **Three-layer knowledge:** Agent definition (always loaded, distilled rules),
  skill (procedure), reference guide (on-demand). Agent and skill are
  round-agnostic — ontologies provided at invocation time
- **Per-character granularity:** One input file and one output file per character
  (203 total). Enables parallelism, isolated failure, easy review/redo, and
  cross-platform portability
- **Dual ID/label output:** Every term appears as both CURIE and primary label.
  Validation script checks correspondence against OBO files (hallucination check)
- **Ontology versions:** Two rounds — Initial ontologies (base uberon/pato/bspo/go)
  and Merged ontology (BestMerged.owl with all curator-added terms). This parallels
  the original study's ontology completeness analysis
- **New term proposals:** AI may propose new terms when no suitable existing term
  exists, but should strongly prefer existing terms. Proposals logged separately
- **Cross-platform design:** Content layer (inputs, ontologies, guide, validation,
  output format) is LLM-agnostic. Only the orchestration adapter is
  platform-specific. This enables running the same experiment with different AI
  systems (Claude, Qwen, Codex, etc.) and comparing annotation quality

## Open Questions

1. **How many AI annotation runs per round?** One run, or multiple (e.g., different
   models, different prompting strategies, multiple runs for consistency)?
2. **IC corpus decision:** Include AI in the corpus (methodologically correct but
   changes all scores, requiring full recomputation) or keep original corpus
   (simpler, preserves original scores)?
3. **Cross-platform comparison:** Run the same annotation task with multiple AI
   systems? Would strengthen the analysis but multiplies the work.
