# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Research analysis pipeline for evaluating phenotype annotation quality. Compares curator-generated annotations against a Gold Standard (GS) and CharaParser (automated tool) using ontology-based semantic similarity metrics (SimJ, NIC, Partial Precision, Partial Recall).

Three curators (WD, AD, NI) each annotated in two rounds: Naive Round (NR) and Knowledge Round (KR). Python 2 is used for analysis scripts, R for visualization, Java for ontology reasoning.

## Pipeline Execution

### Data Preparation (run once, from `src/`)

`./generateGroupedAncestors.sh` — requires MySQL 5.6, OWLTools, ~80GB heap for Java reasoning. Downloads `AllAncestors_Combinations.txt` from Dropbox (too large for git).

### Main Analysis (from `src/`)

Run intercurator analysis first: `../../Intercurator-Consistency/src/runInterCurator.sh`

Then run `./runGoldStandard.sh`:
```
python computeSim.py          # Semantic similarity (SimJ, NIC)
python compute-PR-PP.py       # Partial Precision / Partial Recall
python stats.py               # Wilcoxon signed-rank tests
Rscript figure3.R             # Figures (requires intercurator results)
Rscript figure4.R
Rscript figure5.R
```

## Architecture

**Data flow:** TSV annotations → ontology reasoning (Java/ELK) → ancestor subsumers in MySQL → grouped ancestor files → pairwise similarity computation (Python) → statistics → figures (R)

**Key directories:**
- `src/` — Python analysis, R visualization, shell pipelines, `reasoning/` Java classes
- `data/` — Input annotations (`AllAnnotations.tsv`), mapped annotations, comparison outputs, JAR dependencies, OWLTools
- `Ontologies/` — OWL files; primary ontology is `MergedOntology_GS_Relations.owl` (merge of UBERON, PATO, BSPO, GO with relation classes)
- `Intercurator-Consistency/` — Parallel subproject for curator-to-curator comparisons (must run before main figures)

**Curator/file naming:** `{NR|KR}--{WD|AD|NI}_{id}.tsv` for curators, `Transformed_CP_*.tsv` for CharaParser, `GS_Dataset.tsv` for Gold Standard.

**Java reasoning classes** (`src/reasoning/`):
- `AddRelationsClasses.java` — adds `inheres_in`, `towards`, etc. relation classes to merged ontology
- `GetAncestors.java` — uses ELK reasoner to extract superclass hierarchies; requires large heap (`-Xmx80G`)

## Dependencies

- **Python 2**: numpy, pandas, scipy, collections
- **R**: ggplot2, reshape2, Rmisc, gridExtra, Hmisc
- **Java**: OWL API 4.1, ELK reasoner, log4j 1.2.17 (JARs in `data/`)
- **MySQL 5.6**: stores ancestor subsumer relationships
- **OWLTools 2015**: ontology merging (binary in `data/OWLTools-2015/`)
