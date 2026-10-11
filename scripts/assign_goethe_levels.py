"""
Assigns CEFR levels (A1–C2) to every DeAz row in assets/luget.db.

A1, A2, B1
    Looked up in the official Goethe-Institut word lists. A word gets the
    earliest level whose list contains it.
B2, C1, C2
    Goethe publishes no list above B1, so words missing from all three lists
    are split by German word frequency (wordfreq Zipf score):
        Zipf >= 3.5  -> B2
        Zipf >= 2.7  -> C1
        otherwise    -> C2
    These three levels are estimates, not official CEFR data.

The Goethe PDFs are copyrighted, so they are not stored in the repo. Download
the word lists from goethe.de and pass their paths:

    python3 -m venv /tmp/venv && /tmp/venv/bin/pip install pymupdf wordfreq
    /tmp/venv/bin/python scripts/assign_goethe_levels.py \
        --a1 A1_SD1_Wortliste_02.pdf \
        --a1-fit Goethe-Zertifikat_A1_Fit1_Wortliste.pdf \
        --a2 Goethe-Zertifikat_A2_Wortliste.pdf \
        --b1 Goethe-Zertifikat_B1_Wortliste.pdf

Without --apply the script only prints the new distribution (dry run).
"""

import argparse
import re
import sqlite3
from collections import Counter
from pathlib import Path

import fitz  # PyMuPDF
from wordfreq import zipf_frequency

DB_PATH = Path(__file__).resolve().parent.parent / 'assets' / 'luget.db'

# Bump together with `dbVersion` in word_local_data_source_impl.dart.
DB_VERSION = 6

B2_MIN_ZIPF = 3.5
C1_MIN_ZIPF = 2.7

# The word lists start with a cover, imprint and foreword; entries begin here.
FIRST_ENTRY_PAGE = {'a1': 6, 'a1_fit': 6, 'a2': 3, 'b1': 5}

_ARTICLE = re.compile(r'^(?:der|die|das|sich)\s+')
_SHORT_ARTICLE = re.compile(r'^[res]\s+(?=[A-ZÄÖÜ])')
_ABBREVIATION = re.compile(
    r'\(.*?\)|\b(?:z|d|B|h|u|a|ca|usw|etc|bzw|vgl|Sg|Pl)\.')


def headwords(line: str) -> list[str]:
    """Returns the lemma candidates found on one line of a Goethe list.

    Entries look like `die Adresse, -en` or `dort, -her, -hin  Example ...`;
    the headword is the text before the first comma or wide gap.
    """
    line = line.replace('\t', '  ').strip()
    if not line or len(line) > 90:
        return []
    head = re.split(r'\s{2,}', line)[0]
    if re.search(r'[.!?]', _ABBREVIATION.sub('', head)):
        return []  # an example sentence, not a headword
    found = []
    for alternative in re.split(r'\s/\s|/(?=\s|$)', head):
        word = re.sub(r'\(.*?\)', '', alternative).strip()
        word = word.split(',')[0].strip()
        word = _ARTICLE.sub('', _ARTICLE.sub('', word))
        word = _SHORT_ARTICLE.sub('', word).rstrip('-').strip()
        if not word or re.search(r'[.!?:;=\d]', word) or word.startswith('-'):
            continue
        if len(word.split()) <= 3:
            found.append(word)
    return found


def load_list(pdf: Path, first_page: int) -> set[str]:
    document = fitz.open(pdf)
    words: set[str] = set()
    for page in list(document)[first_page - 1:]:
        for line in page.get_text().splitlines():
            words.update(headwords(line))
    return words


def bare(key: str) -> str:
    """Strips parentheses, article and `sich` from a DeAz key."""
    key = re.sub(r'\(.*?\)', '', key).strip()
    return re.sub(r'\s+', ' ', _ARTICLE.sub('', key)).strip()


def zipf(key: str) -> float:
    """Best Zipf score over ` / ` alternatives; multi-word -> rarest token."""
    scores = []
    for alternative in key.split(' / '):
        tokens = bare(alternative).split() or [alternative]
        scores.append(min(zipf_frequency(t, 'de') for t in tokens))
    return max(scores)


def level_for(key: str, lists: dict[str, set[str]]) -> tuple[str, str]:
    """Returns `(level, source)` where source is `goethe` or `frequency`."""
    alternatives = [bare(a) for a in key.split(' / ')]
    for level in ('A1', 'A2', 'B1'):
        if any(a in lists[level] for a in alternatives):
            return level, 'goethe'
    score = zipf(key)
    if score >= B2_MIN_ZIPF:
        return 'B2', 'frequency'
    return ('C1' if score >= C1_MIN_ZIPF else 'C2'), 'frequency'


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    parser.add_argument('--a1', type=Path, required=True)
    parser.add_argument('--a1-fit', type=Path, required=True)
    parser.add_argument('--a2', type=Path, required=True)
    parser.add_argument('--b1', type=Path, required=True)
    parser.add_argument('--db', type=Path, default=DB_PATH)
    parser.add_argument('--apply', action='store_true',
                        help='write the levels into the database')
    args = parser.parse_args()

    lists = {
        'A1': (load_list(args.a1, FIRST_ENTRY_PAGE['a1'])
               | load_list(args.a1_fit, FIRST_ENTRY_PAGE['a1_fit'])),
        'A2': load_list(args.a2, FIRST_ENTRY_PAGE['a2']),
        'B1': load_list(args.b1, FIRST_ENTRY_PAGE['b1']),
    }
    for level, words in lists.items():
        print(f'Goethe {level}: {len(words)} headwords')

    connection = sqlite3.connect(args.db)
    rows = connection.execute('SELECT id, key FROM DeAz').fetchall()
    updates = [(level_for(key, lists)[0], word_id) for word_id, key in rows]

    distribution = Counter(level for level, _ in updates)
    print(f'\n{len(rows)} DeAz rows:')
    for level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2'):
        print(f'  {level}: {distribution[level]}')

    if not args.apply:
        print('\nDry run — pass --apply to write the levels.')
        return
    connection.executemany('UPDATE DeAz SET level = ? WHERE id = ?', updates)
    connection.execute(f'PRAGMA user_version = {DB_VERSION}')
    connection.commit()
    connection.execute('VACUUM')
    print(f'\nUpdated {args.db} (user_version = {DB_VERSION}).')


if __name__ == '__main__':
    main()
