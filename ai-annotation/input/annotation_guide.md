# Guide to Character Annotation

Reference guide for EQ (Entity-Quality) phenotype annotation, adapted from the
[Phenoscape Guide to Character Annotation](https://github.com/phenoscape/phenoscape-wiki/blob/main/wiki/Guide_to_Character_Annotation.md),
which was provided to the human curators in the original study.

**Mechanical changes from the original guide:**
- Post-composed expressions use OWL Manchester syntax (the original guide uses
  Phenex caret notation; see syntax mapping below)
- Output is written to TSV files (the original used the Phenex desktop application)
- Term IDs and primary labels must both be provided for every term

---

## The EQ Model

The Entity-Quality (EQ) formalism combines 'Entity' terms from Uberon (an
anatomical ontology) with 'Quality' descriptors from the Phenotype and Trait
Ontology (PATO). Spatial and positional terms from the Biological Spatial
Ontology (BSPO) are also utilized.

Each annotation row captures one EQ statement. A single character state often
requires multiple EQ rows to fully describe its phenotype.

## Output Format

Each EQ annotation row has 10 tab-separated columns:

| Column | Description |
|--------|-------------|
| Character | Character number |
| Character Label | Character description |
| State Symbol | State code (0, 1, 2, ...) |
| State Label | State description |
| Entity ID | Entity as OWL Manchester expression using CURIEs |
| Entity Label | Same expression using primary labels from the ontology |
| Quality ID | Quality as CURIE or Manchester expression |
| Quality Label | Same using primary labels |
| Related Entity ID | Related entity as CURIE or expression (may be empty) |
| Related Entity Label | Same using primary labels (may be empty) |

**ID/Label correspondence:** Every term must appear in both forms. The ID column
uses CURIEs (e.g., `UBERON:0001424`); the label column uses the `name:` field
from the OBO file (e.g., `ulna`). For post-composed expressions, the structure
is identical — only the atomic terms are swapped between ID and label form.

**Label conventions:**
- Single-word labels are unquoted: `position`, `absent`, `ulna`
- Multi-word labels are single-quoted: `'increased size'`, `'nasal bone'`
- Relation labels in expressions are always unquoted: `part_of some`, `not some`

## Post-Composition Syntax

Post-composition creates complex term expressions by combining existing terms.
This project uses **OWL Manchester syntax**:

```
<genus_ID> and (<relation_ID> some <differentia_ID>)
```

The original Phenoscape guide uses Phenex caret notation. The mapping is:

| Phenex caret notation | OWL Manchester syntax |
|-----------------------|-----------------------|
| `genus^relation(differentia)` | `GENUS_ID and (REL_ID some DIFF_ID)` |
| `A^part_of(B)` | `A_ID and (BFO:0000050 some B_ID)` |
| `A^part_of(B^part_of(C))` (nested) | `A_ID and (BFO:0000050 some (B_ID and (BFO:0000050 some C_ID)))` |
| `A^connects(B)^connects(C)` (multiple) | `A_ID and (RO:0002150 some B_ID) and (RO:0002150 some C_ID)` |
| `Q^not(Q2)` | `Q_ID and (PHENOSCAPE:complement_of some Q2_ID)` |

In the label column, the same structure is used with labels replacing CURIEs:
- ID: `BSPO:0000066 and (BFO:0000050 some UBERON:0002397)`
- Label: `'anterior region' and (part_of some maxilla)`

---

## PATO Terms Used in Systematic Character Annotation

| PATO Attribute-Level Term | Synonyms | Examples of Child Terms |
|---------------------------|----------|----------------------|
| shape | | triangular, lobed, concave, protruding into |
| position | placement, location | horizontal, anterior to |
| size | | thin, large, decreased height |
| structure | | porous, fused with |
| composition | composed of, content | ligamentous, cartilaginous |
| texture | | smooth, wrinkled |
| optical quality | | color, brightness |
| mass | | increased mass |
| quality of a solid | | flexible, hard |
| mobility | | mobile, immobile |
| closure | | open, closed |
| behavioral quality | | |
| count | number, amount | present, absent |

## Annotation Specificity

Annotations utilize the most specific term or post-composition possible for both
Entity and Quality. When characters involve complex phenotypes (particularly
shape variation), annotations may be made at the attribute level in PATO (e.g.,
PATO:0000052 shape).

---

## Character Annotation Patterns

### 1. Qualities of Single Physical Entities

#### 1a. Shape

All shape terms apply only to single entities:

`E: supraorbital, Q: sigmoid`

#### 1b. Position

Some position terms apply only to single entities:

`E: projection and (part_of some frontal), Q: vertical`

#### 1c. Count

The 'Count' field records numerical values:

- `E: vertebra, Q: count, Count: 33`

#### 1d. Presence/Absence

PATO terms `present` (PATO:0000467) and `absent` (PATO:0000462) annotate
variation in entity presence:

`E: pectoral fin, Q: present`

**Inferred Presence:** It is unnecessary to annotate presence if the character
describes other attributes. For example, "frontal bone present and round"
requires only:

`E: frontal bone, Q: round`

because the presence of frontal bone is inferred.

#### 1e. Mobility

Skeletal entities may be described as mobile (capable of movement) or immobile:

`E: maxilla, Q: mobile`

#### 1f. Composition

Composition qualities describe the types and quantities of constituent subparts:

`E: bone, Q: poorly ossified`

### 2. Qualities of Related Physical Entities

Some phenotypes describe states existing between two entities, utilizing
relational qualities such as "differentiated from," "overlapped by," and
"fused with":

`E: parietal bone, Q: fused with, RE: supraoccipital bone`

#### 2a. Positional Qualities Between Two Entities

anterior to, posterior to, diagonal to, extends to, basal to

#### 2b. Structural Qualities Between Two Entities

- attached to
- in contact with
- separated from (denotes entities not touching)
- fused with
- unfused from (applies whether or not elements are in contact)

#### 2c. Composition Quality Between Two Entities

`E: lateral forebrain bundle, Q: composition, RE: myelinated nerve fiber`

### 3. Size

#### 3a. Relative Size Comparisons

Comparisons between two structures, such as "frontal length greater than
parietal length":

`E: frontal bone, Q: increased length, RE: parietal`

#### 3b. Size Comparison Across Taxa

A state describing "frontal large" is annotated:

`E: frontal bone, Q: increased size`

#### 3c. Multiple Dimensions of Size

When multiple size dimensions are described, such as "greater length relative to
width," quality post-composition is required. In Manchester syntax:

```
E: frontal bone
Q: PATO:0000122 and (PATO:0002305 some (PATO:0000921 and (BFO:0000052 some <frontal_bone_ID>)))
   length and (increased_in_magnitude_relative_to some (width and (inheres_in some 'frontal bone')))
```

A less detailed alternative:

`E: frontal bone, Q: increased length, RE: frontal bone`

#### 3d. Series of Relative Sizes

For ranges such as "maxilla: (0) long, (1) medium, or (2) short," place numbers
in the Count column indicating sort order (1 < 2 < 3...):

`E: maxilla, Q: length, Count: 1` [for "short"]

#### 3e. Size Variation from a "Normal" State

For "femur size: (0) small, (1) typical size":

- State 0: `E: femur, Q: decreased size`
- State 1: `E: femur, Q: size and (not some decreased size)` (complement)

#### 3f. Similarity in 'Size' and 'Shape' Terms

Many aspects of size also relate to shape. By convention, "increased width" is
used to indicate size variation rather than "broad."

### 4. Biological Process Annotations

Phenotypes describing biological processes use terms from the Gene Ontology's
biological process branch (GO:0008150). These terms can only be used with
'process quality' (PATO:0001236) terms.

### 5. Sexually Dimorphic Phenotypes

Sex-specific phenotypes use Uberon terms 'male organism' and 'female organism'
via post-composition:

`E: cloacal fold and (part_of some male organism), Q: absent`

### 6. Quality-Modified Entities and 'Present'/'Absent' Annotations

Sometimes PATO terms modify entities in post-composition. For example, "number
of round teeth":

`E: tooth and (bearer_of some round), Q: count`

For "branched dorsal fin ray, present or absent," interpret as quality variation:

- `E: dorsal fin ray, Q: branched`
- `E: dorsal fin ray, Q: unbranched`

**Implications on Reasoning:** Presence/absence of white hair has two different
annotations:

- `E: hair and (bearer_of some white), Q: present` (some white hair exists)
- `E: hair, Q: white` (all hair is white)

Generally, quality-modified entities are preferred for complex EQs.

### 7. Bilaterally Paired Structures

Contralateral halves use `in_right_side_of` and `in_left_side_of` relations:

```
E: frontal and (in_right_side_of some whole organism)
Q: fused with
RE: frontal and (in_left_side_of some whole organism)
```

### 8. Complementary Phenotypes ("Negation")

When one state encompasses any phenotype except the opposite state, use
"complementary phenotypes." For "Opercle: 0) round; 1) not round":

- State 0: `E: opercle, Q: round`
- State 1: `E: opercle, Q: shape and (not some round)` (complement)

In Manchester syntax, "not" is expressed as `PHENOSCAPE:complement_of`:
`PATO:0000052 and (PHENOSCAPE:complement_of some PATO:0000411)`

This convention applies to variation from normal, average, or typical states.

### 9. Singular vs. Plural Entities

Terms use singular form (e.g., 'basihyal tooth' rather than 'basihyal teeth')
to avoid ambiguity.

### 10. Coloration and Color Pattern Phenotypes

Coloration uses PATO color qualities; color patterns use terms like 'blotchy'
or 'banded':

- `E: trunk, Q: yellow`
- `E: caudal fin, Q: banded`

### 11. Polymorphic State Descriptions

When authors describe variability within a single state, create multiple
annotations. For "infraorbital 5, reduced in size or absent":

- `E: infraorbital 5, Q: decreased size`
- `E: infraorbital 5, Q: absent`

### 12. Use of Skeletal Terms (Bone, Cartilage, Skeletal Element)

Authors sometimes refer to endochondral structures without specifying bone or
cartilage. Convention assumes bone unless "cartilage" is explicitly stated.
When unclear after reviewing publication materials, use "element" terms.

Example: "Epibranchial 1: (0) present and ossified; (1) present and
cartilaginous; (2) absent"

- State 0: `E: epibranchial 1 bone, Q: present`
- State 1: `E: epibranchial 1 cartilage, Q: present`
- State 2: `E: epibranchial 1 cartilage, Q: absent` AND
  `E: epibranchial 1 bone, Q: absent`

"Unossified" in paleontology means no trace of skeletal element:
`E: pubis, Q: absent`

### 13. Unannotatable States

Some states cannot be annotated with EQ (e.g., truncated descriptions, "State 4"
with no phenotype information). Leave all EQ columns empty for these states.
They should still appear in the output file to maintain the complete
character-state mapping.

---

## Creating or Refining Terms by Post-Composition

New terms can be composed on-the-fly by combining existing terms using the
"genus-differentia" principle. One term serves as the genus, differentiated
using a relationship and differentia term.

### General Rules

- Choose the more general part as the genus, then use the relationship and
  differentia to narrow down
- For example, "process of the lateral ethmoid" uses "anatomical projection"
  as the genus with "part_of" and "lateral ethmoid":
  `anatomical projection and (part_of some lateral ethmoid)`

### Refining with the Spatial Ontology (BSPO)

BSPO provides terms for margins, surfaces, or regions of skeletal elements. For
"anterior process of the maxilla":

`anatomical projection and (part_of some (anterior region and (part_of some maxilla)))`

**Regions vs. Surfaces:** Regions lack well-defined boundaries; surfaces have
them. For post-compositions, region terms are typically used.

BSPO regions: anterior region, posterior region, dorsal region, ventral region,
proximal region, distal region, lateral region, medial region.

BSPO surfaces: dorsal surface, ventral surface.

### Creating Joint Terms

Joints are defined by the skeletal elements they connect, using the `connects`
relation (not nested):

`skeletal joint and (connects some metapterygoid) and (connects some hyomandibula)`

### Multiple Differentia and Nesting

Post-compositions can be nested:

`anatomical projection and (part_of some (anterior region and (part_of some maxilla)))`

or have multiple non-nested differentia:

`skeletal joint and (connects some metapterygoid) and (connects some hyomandibula)`

The composition order matters for non-symmetric relationships.

---

## Relations Used for Post-Compositions

| Relation | Category | Design Pattern |
|----------|----------|----------------|
| part_of (BFO:0000050) | mereological | E and (part_of some E2) |
| has_part (BFO:0000051) | mereological | E and (has_part some E2) |
| bearer_of (BFO:0000053) | quality | E and (bearer_of some Q) |
| inheres_in (BFO:0000052) | quality | Q and (inheres_in some E) |
| connects (RO:0002176) | connectedness | joint and (connects some E1) and (connects some E2) |
| connected_to (RO:0002170) | connectedness | E and (connected_to some E2) |
| continuous_with (RO:0002150) | connectedness | E and (continuous_with some E2) |
| attaches_to (RO:0002371) | connectedness | E and (attaches_to some E2) |
| anteriorly_connected_to | connectedness | E and (anteriorly_connected_to some E2) |
| posteriorly_connected_to | connectedness | E and (posteriorly_connected_to some E2) |
| distally_connected_to | connectedness | E and (distally_connected_to some E2) |
| proximally_connected_to | connectedness | E and (proximally_connected_to some E2) |
| develops_from | development | E and (develops_from some E2) |
| has_muscle_insertion | muscle | muscle and (has_muscle_insertion some E) |
| has_muscle_origin | muscle | muscle and (has_muscle_origin some E) |
| serves_as_attachment_site_for | muscle | E and (serves_as_attachment_site_for some muscle) |
| adjacent_to (RO:0002220) | spatial | E and (adjacent_to some E2) |
| anterior_to (BSPO:0000096) | spatial | E and (anterior_to some E2) |
| posterior_to (BSPO:0000099) | spatial | E and (posterior_to some E2) |
| dorsal_to (BSPO:0000098) | spatial | E and (dorsal_to some E2) |
| ventral_to (BSPO:0000102) | spatial | E and (ventral_to some E2) |
| in_left_side_of (BSPO:0000120) | spatial | E and (in_left_side_of some E2) |
| in_right_side_of (BSPO:0000121) | spatial | E and (in_right_side_of some E2) |
| distal_to | spatial | E and (distal_to some E2) |
| encloses | spatial | E and (encloses some E2) |
| surrounds | spatial | E and (surrounds some E2) |
| extends_from (PHENOSCAPE:extends_from) | spatial | E and (extends_from some E2) |
| extends_to (PHENOSCAPE:extends_to) | spatial | E and (extends_to some E2) |
| complement_of (PHENOSCAPE:complement_of) | negation | Q and (not some Q2) |
| increased_in_magnitude_relative_to (PATO:0002305) | size | Q and (increased_in_magnitude_relative_to some (Q2 and (inheres_in some E))) |
| decreased_in_magnitude_relative_to (PATO:0002304) | size | Q and (decreased_in_magnitude_relative_to some (Q2 and (inheres_in some E))) |
| similar_in_magnitude_relative_to (PATO:0002306) | size | Q and (similar_in_magnitude_relative_to some (Q2 and (inheres_in some E))) |

Note: Some relations may appear with namespace-qualified IDs in post-composed
expressions (e.g., `BFO:0000050 some` for `part_of some`). Look up the relation
ID in the ontology Typedef stanzas when needed.

---

## Interpreting Authors' Text

Authors may use words with exact ontology matches, but curators may choose
different terms based on context and anatomical knowledge. For instance, "deep"
in "Clavicle shape of ventromedial plate: narrow, deep, intermediate" might be
interpreted as increased width depending on context.

Similarly, authors sometimes use terms like "continuous" or "discontinuous" to
describe margins or position, but more appropriate PATO terms (e.g., "straight,"
"offset") are preferred.

---

## Searching the Ontologies

The ontologies are provided in OBO format. Key fields per term stanza:

```
[Term]
id: UBERON:0001474
name: bone element              <- this is the primary label to use
def: "..." [...]                <- definition, helpful for choosing the right term
synonym: "bone organ" EXACT []  <- synonyms can help find terms
is_a: UBERON:0004765            <- parent term (superclass)
relationship: part_of UBERON:0001434  <- relationships to other terms
is_obsolete: true               <- DO NOT use obsolete terms
```

Search strategy:
1. Search for keywords from the character/state description
2. Check the `name:` field for the primary label
3. Read the `def:` field to confirm the term matches the intended meaning
4. Check synonyms — terms often have common names or Latin alternatives
5. Check `is_obsolete:` — never use obsolete terms; look for `replaced_by:`
6. If unsure between multiple terms, prefer the more specific one
