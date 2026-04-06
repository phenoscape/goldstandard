# AI Annotation Workspace

This workspace is for annotating morphological character states with
Entity-Quality (EQ) phenotype annotations using ontology terms.

## Available Skill

- **phenotype-eq-annotation** skill — annotate a single character file with EQ statements using UBERON, PATO, BSPO, and GO

## Key Resources

- `input/characters/` — per-character input files (one character with multiple states in one file)
- `input/ontologies/` — ontology files in OBO format for term lookup
- `input/annotation_guide.md` — detailed reference for annotation patterns and conventions
- `input/papers` — source publications for characters being annotated

## Validation

After producing annotation output, run the structural validator:

```bash
scala-cli run scripts/validate_annotations.scala -- <output_file.tsv>
```

This checks: column count, CURIE existence in ontologies, label correctness,
Manchester syntax parsing, obsolete terms, and relational quality / Related
Entity consistency. Fix all errors before considering the annotation complete.

## Important Constraints

- Do not look at files outside this workspace.
