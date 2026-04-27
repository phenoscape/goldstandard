#!/usr/bin/env python3
"""Add a Paper_PDF column to each character file in all-characters/.

Reads GS-categories.tsv to get the publication source for each character number,
matches publication names to PDF filenames by normalized (first_author, year),
and rewrites each character TSV with the new column.
"""

import csv
import os
import re
import sys


def normalize_author_year(name):
    """Extract (normalized_first_author, year) from a publication name.

    Examples:
        "Chakrabarty 2007" -> ("chakrabarty", "2007")
        "O?Leary et al. 2013" -> ("oleary", "2013")
        "Nesbitt et al. 2011b" -> ("nesbitt", "2011")
    """
    first_author = re.split(r'[\s&]', name.strip())[0]
    first_author = re.sub(r'[^a-zA-Z]', '', first_author).lower()
    year_match = re.search(r'(\d{4})', name)
    year = year_match.group(1) if year_match else None
    return (first_author, year)


def build_pdf_lookup(papers_dir):
    """Build a dict mapping (normalized_first_author, year) -> pdf filename."""
    lookup = {}
    for fname in os.listdir(papers_dir):
        if not fname.endswith('.pdf'):
            continue
        base = fname.replace('.pdf', '')
        parts = base.split('_')
        first_author = re.sub(r'[^a-zA-Z]', '', parts[0]).lower()
        year_match = re.search(r'(\d{4})', base)
        year = year_match.group(1) if year_match else None
        lookup[(first_author, year)] = fname
    return lookup


def build_char_to_pdf(categories_path, pdf_lookup):
    """Build a dict mapping character number (int) -> pdf filename."""
    char_to_pdf = {}
    unmatched = set()
    with open(categories_path, newline='', encoding='utf-8') as f:
        reader = csv.reader(f, delimiter='\t')
        header = next(reader)
        for row in reader:
            if len(row) < 3:
                continue
            pub_ref = row[1]  # "Character Comment" column, e.g. "Chakrabarty 2007: 1"
            char_num = int(row[2])  # "Character Number" column
            if char_num in char_to_pdf:
                continue
            pub_name = pub_ref.split(':')[0].strip()
            key = normalize_author_year(pub_name)
            if key in pdf_lookup:
                char_to_pdf[char_num] = pdf_lookup[key]
            else:
                unmatched.add(pub_name)
    if unmatched:
        print(f"WARNING: No PDF match for: {unmatched}", file=sys.stderr)
    return char_to_pdf


def add_column_to_file(filepath, pdf_filename):
    """Read a character TSV, add Paper_PDF column, write back."""
    with open(filepath, newline='', encoding='utf-8') as f:
        reader = csv.reader(f, delimiter='\t')
        rows = list(reader)

    if not rows:
        return

    # Add header
    rows[0].append('Paper_PDF')
    # Add value to data rows
    for row in rows[1:]:
        row.append(pdf_filename)

    with open(filepath, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f, delimiter='\t')
        writer.writerows(rows)


def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    categories_path = os.path.join(base_dir, 'supplemental-data', 'GS-categories.tsv')
    papers_dir = os.path.join(base_dir, 'ai-annotation', 'input', 'papers')
    chars_dir = os.path.join(base_dir, 'all-characters')

    pdf_lookup = build_pdf_lookup(papers_dir)
    print(f"Found {len(pdf_lookup)} PDFs: {sorted(pdf_lookup.values())}")

    char_to_pdf = build_char_to_pdf(categories_path, pdf_lookup)
    print(f"Mapped {len(char_to_pdf)} characters to PDFs")

    updated = 0
    skipped = []
    for fname in sorted(os.listdir(chars_dir)):
        if not fname.endswith('.tsv'):
            continue
        match = re.search(r'char_(\d+)', fname)
        if not match:
            continue
        char_num = int(match.group(1))
        if char_num not in char_to_pdf:
            skipped.append(fname)
            continue
        filepath = os.path.join(chars_dir, fname)
        add_column_to_file(filepath, char_to_pdf[char_num])
        updated += 1

    print(f"Updated {updated} files")
    if skipped:
        print(f"Skipped (no mapping): {skipped}", file=sys.stderr)


if __name__ == '__main__':
    main()
