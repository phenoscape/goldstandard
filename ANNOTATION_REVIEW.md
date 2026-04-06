# Annotation Review: AI Agents vs Gold Standard (Characters 1-50)

**Date:** 2026-04-05

Systematic comparison of Claude 4.6 and GPT 5.4 annotations against the Gold
Standard for the first 50 characters, to identify generalizable instruction
improvements for the next annotation round.

---

## Summary

Across 50 characters reviewed per agent:
- **Claude 4.6**: 7/50 exact or near-exact matches (chars 3, 15, 18, 19, 29, 32, 35, 37, 42)
- **GPT 5.4**: 3/50 exact or near-exact matches (chars 15, 32, 40)

Both agents share the same core failure modes, though with different frequencies.
The issues below are ranked by frequency across both agents combined and by impact
on similarity scores.

---

## Issue 1: Creates TEMP IDs for terms that exist in the ontology

**Claude: ~12 occurrences | GPT: ~22 occurrences | Impact: HIGH**

The single most impactful issue. Both agents create UBERONTEMP/PATOTEMP
identifiers for concepts that already exist in the provided ontologies, either
under a different name or via a synonym. TEMP IDs produce zero or near-zero
similarity scores in the pipeline.

**Common patterns:**
- Term exists under a *different primary label* than what the character uses
  - `craniomandibular joint` -> `UBERON:0011171 'jaw joint'` (char 10)
  - `base-plate` -> `UBERON:4300020 'anal fin basal cartilage'` (char 9, synonym "anal fin basal plate")
  - `pelvic plate` -> `UBERON:2100623 'basipterygium element'` (char 41)
  - `ventral supracondylar tubercle` -> `UBERON:0018371` (char 11, exists with that exact name!)
- PATO term exists but agent searches with wrong spelling/form
  - `boomerang-shaped` -> `PATO:0002536 'boomerang shaped'` (char 33)
  - `unicuspid`/`bicuspid` -> `PATO:0005021 'unicuspidate'`/`PATO:0002281 'biscupidate'` (char 36)
  - `molariform` -> `PATO:0005009 'molariform'` (char 36 — exact match!)
  - `extends beyond` -> `PATO:0002464 'extends beyond'` (char 49)
  - `composed of` -> `PATO:0000025 'composition'` (char 47)
- Concept can be expressed via post-composition of existing terms
  - `intertarsal sesamoid` -> `sesamoid bone and (part_of some tarsal skeleton)` (char 25)
  - `postatlantal vertebra` -> `vertebral element and (posterior_to some vertebral bone 1)` (char 27)

**Instruction improvement:** Before creating any TEMP ID, the agent must:
1. Search the ontology by exact label, partial match, and synonym
2. Try alternate spellings and forms (e.g., `-ate`/`-ous`/`-iform` suffixes for PATO)
3. Check if the concept can be post-composed from existing terms
4. If a term really cannot be found, approximate using the *most specific
   subsuming term* post-composed with appropriate relations — e.g.,
   `'parent term' and (part_of some 'location')` — rather than creating a TEMP.
   A parent term that subsumes the correct concept will still share ancestors
   with the GS term and produce non-zero similarity; a TEMP shares nothing.

---

## Issue 2: Defaults to present/absent instead of specific relational/structural qualities

**Claude: ~10 occurrences | GPT: ~12 occurrences | Impact: HIGH**

Both agents frequently model phenotypes as "entity X is present/absent" when the
GS uses semantically richer qualities. This loses critical relational and
structural information.

**Sub-patterns:**

**(a) Relational qualities replaced by present/absent:**
- Char 13: AI says `sacral vertebra present/absent`; GS says `sacral vertebra attached_to/separated_from ilium`
- Char 17: AI says `puboischiadic bar present/absent`; GS says left bar `fused_with/unfused_from` right bar
- Char 9: AI says `double base-plate present/absent`; GS says anal fin basal cartilage is `bipartite/not bipartite`

**(b) Surface features/textures modeled as entities rather than qualities:**
- Char 31: AI creates entity `neurovascular pitting`, quality=present; GS uses entity=`beak`, quality=`foveate`
- Char 45: AI creates entity `toothed plate of clasper`, quality=present; GS uses entity=`clasper`, quality=`dentated`
- Char 7: AI creates entity `basal bulb`, quality=present; GS uses entity=`proximal region of hair shaft`, quality=`swollen`

**(c) Spatial/positional qualities replaced by present/absent:**
- Char 3 (GPT): AI says `muscle present/absent`; GS says muscle `located_in/not_located_in` sheath
- Char 28: AI says caudal spot `decreased/increased size`; GS says position `extends_to/not_extends_to` caudal peduncle

**Instruction improvement:** Add explicit guidance:
- When a character describes a *relationship between two structures* (fusion,
  contact, attachment, articulation), use the appropriate relational quality
  (fused_with, in_contact_with, attached_to, articulated_with) with a Related
  Entity. Never model a relationship as present/absent of a combined structure.
- When a character describes a *surface feature or texture* (pitting, tuberculation,
  tooth-like projections), model it as a quality of the bearer entity (foveate,
  cuspidate, dentated), not as a separate sub-entity that is present/absent.
- Present/absent should only be used when an *entire discrete anatomical structure*
  is truly present or absent.

---

## Issue 3: Missing multi-row decomposition of complex states

**Claude: ~16 occurrences | GPT: ~14 occurrences | Impact: HIGH**

When a character state describes multiple simultaneous phenotypic aspects, the GS
creates separate EQ rows for each aspect. Both agents tend to capture only the
most salient feature and drop the rest.

**Common patterns:**
- Char 8: "Trifid processus ventralis on T1 and T2" -> GS has 4+ rows
  (per-vertebra, per-process); AI has 1-2 rows with no vertebra distinction
- Char 2, state 1: GS has 4 rows (count + bifurcated + triangular + raised);
  AI has 1-2 rows
- Char 33: GS has 3 rows per state (shape + sub-process presence); AI has 1
- Char 47, state 1: GS has 5 rows (4 bone compositions + tripartite); GPT has 1
- Char 20: GS has 2 rows per state (parietal + dermatocranium); AI has 1

**Instruction improvement:** When a state description contains:
- Multiple phenotypic adjectives ("elongated AND narrow")
- Multiple referenced structures ("thoracic vertebrae 1 and 2")
- A compound description ("triradiate with distinct anterolateral and
  posterolateral processes")

Each distinct aspect must be a separate EQ row. Read the state label carefully
and count the distinct phenotypic claims being made. A good heuristic: if the
state mentions N structures or N+1 adjectives, expect at least N EQ rows.

---

## Issue 4: Missing or wrong spatial post-composition in Entity

**Claude: ~10 occurrences | GPT: ~9 occurrences | Impact: HIGH**

The GS frequently post-composes entities to add critical anatomical context
(specific vertebra number, sex, body side, spatial region). Both agents tend to
use bare entity terms.

**Sub-patterns:**

**(a) Missing laterality for bilateral paired structures:**
- Chars 17, 18, 26: Fusion/contact between left and right structures requires
  `in_left_side_of`/`in_right_side_of` post-composition. Both agents omit this.

**(b) Missing sex-specificity:**
- Char 12: "dorsal cloacal glands in female" -> GS uses `part_of female organism`; both agents omit it

**(c) Missing vertebra/element number:**
- Char 8: GS distinguishes `part_of thoracic vertebra 1` vs `part_of thoracic vertebra 2`; both agents use bare processus

**(d) Missing spatial region nesting:**
- Char 21: GS uses `bone fossa part_of (dorsal region part_of phalanx)`; AI uses just `dorsal region part_of phalanx` (missing the fossa layer)
- Char 48: GS uses `dorsal margin part_of ectethmoid`; AI uses just `ectethmoid`

**Instruction improvement:** When a character description includes spatial
qualifiers, they must be reflected in the Entity post-composition:
- "in female/male" -> add `part_of female/male organism`
- "left/right X" or fusion of paired structures -> add
  `in_left_side_of/in_right_side_of organism`
- "vertebra 1 and 2" -> separate rows with `part_of` each specific vertebra
- "dorsal margin of X" -> `dorsal margin and (part_of some X)`, not just `X`
- "anterior region of X" -> `anterior region and (part_of some X)`

---

## Issue 5: Fails to use the complement_of negation pattern

**Claude: ~7 occurrences | GPT: ~5 occurrences | Impact: MEDIUM-HIGH**

The GS often encodes "absent" states not as simple `PATO:absent` but as
`QUALITY_ATTRIBUTE and (PHENOSCAPE:complement_of some SPECIFIC_QUALITY)`. This
preserves information about *what specific quality is absent*.

**Examples:**
- Char 28: GS `position and (not some extends_to)` vs AI `decreased size` or `absent`
- Char 41: GS `shape and (not some semicircular)` vs AI `absent`
- Char 45: GS `shape and (not some dentated)` vs AI `absent`
- Char 49: GS `position and (not some extends_beyond)` vs AI `absent`

**Instruction improvement:** When a character has states like "X present" / "X
absent" where X is a specific quality (not a structure):
- The "present" state uses the specific quality: `QUALITY_ID`
- The "absent" state uses: `QUALITY_PARENT and (PHENOSCAPE:complement_of some QUALITY_ID)`
- Reserve simple `PATO:0000462 absent` only for when an entire anatomical
  structure is absent

---

## Issue 6: Defaults to part_of when other relations are correct

**Claude: ~3 occurrences | GPT: ~3 occurrences | Impact: MEDIUM**

Both agents default to `BFO:0000050` (part_of) for nearly all post-composition
relationships, when biologically different relations apply.

**Examples:**
- Chars 36, 50: Teeth `attaches_to` toothplates/bones, not `part_of`
- Char 50: Replacement tooth is `adjacent_to` premolar position, not `part_of`
- Char 27: Rib head `connected_to` vertebral element, not `part_of`

**Instruction improvement:** Choose the biologically appropriate relation:
- `attaches_to` — for teeth on jaws/toothplates, ligaments on bones
- `adjacent_to` — for proximity relationships (replacement tooth near target)
- `connected_to` — for articular connections
- `posterior_to`/`anterior_to` — for serial homologs (vertebral position)
- `part_of` — only for true mereological containment

---

## Issue 7: Uses simple size/shape qualities instead of magnitude-relative-to pattern

**Claude: ~4 occurrences | GPT: ~4 occurrences | Impact: MEDIUM**

When a character explicitly compares two dimensions or structures, the GS uses
the complex `increased_in_magnitude_relative_to` quality pattern. Both agents
substitute simpler qualities.

**Examples:**
- Char 22: GS `length and (increased_in_magnitude_relative_to some (width and (inheres_in some gill raker)))`; AI uses `elongated`
- Char 43: GS `length and (decreased_in_magnitude_relative_to some ...)`; AI uses `decreased length`

**Instruction improvement:** When a character explicitly compares two measurable
properties (e.g., "longer than wide", "height exceeds length"), use the
`increased_in_magnitude_relative_to` or `similar_in_magnitude_relative_to`
pattern to encode the comparison target explicitly.

---

## Issue 8: Over-composes entity when existing term suffices

**Claude: ~3 occurrences | GPT: ~4 occurrences | Impact: LOW**

The AI sometimes adds unnecessary spatial post-composition when the named
ontology term already captures the intended meaning.

**Examples:**
- Char 37: GPT adds `adjacent_to orbital region and adjacent_to mouth` to
  `cheek scale` — unnecessary since UBERON:0018312 already means cheek scale
- Char 49: Both add `part_of caudal fin lower lobe` to `hypochordal radial` —
  the term already implies caudal fin context

**Instruction improvement:** If a named ontology term already captures the
anatomical context, do not add redundant spatial qualifiers. Only post-compose
when needed to disambiguate.

---

## Issue 9: Wrong entity choice (not a specificity issue — fundamentally different structure)

**GPT: ~4 occurrences | Claude: ~2 occurrences | Impact: MEDIUM**

Sometimes the AI selects an entity that is a genuinely different anatomical
structure, not just a more/less specific version of the right one.

**Examples:**
- Char 6: GPT uses `nasal process of premaxilla` (UBERON:0018341); GS uses
  `alary process of premaxilla` (UBERON:3000003) — different structures
- Char 33: Both use `pterygoid bone` (UBERON:0010389/3000523); GS uses
  `sphenoid bone pterygoid process` (UBERON:0004649) — different structure entirely
- Char 5: GPT uses `tectorial membrane of cochlea`; GS uses
  `tectorial restraint system` — component vs system

**Instruction improvement:** Always read the full `def:` field of an ontology
term before committing to it. Terms with similar names can refer to different
structures in different taxa. Check the `is_a:` hierarchy to confirm the term
is in the correct anatomical class.

---

## Agent-Specific Observations

### Claude 4.6 strengths (relative to GPT)
- Better at finding existing ontology terms (fewer TEMP IDs overall)
- Better at post-composition syntax when it does attempt it
- More consistent complement_of negation pattern usage

### GPT 5.4 strengths (relative to Claude)
- Sometimes captures more spatial detail in entity expressions
- Occasionally uses relational qualities where Claude defaults to present/absent

### GPT 5.4 unique issues
- Fabricated/hallucinated BSPO identifiers (char 26: used BSPO:0000102 which doesn't exist)
- More frequent TEMP creation for PATO terms that exist with nearly identical labels

---

## Priority-Ordered Instruction Improvements for SKILL.md

1. **Ontology search exhaustiveness** (Issues 1, 9) — require synonym search,
   alternate forms, and definition reading before any TEMP creation. Approximate
   with most specific subsuming term + post-composition rather than TEMP.

2. **Quality-on-bearer, not entity-present/absent** (Issue 2) — explicit guidance
   on when to use relational qualities vs present/absent, and when to model
   features as qualities of the bearer rather than separate entities.

3. **Multi-row decomposition** (Issue 3) — explicit instruction to produce one
   EQ row per distinct phenotypic claim in a state description.

4. **Required spatial post-composition** (Issue 4) — enumerate the situations
   requiring post-composition: laterality, sex, vertebra number, spatial region.

5. **Complement_of negation** (Issue 5) — add the pattern with examples to the
   skill's conventions section.

6. **Relation choice** (Issue 6) — add a relations decision guide (part_of vs
   attaches_to vs adjacent_to vs connected_to).

7. **Magnitude-relative-to** (Issue 7) — add the proportional comparison pattern.

8. **Validator script** — require running the validation script at end of
   workflow to catch ID/label mismatches and missing terms.

9. **Paper consultation** — more explicitly direct reading the source publication
   for unfamiliar terminology and anatomical disambiguation.
