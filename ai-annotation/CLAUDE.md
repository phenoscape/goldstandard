# AI Annotation Workspace

This workspace is for annotating morphological character states with
Entity-Quality (EQ) phenotype annotations using ontology terms.

## Available Agent and Skill

- **biocurator** agent — specialized for EQ annotation using UBERON, PATO, BSPO, and GO
- **phenotype-eq-annotation** skill — procedure for annotating a single character file

## Key Resources

- `input/characters/` — per-character input files (one per character, 203 total)
- `input/ontologies/` — ontology files in OBO format for term lookup
- `input/annotation_guide.md` — detailed reference for annotation patterns and conventions

## Important Constraints

- Do not look at files outside this workspace.
