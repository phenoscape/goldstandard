---
name: phenotype-eq-annotation
description: Annotate a single character's states with EQ (Entity-Quality) phenotype annotations using ontology terms.
---

# Phenotype EQ Annotation

Annotate the character states in a given input file with Entity-Quality (EQ)
statements, producing a TSV output file.

## Background

### The EQ Model

Each phenotype annotation is an EQ statement with up to three components:

- **Entity (E):** The anatomical structure (from UBERON, BSPO, or GO)
- **Quality (Q):** The phenotypic property (from PATO)
- **Related Entity (RE):** A second anatomical structure for relational qualities (optional)

A single character state may require **multiple EQ rows** to fully capture its
phenotype. For example, "round and multicuspidate teeth" requires two rows:
one for round, one for multicuspidate.

### Ontology Sources

- **UBERON** — anatomy (structures, bones, organs, regions)
- **PATO** — phenotypic qualities (shape, size, position, presence/absence, etc.)
- **BSPO** — biological spatial terms (regions, surfaces, sides, spatial relations)
- **GO** — Gene Ontology (biological processes only, used rarely)

The ontologies are provided in OBO format in `input/ontologies/`. Search them
using grep or read to find appropriate terms.

### Conventions

1. **Specificity:** Always use the most specific ontology term available
2. **Singular form:** Use `'basihyal tooth'` not `'basihyal teeth'`
3. **Inferred presence:** Do not annotate presence when other qualities imply it
   (e.g., "round frontal bone" only needs `Q: round`, not a separate `Q: present` row)
4. **Absence:** Use `PATO:0000462 absent` / **Presence:** Use `PATO:0000467 present`
5. **Negation:** Use `Q_parent and (PHENOSCAPE:complement_of some Q_specific)`;
   in labels write `not` for `complement_of`
6. **No obsolete terms:** Check `is_obsolete: true` in OBO stanzas — never use these
7. **Skeletal convention:** Assume "bone" unless "cartilage" is explicitly stated
8. **Polymorphic states:** "reduced or absent" gets two separate EQ rows
9. **Unannotatable states:** If a state has no meaningful phenotype description
   (e.g., "State 4"), include it in the output with empty EQ columns
10. **Prefer existing terms:** Strongly prefer terms already in the ontology.
    If no suitable term exists, note it in proposed_terms.txt

### Post-Composition Syntax

Use **OWL Manchester syntax** for post-composed expressions:

```
<genus_ID> and (<relation_ID> some <differentia_ID>)
```

The label form mirrors the structure exactly:

- ID:    `BSPO:0000066 and (BFO:0000050 some UBERON:0002397)`
- Label: `'anterior region' and (part_of some maxilla)`

**Label conventions:**
- Single-word labels are unquoted: `position`, `absent`, `maxilla`
- Multi-word labels are single-quoted: `'anterior region'`, `'increased size'`
- Relation labels in expressions are always unquoted: `part_of some`, `not some`

**Nesting** for spatial refinement (e.g., "anterior process of the maxilla"):
```
<projection_ID> and (BFO:0000050 some (<anterior_region_ID> and (BFO:0000050 some <maxilla_ID>)))
```

### Reference

For detailed annotation patterns (size comparisons, spatial refinement with BSPO,
complementary phenotypes, bilaterally paired structures, etc.), read the full
annotation guide at `input/annotation_guide.md`.

## Inputs

You will be given:
- A character input file path (e.g., `input/characters/char_042.tsv`)
- An output file path for the results
- The ontology files to use (in `input/ontologies/`)

The input file has 5 columns: Character, Character Label, State Symbol, State Label, Paper_PDF.
The `Paper_PDF` column contains the filename of the source publication in
`input/papers/` (e.g., `Conrad_2008.pdf`).

## Procedure

For each state in the input file:

### Step 1: Understand the phenotype

Read the character label and state label. Identify:
- What anatomical structure(s) are involved?
- What quality or property is being described?
- Is there a relationship between two structures?
- Is this presence/absence, shape, size, position, fusion, or another quality type?

If the character or state description is ambiguous or uses unfamiliar
terminology, you may consult the source publication PDF (listed in the
`Paper_PDF` column) at `input/papers/<filename>` for additional context.

### Step 2: Find Entity terms

Search the ontology OBO files for anatomical terms matching the structures
described. Use grep to search by keywords from the character/state description.

```bash
grep -i "name: .*femur" input/ontologies/uberon.obo
```

When a keyword search returns too many or too few results, also search
**synonyms** and **definitions**:

```bash
# Search synonyms — terms often have common names or Latin alternatives
grep -i -B5 'synonym:.*"femoral"' input/ontologies/uberon.obo

# Search definitions — helpful when the common name doesn't match
grep -i -A1 'def:.*long bone' input/ontologies/uberon.obo
```

For each candidate term, read the full `[Term]` stanza and evaluate:

1. **`id:`** — the CURIE you will use (e.g., `UBERON:0001424`)
2. **`name:`** — the primary label (e.g., `ulna`). This is what goes in Label columns
3. **`def:`** — the definition. Read this carefully to confirm the term matches the
   intended anatomical meaning, not just the name. Terms with similar names can
   refer to different structures in different taxa
4. **`synonym:`** — alternate names. Useful for finding terms, but always use the
   `name:` field as the label in output, never a synonym
5. **`is_obsolete: true`** — **never use obsolete terms**. If present, look for a
   `replaced_by:` or `consider:` field pointing to the current term
6. **`is_a:`** and **`relationship:`** — parent terms and relationships. Useful for
   understanding the term's position in the hierarchy and finding more specific
   alternatives

**Choosing between candidate terms:** When multiple terms could fit:
- Prefer the more specific term (a child over a parent)
- Check definitions to distinguish terms with similar names
- Consider the taxonomic scope — some UBERON terms are specific to certain clades

If the entity requires spatial refinement (e.g., "anterior process of the
maxilla"), build a post-composed expression using BSPO region terms and
`BFO:0000050` (part_of). See the Post-Composition Syntax section above.

### Step 3: Find Quality terms

Search `pato.obo` for the quality being described. Common patterns:
- "absent" / "present" → `PATO:0000462` / `PATO:0000467`
- Shape words (round, triangular, etc.) → search PATO by keyword
- Size words (large, small, elongated) → search PATO
- Relational qualities (fused, in contact, separated) → search PATO

**Common PATO terms for quick reference:**

| Quality | ID | When to use |
|---------|----|-------------|
| present | PATO:0000467 | Entity exists |
| absent | PATO:0000462 | Entity does not exist |
| fused with | PATO:0000642 | Two structures merged (relational) |
| separated from | PATO:0001505 | Two structures not touching (relational) |
| in contact with | PATO:0001961 | Two structures touching (relational) |
| attached to | PATO:0001667 | Physical attachment (relational) |
| increased size | PATO:0000586 | Larger than typical |
| decreased size | PATO:0000587 | Smaller than typical |
| increased length | PATO:0000573 | Longer than typical |
| decreased length | PATO:0000574 | Shorter than typical |
| position | PATO:0000140 | General positional quality |
| located in | PATO:0002261 | Located within another structure (relational) |
| anterior to | PATO:0001632 | Positional (relational) |
| posterior to | PATO:0001633 | Positional (relational) |
| shape | PATO:0000052 | General shape (use when no specific child applies) |
| amount | PATO:0000070 | Count/number |

For PATO terms too, read definitions and synonyms to choose the most appropriate
quality. For example, "deep" might mean `increased depth` or `increased width`
depending on anatomical context.

For negation ("not round"), use the complement pattern:
`PATO:0000052 and (PHENOSCAPE:complement_of some PATO:0000411)`

### Step 4: Determine if Related Entity is needed

Relational qualities (fused with, anterior to, in contact with, etc.) require
a Related Entity. Check the quality's definition in PATO — if it describes a
relationship between two things, you need an RE.

### Step 5: Write the EQ row(s)

Produce one or more TSV rows per state. Each row has 10 columns:

```
Character\tCharacter Label\tState Symbol\tState Label\tEntity ID\tEntity Label\tQuality ID\tQuality Label\tRelated Entity ID\tRelated Entity Label
```

**Critical — ID/Label correspondence:**
- Entity ID `UBERON:0001424` must pair with Entity Label `ulna` (the `name:` field
  from the OBO file for that ID)
- For post-composed expressions, every CURIE in the ID expression must map to the
  correct label in the Label expression, maintaining identical structure
- The validation script will check every ID/label pair against the ontology. Any
  mismatch will be flagged as an error

### Step 6: Handle unannotatable states

If a state has no meaningful phenotype description (e.g., "State 4", truncated
text), write a row with the character/state columns filled in and all EQ columns
(5-10) empty.

## Output

Write the annotated TSV to the specified output path. The output file must
include the header row:

```
Character	Character Label	State Symbol	State Label	Entity ID	Entity Label	Quality ID	Quality Label	Related Entity ID	Related Entity Label
```

If you propose any new terms (terms not found in the ontologies), append them to
a `proposed_terms.txt` file alongside the output, with a brief justification:

```
NEW:0001	proposed label	Reason: no existing term for X; closest is UBERON:NNNNNNN 'Y'
```

## Quality Checks

Before writing output, verify:
1. Every term ID you used actually exists in the OBO files
2. Every label matches the `name:` field for that ID exactly (not a synonym)
3. Post-composed expressions use correct Manchester syntax with matching parentheses
4. No obsolete terms are used
5. Relational qualities have a Related Entity; non-relational qualities do not

## Completion Report

After writing the output file, report only: the output file path, the number of
rows written, and any errors or proposed terms. Do not repeat or summarize the
annotations themselves.
