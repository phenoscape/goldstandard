#!/usr/bin/env python3
"""Split GS_Dataset.tsv into per-character input files for AI annotation.

Each output file contains the character number, label, and all states
(symbol + label) for that character. These are the inputs the biocurator
agent uses — they contain what to annotate, not the EQ annotations themselves.

Usage:
    python split_characters.py

Reads:  ../../data/MappedAnnotations/GS_Dataset.tsv
Writes: ../input/characters/char_NNN.tsv  (one per character)
"""

import csv
import os
from collections import OrderedDict

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
GS_PATH = os.path.join(SCRIPT_DIR, "../../data/MappedAnnotations/GS_Dataset.tsv")
OUTPUT_DIR = os.path.join(SCRIPT_DIR, "../input/characters")


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Collect unique character-state pairs, preserving order
    # Key: character number -> {label, states: [(symbol, label)]}
    characters = OrderedDict()

    with open(GS_PATH, newline="") as f:
        reader = csv.reader(f, delimiter="\t")
        header = next(reader)
        for row in reader:
            char_num = row[0]
            char_label = row[1]
            state_symbol = row[2]
            state_label = row[3]

            if char_num not in characters:
                characters[char_num] = {
                    "label": char_label,
                    "states": OrderedDict(),
                }

            # Use state_symbol as key to deduplicate (a state can have
            # multiple EQ rows in the GS, but we only list it once as input)
            if state_symbol not in characters[char_num]["states"]:
                characters[char_num]["states"][state_symbol] = state_label

    # Write one file per character
    for char_num, info in characters.items():
        filename = f"char_{int(char_num):03d}.tsv"
        filepath = os.path.join(OUTPUT_DIR, filename)

        with open(filepath, "w", newline="") as f:
            writer = csv.writer(f, delimiter="\t")
            writer.writerow(["Character", "Character Label", "State Symbol", "State Label"])
            for state_symbol, state_label in info["states"].items():
                writer.writerow([char_num, info["label"], state_symbol, state_label])

    print(f"Wrote {len(characters)} character files to {os.path.relpath(OUTPUT_DIR, os.getcwd())}")


if __name__ == "__main__":
    main()
