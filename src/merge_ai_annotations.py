"""Merge per-character AI annotation files into single annotation TSVs.

Reads char_001.tsv through char_203.tsv from each AI agent's output directory,
fixes column count issues, and writes a single merged file per agent into
data/MappedAnnotations/.
"""

import os
import glob
import sys

HEADER = "Character\tCharacter Label\tState Symbol\tState Label\tEntity ID\tEntity Label\tQuality ID\tQuality Label\tRelated Entity ID\tRelated Entity Label"
TARGET_COLS = 10


def merge_files(input_dir, output_path):
    """Merge per-character files from input_dir into a single TSV at output_path."""
    char_files = sorted(glob.glob(os.path.join(input_dir, "char_*.tsv")))
    if not char_files:
        print(f"No char_*.tsv files found in {input_dir}")
        sys.exit(1)

    total_lines = 0
    skipped_lines = 0

    with open(output_path, 'w') as out:
        out.write(HEADER + "\n")

        for filepath in char_files:
            with open(filepath, 'r') as f:
                for i, line in enumerate(f):
                    # Skip header line
                    if i == 0 and "Character" in line and "Entity ID" in line:
                        continue
                    # Skip blank lines
                    stripped = line.strip()
                    if not stripped:
                        continue

                    cols = stripped.split("\t")
                    ncols = len(cols)

                    if ncols < TARGET_COLS:
                        # Pad with empty columns
                        cols.extend([""] * (TARGET_COLS - ncols))
                    elif ncols > TARGET_COLS:
                        # Truncate (e.g., GPT char_065 state 3 with 17 columns)
                        cols = cols[:TARGET_COLS]

                    out.write("\t".join(cols) + "\n")
                    total_lines += 1

    print(f"{output_path}: {total_lines} data lines from {len(char_files)} files")
    return total_lines


def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    output_dir = os.path.join(base_dir, "data", "MappedAnnotations")

    sources = [
        # Round 1
        ("test-output/round-1/claude-4.6-high", "AI--Claude_46.tsv"),
        ("test-output/round-1/gpt-5.4-high", "AI--GPT_54.tsv"),
        # Round 2
        ("test-output/round-2/claude-4.6-high", "AI--Claude_46_R2.tsv"),
        ("test-output/round-2/gpt-5.4-xhigh", "AI--GPT_54_R2.tsv"),
        ("test-output/round-2/gpt-5.4-mini-high", "AI--GPT_54_Mini.tsv"),
        ("test-output/round-2/sonnet-4.6-medium", "AI--Sonnet_46.tsv"),
    ]

    for input_subdir, output_name in sources:
        input_dir = os.path.join(base_dir, input_subdir)
        output_path = os.path.join(output_dir, output_name)
        merge_files(input_dir, output_path)


if __name__ == "__main__":
    main()
