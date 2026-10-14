#!/usr/bin/env python3
"""Checks store/listing.md against the App Store and Google Play limits.

Every field in the listing is a heading such as `### Subtitle (max 30)`
followed by a fenced block. The script counts the characters of each block
and fails when one is over its limit or uses a word that must not appear.

Run from the repository root:  python3 scripts/check_store_listing.py
"""
import re
import sys

PATH = "store/listing.md"
FORBIDDEN = ["goethe"]
HEADING = re.compile(r"^#{2,3} (.+?) \(max (\d+)\)\s*$")

lines = open(PATH, encoding="utf-8").read().split("\n")
section = ""
problems = 0
checked = 0
i = 0
while i < len(lines):
    line = lines[i]
    if line.startswith("## ") and "(max" not in line:
        section = line[3:].strip()
    elif line.startswith("# ") and "(max" not in line:
        section = line[2:].strip()
    m = HEADING.match(line)
    if m and i + 1 < len(lines):
        j = i + 1
        while j < len(lines) and lines[j].strip() == "":
            j += 1
        if j < len(lines) and lines[j].startswith("```"):
            k = j + 1
            body = []
            while k < len(lines) and not lines[k].startswith("```"):
                body.append(lines[k])
                k += 1
            text = "\n".join(body)
            limit = int(m.group(2))
            checked += 1
            status = "ok " if len(text) <= limit else "OVER"
            if len(text) > limit:
                problems += 1
            for word in FORBIDDEN:
                if word in text.lower():
                    problems += 1
                    status = "BAD"
            print(f"{status} {len(text):>4}/{limit:<4} {section} / {m.group(1)}")
            i = k
    i += 1
print(f"\n{checked} fields checked, {problems} problem(s)")
sys.exit(1 if problems else 0)
