#!/usr/bin/env python3
"""Group character TSVs into per-paper folders under all-characters/by-paper/.

Each input file in all-characters/ is expected to contain a Paper_PDF column,
and every row in a given file must agree on the same non-empty Paper_PDF value.
The script rebuilds all-characters/by-paper/ and copies each character file into
all-characters/by-paper/<Paper_PDF>/<character_file>.
"""

from __future__ import annotations

import csv
import shutil
import sys
from pathlib import Path


def extract_paper_pdf(tsv_path: Path) -> str:
    """Return the single Paper_PDF value used by all rows in a TSV."""
    with tsv_path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        if not reader.fieldnames or "Paper_PDF" not in reader.fieldnames:
            raise ValueError(f"{tsv_path.name} is missing the Paper_PDF column")

        paper_values = {
            row["Paper_PDF"].strip()
            for row in reader
            if row.get("Paper_PDF") and row["Paper_PDF"].strip()
        }

    if not paper_values:
        raise ValueError(f"{tsv_path.name} has no Paper_PDF values")
    if len(paper_values) > 1:
        joined = ", ".join(sorted(paper_values))
        raise ValueError(f"{tsv_path.name} has multiple Paper_PDF values: {joined}")

    return next(iter(paper_values))


def rebuild_directory(output_dir: Path) -> None:
    """Remove old generated contents so reruns stay in sync with inputs."""
    output_dir.mkdir(parents=True, exist_ok=True)
    for child in output_dir.iterdir():
        if child.is_dir():
            shutil.rmtree(child)
        else:
            child.unlink()


def main() -> int:
    base_dir = Path(__file__).resolve().parent
    source_dir = base_dir / "all-characters"
    output_dir = source_dir / "by-paper"

    character_files = sorted(source_dir.glob("char_*.tsv"))
    if not character_files:
        print(f"No character TSVs found in {source_dir}", file=sys.stderr)
        return 1

    rebuild_directory(output_dir)

    copied = 0
    papers: set[str] = set()

    for tsv_path in character_files:
        paper_pdf = extract_paper_pdf(tsv_path)
        destination_dir = output_dir / paper_pdf
        destination_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(tsv_path, destination_dir / tsv_path.name)
        copied += 1
        papers.add(paper_pdf)

    print(f"Copied {copied} character files into {len(papers)} paper folders")
    for paper in sorted(papers):
        print(f"  {paper}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
