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
using grep or read to find appropriate terms. Terms may use various OBO ID prefixes in addition to the main namespace in a given ontology (e.g., terms with temporary identifiers).

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

- ID: `BSPO:0000066 and (BFO:0000050 some UBERON:0002397)`
- Label: `'anterior region' and (part_of some maxilla)`

**Label conventions:**

- Single-word labels are unquoted: `position`, `absent`, `maxilla`
- Multi-word labels, for either class terms or relation terms are single-quoted: `'anterior region'`, `'increased size'`
- Single terms from the ontology that are not post-composed follow the same quoting conventions

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

**Read the source publication.** Character descriptions are often abbreviations
that require context about the study organism, anatomical system, and taxonomic
scope. Before annotating, read the publication PDF (listed in the `Paper_PDF`
column) at `input/papers/<filename>`. Pay attention to:

- The methods section for what organism group and anatomical system is studied
- Figures and figure legends showing the structures being described
- The character list introduction explaining any conventions used
- Any character state descriptions that elaborate on the terse labels

Many annotation errors trace to not understanding what the character is asking
about. A few minutes reading the paper prevents wrong entity/quality choices.

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

**Term search hierarchy — before creating any TEMP ID, exhaust these in order:**

1. **Exact label:** `grep -i "^name: .*keyword" input/ontologies/*.obo`
2. **Synonyms:** `grep -i -B5 'synonym:.*"keyword"' input/ontologies/*.obo`
3. **Alternate spellings:** Try `-ate`/`-ous`/`-iform` suffixes, hyphenated vs
   unhyphenated, singular vs plural (e.g., `unicuspid` → `unicuspidate`,
   `boomerang-shaped` → `boomerang shaped`)
4. **Definition search:** `grep -i -A1 'def:.*keyword' input/ontologies/*.obo`
5. **Post-compose from existing terms:** e.g., `'sesamoid bone' and (part_of some
'tarsal skeleton')` instead of a TEMP `intertarsal sesamoid`
6. **Most specific subsuming parent + relation:** If no exact term exists, use the
   most specific parent that subsumes the intended concept, post-composed with
   relations if needed. E.g., `'vertebral element' and (posterior_to some
'vertebral bone 1')` for "postatlantal vertebra".
7. **TEMP ID (absolute last resort):** Only after exhausting all above options.

**Note about approximation:** A most-specific subsuming parent term
can produce a produce meaningful annotation. A sibling or neighbor term is WORSE than a parent
because it may introduce incorrect ancestors. A TEMP ID is worst of all — it
adds no semantics because it has no ontological relationships.

**Choosing between candidate terms:** When multiple terms could fit:

- Prefer the more specific term (a child over a parent)
- Check definitions to distinguish terms with similar names
- Consider the taxonomic scope — some UBERON terms are specific to certain clades

**Surface features as qualities, not entities:** When a character describes a
surface feature or texture (pitting, tuberculation, tooth-like projections,
ridging), model it as a **quality of the bearer entity**, not as a separate
sub-entity that is present/absent. Examples:

- "neurovascular pitting on beak" → Entity: `beak`, Quality: `foveate`
- "toothed plate of clasper" → Entity: `clasper`, Quality: `dentated`
- "basal bulb on hair shaft" → Entity: `'proximal region' and (part_of some 'hair shaft')`, Quality: `swollen`

**Entity specification with part_of:** If the entity requires spatial refinement
(e.g., "anterior process of the maxilla"), build a post-composed expression
using BSPO region terms and `BFO:0000050` (part_of). See the Post-Composition
Syntax section above.

**Avoid redundant post-composition.** If a relationship is already implied by
an ontology term's classification, do not re-state it. For example, `frontal
bone` is already classified as `part_of some cranium` in UBERON — writing
`'frontal bone' and (part_of some cranium)` adds nothing. Post-compose only
when the context is not already captured by the chosen term. Contrast this with
a generic term like `'anatomical projection'`, which could refer to a process
on many different bones — here, `'anatomical projection' and (part_of some
maxilla)` is informative because the ontology term alone does not specify which
bone bears the projection.

**Spatial post-composition checklist:** When a character includes spatial
qualifiers, they MUST be reflected in the Entity post-composition. The examples
below show the **Label** form; the ID form mirrors the structure exactly with
CURIEs in place of labels (see Post-Composition Syntax above).

- **"in female/male"** → add `part_of some 'female organism'` /
  `part_of some 'male organism'`
- **"left/right X"** or fusion of paired structures → use
  `in_left_side_of` / `in_right_side_of` with `'whole organism'` or the
  appropriate parent structure
- **"vertebra 1 and 2"** → separate rows with `part_of` each specific vertebra
- **"dorsal margin of X"** → `'dorsal margin' and (part_of some X)`,
  not just `X`
- **"anterior region of X"** → `'anterior region' and (part_of some X)`
- **Two-level nesting** (e.g., "fossa on dorsal surface of phalanx") →
  `'bone fossa' and (part_of some ('dorsal region' and (part_of some phalanx)))`

**Relation choice guide:** Do not default to `part_of` for all post-compositions.
Choose the biologically appropriate relation:

- `attaches_to` (RO:0002371) — teeth on jaws/toothplates, ligaments on bones
- `adjacent_to` (RO:0002220) — proximity (replacement tooth near target position)
- `connected_to` (RO:0002170) — articular connections between bones
- `connects` (RO:0002176) — ternary: joint connects bone1, joint connects bone2
- `continuous_with` (RO:0002150) — structures sharing a boundary without separation
- `posterior_to` (BSPO:0000099) / `anterior_to` (BSPO:0000096) — serial homologs
  (vertebral position relative to another vertebra)
- `part_of` (BFO:0000050) — ONLY for true mereological containment (a structure
  physically contained within another)

**OBO Typedef relation IDs:** OBO Typedef stanzas define relations with shortname
IDs (e.g., `part_of`, `attaches_to`). Many have an `xref:` field pointing to a
standard CURIE (e.g., `xref: BFO:0000050`). In annotation output, **always use
the CURIE from the xref**, never the shortname. This applies only to relations,
not class terms. The relations table in `input/annotation_guide.md` lists the
correct CURIEs for each relation.

### Step 3: Find Quality terms

Search `pato.obo` for the quality being described. Common patterns:

- "absent" / "present" → `PATO:0000462` / `PATO:0000467`
- Shape words (round, triangular, etc.) → search PATO by keyword
- Size words (large, small, elongated) → search PATO
- Relational qualities (fused, in contact, separated) → search PATO

**Common PATO terms for quick reference:**

| Quality          | ID           | When to use                                        |
| ---------------- | ------------ | -------------------------------------------------- |
| present          | PATO:0000467 | Entity exists                                      |
| absent           | PATO:0000462 | Entity does not exist                              |
| fused with       | PATO:0000642 | Two structures merged (relational)                 |
| separated from   | PATO:0001505 | Two structures not touching (relational)           |
| in contact with  | PATO:0001961 | Two structures touching (relational)               |
| attached to      | PATO:0001667 | Physical attachment (relational)                   |
| increased size   | PATO:0000586 | Larger than typical                                |
| decreased size   | PATO:0000587 | Smaller than typical                               |
| increased length | PATO:0000573 | Longer than typical                                |
| decreased length | PATO:0000574 | Shorter than typical                               |
| position         | PATO:0000140 | General positional quality                         |
| located in       | PATO:0002261 | Located within another structure (relational)      |
| anterior to      | PATO:0001632 | Positional (relational)                            |
| posterior to     | PATO:0001633 | Positional (relational)                            |
| shape            | PATO:0000052 | General shape (use when no specific child applies) |
| amount           | PATO:0000070 | Count/number                                       |

For PATO terms too, read definitions and synonyms to choose the most appropriate
quality. For example, "deep" might mean `increased depth` or `increased width`
depending on anatomical context.

**Relational qualities vs present/absent:** When a character describes a
_relationship between two structures_ (fusion, contact, attachment,
articulation), use the appropriate relational quality with a Related Entity.
**Never** model a relationship as present/absent of a combined structure.

- "sacral vertebra attached to ilium" → Q: `attached to`, RE: `ilium`
  (NOT: Entity: `sacral vertebra`, Q: `present`)
- "left and right puboischiadic bars fused" → Q: `fused with`, RE: right bar
  (NOT: Entity: `fused puboischiadic bar`, Q: `present`)

Use `PATO:0000462 absent` / `PATO:0000467 present` **only** when an entire
discrete anatomical structure is truly present or absent.

**Complement_of negation pattern:** When a character has states like "quality X
present" / "quality X absent" where X is a specific quality (not a structure):

- The "present" state uses the specific quality directly
- The "absent" state uses: `Q_PARENT and (PHENOSCAPE:complement_of some Q_SPECIFIC)`
- In the Label column, write `not` for `complement_of`

Examples (showing Label form):

| State                                    | Quality ID                                                      | Quality Label                              |
| ---------------------------------------- | --------------------------------------------------------------- | ------------------------------------------ |
| "extends beyond caudal peduncle"         | `PATO:0002464`                                                  | `'extends beyond'`                         |
| "does not extend beyond caudal peduncle" | `PATO:0000140 and (PHENOSCAPE:complement_of some PATO:0002464)` | `position and (not some 'extends beyond')` |
| "semicircular pelvic plate"              | `PATO:0000411`                                                  | `semicircular`                             |
| "not semicircular pelvic plate"          | `PATO:0000052 and (PHENOSCAPE:complement_of some PATO:0000411)` | `shape and (not some semicircular)`        |

Reserve simple `PATO:0000462 absent` only for when an entire anatomical
structure is absent, not for the absence of a quality.

**Magnitude-relative-to pattern:** When a character explicitly compares two
measurable properties (e.g., "longer than wide", "height exceeds length"), use
the `increased_in_magnitude_relative_to` pattern to encode the comparison
target. Do NOT substitute a simpler quality like `elongated`. Example:

- "gill raker longer than wide" →
  - Quality ID: `PATO:0000122 and (PATO:0002305 some (PATO:0000921 and (BFO:0000052 some UBERON:0011323)))`
  - Quality Label: `length and (increased_in_magnitude_relative_to some (width and (inheres_in some 'gill raker')))`

### Step 4: Determine if Related Entity is needed

Relational qualities (fused with, anterior to, in contact with, etc.) require
a Related Entity. Check the quality's definition in PATO — if it describes a
relationship between two things, you need an RE. **Qualities in PATO's
`relational_slim` subset always require a Related Entity.** The validation
script will flag missing REs for relational qualities.

### Step 5: Write the EQ row(s)

**Each distinct phenotypic aspect = a separate EQ row.** When a state description
contains multiple phenotypic adjectives, multiple referenced structures, or a
compound description, decompose it fully. A good heuristic: if the state
mentions N structures and M qualities, expect at least N × M rows. Examples:

- "trifid processus ventralis on T1 and T2" → rows for each vertebra × each
  process feature (4+ rows)
- "elongated and narrow gill raker" → one row for elongated, one for narrow
- "triradiate with distinct anterolateral and posterolateral processes" →
  rows for triradiate shape + each process presence

Produce one or more TSV rows per state. Each row has 10 columns:

```
Character\tCharacter Label\tState Symbol\tState Label\tEntity ID\tEntity Label\tQuality ID\tQuality Label\tRelated Entity ID\tRelated Entity Label
```

Verify that your output tool does not strip trailing tabs from empty columns. If a state has no Related Entity, the last two columns must be present but empty (i.e., end with `\t\t`).

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
6. Every row has exactly 10 tab-separated columns (including empty trailing columns)

## Step 7: Validate and Correct

After writing all output files:

1. **Verify all files were written** — confirm the output file exists and is not empty
2. **Run the validation script:**

```bash
scala-cli run scripts/validate_annotations.scala -- <output_file.tsv>
```

3. **Fix all errors** reported by the validator (unknown IDs, label mismatches,
   malformed syntax, missing Related Entities for relational qualities, wrong
   column count)
4. **Re-run the validator** until it reports zero errors. Warnings may be
   acceptable but review them to confirm they are intentional.

The validator checks all IDs against the ontology, parses Manchester syntax
expressions, verifies ID/label correspondence, and flags relational quality
issues. It catches the most common annotation mistakes automatically.

## Completion Report

After writing the output file and passing validation, report only: the output
file path, the number of rows written, the validation result, and any errors or
proposed terms. Do not repeat or summarize the annotations themselves.
