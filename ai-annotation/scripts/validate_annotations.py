#!/usr/bin/env python3
"""Validate that term IDs and labels in annotation files match the ontologies.

Parses OBO files to build an ID -> primary label mapping, then checks every
annotation TSV for:
  1. Term IDs that don't exist in any ontology
  2. Labels that don't match the primary name for the given ID
  3. Malformed post-composed expressions (mismatched parentheses)
  4. Use of obsolete terms

Usage:
    python validate_annotations.py <annotation.tsv> [<annotation2.tsv> ...]

    # Validate a single file:
    python validate_annotations.py round1-initial/characters/char_001.tsv

    # Validate all files in a round:
    python validate_annotations.py round1-initial/characters/char_*.tsv

Ontology OBO files are read from input/ontologies/*.obo relative to this
script's parent directory (ai-annotation/).

Exit code: 0 if all valid, 1 if any errors found.
"""

import csv
import glob
import os
import re
import sys
from collections import defaultdict

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.join(SCRIPT_DIR, "..")
ONTOLOGY_DIR = os.path.join(BASE_DIR, "input", "ontologies")

# Columns that contain ID expressions (0-indexed)
ID_COLUMNS = {4: "Entity ID", 6: "Quality ID", 8: "Related Entity ID"}
# Corresponding label columns
LABEL_COLUMNS = {5: "Entity Label", 7: "Quality Label", 9: "Related Entity Label"}

# Known relation IDs used in post-compositions — these may not be in OBO term stanzas
# but are valid in Manchester syntax expressions
KNOWN_RELATION_IDS = {
    "BFO:0000050": "part_of",
    "BFO:0000051": "has_part",
    "BFO:0000052": "inheres_in",
    "BFO:0000053": "bearer_of",
    "RO:0002150": "connects",
    "RO:0002220": "attaches_to",
    "BSPO:0000096": "adjacent_to",
    "BSPO:0000098": "anterior_to",
    "BSPO:0000099": "posterior_to",
    "BSPO:0000100": "dorsal_to",
    "BSPO:0000101": "ventral_to",
    "BSPO:0000102": "in_left_side_of",
    "BSPO:0000103": "in_right_side_of",
    "BSPO:0000120": "dorsal_to",
    "BSPO:0000121": "ventral_to",
    "PHENOSCAPE:complement_of": "not",
    "PHENOSCAPE:extends_from": "extends_from",
    "PHENOSCAPE:extends_to": "extends_to",
    "PATO:0002304": "decreased_in_magnitude_relative_to",
    "PATO:0002305": "increased_in_magnitude_relative_to",
    "PATO:0002306": "similar_in_magnitude_relative_to",
    "PATO:decreased_in_magnitude_relative_to": "decreased_in_magnitude_relative_to",
    "PATO:increased_in_magnitude_relative_to": "increased_in_magnitude_relative_to",
    "PATO:similar_in_magnitude_relative_to": "similar_in_magnitude_relative_to",
    "UBERON:attaches_to": "attaches_to",
    "UBERON:encloses": "encloses",
    "UBERON:has_muscle_insertion": "has_muscle_insertion",
}

# Pattern to extract CURIEs from Manchester syntax expressions
# Handles standard numeric IDs (UBERON:0001424) and non-numeric IDs (PHENOSCAPE:complement_of)
CURIE_PATTERN = re.compile(r"[A-Z_]+:[A-Za-z_]\w*|[A-Z_]+:\d+")

# Pattern to extract labels from label expressions
# Labels are either single unquoted words or single-quoted multi-word strings
# in context: unquoted_label, 'multi word label'
# They appear between keywords: and, some, (
LABEL_TOKEN_PATTERN = re.compile(r"'([^']+)'|(?<=some )([a-z][a-z_]*(?:\s|$))")


def parse_obo_files(ontology_dir):
    """Parse all .obo files and return {id: set_of_names} and {id: is_obsolete} dicts.

    When the same term appears in multiple OBO files with different names
    (e.g., uberon.obo vs best_merged.obo), all names are kept as valid.
    """
    id_to_names = defaultdict(set)
    obsolete_ids = set()

    obo_files = glob.glob(os.path.join(ontology_dir, "*.obo"))
    if not obo_files:
        print(f"WARNING: No .obo files found in {ontology_dir}", file=sys.stderr)

    def save_term(term_id, term_name, is_obsolete):
        if term_id and term_name:
            id_to_names[term_id].add(term_name)
            if is_obsolete:
                obsolete_ids.add(term_id)

    for obo_path in obo_files:
        current_id = None
        current_name = None
        current_obsolete = False

        with open(obo_path, encoding="utf-8") as f:
            for line in f:
                line = line.rstrip("\n")

                if line == "[Term]" or (line.startswith("[") and line.endswith("]")):
                    save_term(current_id, current_name, current_obsolete)
                    current_id = None
                    current_name = None
                    current_obsolete = False

                elif line.startswith("id: "):
                    current_id = line[4:].strip()

                elif line.startswith("name: "):
                    current_name = line[6:].strip()

                elif line.startswith("is_obsolete: true"):
                    current_obsolete = True

            # Save last term in file
            save_term(current_id, current_name, current_obsolete)

    # Also add known relation IDs to the lookup
    for rel_id, rel_label in KNOWN_RELATION_IDS.items():
        id_to_names[rel_id].add(rel_label)

    return id_to_names, obsolete_ids


def extract_curies(expression):
    """Extract all CURIEs from a Manchester syntax expression."""
    if not expression or not expression.strip():
        return []
    return CURIE_PATTERN.findall(expression)


def check_parentheses(expression):
    """Check that parentheses are balanced in an expression."""
    if not expression:
        return True
    depth = 0
    for ch in expression:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth < 0:
                return False
    return depth == 0


def extract_id_label_pairs(id_expr, label_expr):
    """Extract paired (ID, label) tuples from parallel ID and label expressions.

    The ID and label expressions have the same structure, with CURIEs in the ID
    expression and labels in the label expression occupying corresponding positions.

    Returns a list of (curie, label) pairs, or None if the expressions can't be
    aligned (which itself is an error).
    """
    if not id_expr or not id_expr.strip():
        return []

    curies = CURIE_PATTERN.findall(id_expr)
    if not curies:
        return []

    if not label_expr or not label_expr.strip():
        # IDs present but no labels — will be caught as an error
        return [(c, "") for c in curies]

    # Strategy: replace each CURIE in the ID expression with a placeholder,
    # then do the same structural split on the label expression to align them.
    # The structural keywords (and, some, parentheses) should match.

    # Extract labels by splitting on the same structural keywords
    # Remove structural syntax to get just the term tokens
    label_clean = label_expr
    for keyword in ["and", "some"]:
        label_clean = re.sub(rf"\b{keyword}\b", "|||", label_clean)
    label_clean = label_clean.replace("(", "|||").replace(")", "|||")

    labels = []
    for token in label_clean.split("|||"):
        token = token.strip().strip("'").strip()
        if token:
            labels.append(token)

    if len(curies) != len(labels):
        # Can't align — return what we have, caller will report structural mismatch
        pairs = []
        for i, c in enumerate(curies):
            lbl = labels[i] if i < len(labels) else "<missing>"
            pairs.append((c, lbl))
        return pairs

    return list(zip(curies, labels))


def validate_file(filepath, id_to_names, obsolete_ids):
    """Validate a single annotation TSV file. Returns list of error strings."""
    errors = []
    filename = os.path.basename(filepath)

    try:
        with open(filepath, newline="", encoding="utf-8") as f:
            reader = csv.reader(f, delimiter="\t")
            header = next(reader, None)
            if header is None:
                errors.append(f"{filename}: empty file")
                return errors

            for row_num, row in enumerate(reader, start=2):
                # Pad short rows
                while len(row) < 10:
                    row.append("")

                char_num = row[0]
                state_sym = row[2]
                row_id = f"{filename}:{row_num} (char {char_num}, state {state_sym})"

                # Check each ID/label column pair
                for id_col, label_col in zip(
                    sorted(ID_COLUMNS.keys()), sorted(LABEL_COLUMNS.keys())
                ):
                    id_expr = row[id_col].strip()
                    label_expr = row[label_col].strip()
                    col_name = ID_COLUMNS[id_col]

                    # Skip empty pairs (valid for optional RE columns)
                    if not id_expr and not label_expr:
                        continue

                    if id_expr and not label_expr:
                        errors.append(
                            f"{row_id}: {col_name} has ID but no label: {id_expr}"
                        )
                        continue

                    if label_expr and not id_expr:
                        errors.append(
                            f"{row_id}: {LABEL_COLUMNS[label_col]} has label but no ID: {label_expr}"
                        )
                        continue

                    # Check parentheses
                    if not check_parentheses(id_expr):
                        errors.append(
                            f"{row_id}: {col_name} has unbalanced parentheses: {id_expr}"
                        )
                    if not check_parentheses(label_expr):
                        errors.append(
                            f"{row_id}: {LABEL_COLUMNS[label_col]} has unbalanced parentheses: {label_expr}"
                        )

                    # Extract and check each CURIE
                    curies = extract_curies(id_expr)
                    for curie in curies:
                        if curie not in id_to_names:
                            errors.append(
                                f"{row_id}: {col_name} unknown term ID: {curie}"
                            )
                        elif curie in obsolete_ids:
                            names = ", ".join(sorted(id_to_names[curie]))
                            errors.append(
                                f"{row_id}: {col_name} obsolete term: {curie} ({names})"
                            )

                    # Check ID/label alignment
                    pairs = extract_id_label_pairs(id_expr, label_expr)
                    for curie, label in pairs:
                        if curie not in id_to_names:
                            continue  # Already reported as unknown
                        valid_names = id_to_names[curie]
                        if label not in valid_names:
                            expected = ", ".join(sorted(valid_names))
                            errors.append(
                                f"{row_id}: {col_name} label mismatch for {curie}: "
                                f"got '{label}', expected one of: {expected}"
                            )

    except FileNotFoundError:
        errors.append(f"{filename}: file not found")
    except Exception as e:
        errors.append(f"{filename}: error reading file: {e}")

    return errors


def main():
    if len(sys.argv) < 2:
        print(
            f"Usage: {sys.argv[0]} <annotation.tsv> [<annotation2.tsv> ...]",
            file=sys.stderr,
        )
        sys.exit(2)

    annotation_files = sys.argv[1:]

    print(f"Loading ontologies from {ONTOLOGY_DIR} ...")
    id_to_names, obsolete_ids = parse_obo_files(ONTOLOGY_DIR)
    print(f"  Loaded {len(id_to_names)} terms ({len(obsolete_ids)} obsolete)")

    total_errors = 0
    total_files = 0
    files_with_errors = 0

    for filepath in annotation_files:
        total_files += 1
        errors = validate_file(filepath, id_to_names, obsolete_ids)
        if errors:
            files_with_errors += 1
            total_errors += len(errors)
            for err in errors:
                print(f"  ERROR: {err}")

    print()
    print(f"Validated {total_files} file(s): ", end="")
    if total_errors == 0:
        print("all OK")
    else:
        print(f"{total_errors} error(s) in {files_with_errors} file(s)")

    sys.exit(1 if total_errors > 0 else 0)


if __name__ == "__main__":
    main()
