"""
Converts Dictionary_Last.xlsx into the luget.db SQLite asset.

Tables produced
---------------
DeAz        German → Azerbaijani (all grammatical columns)
AzDe        Azerbaijani → German  (auto-generated from DeAz translations)
bookmark    Empty; schema matches app expectations
quiz_results  Empty; will also be recreated by onOpen, but included for
              completeness

user_version is set to 3 so the app re-copies the asset on next launch.
Remember to bump `dbVersion` in word_local_data_source_impl.dart to 3 as well.
"""

import re
import shutil
import sqlite3
from collections import defaultdict
from pathlib import Path

import openpyxl

BASE = Path('/Users/elvinmammadov/StudioProjects/Dictionary')
EXCEL = BASE / 'assets' / 'Dictionary_Last.xlsx'
DB_OUT = BASE / 'assets' / 'luget.db'
DB_BACKUP = DB_OUT.with_suffix('.db.bak')
DB_VERSION = 3   # bump from 2 → 3 to force re-copy on existing installs

# ---------------------------------------------------------------------------
# 1.  Load Excel → DeAz rows
# ---------------------------------------------------------------------------

print(f"Loading {EXCEL} …")
wb = openpyxl.load_workbook(EXCEL, read_only=True, data_only=True)
ws = wb.active

headers = [c.value for c in next(ws.iter_rows(min_row=1, max_row=1))]
print(f"  Headers: {headers}")

# Expected column order (0-indexed after Id column is skipped):
# Id | Word | Article | Gender | MainType | SubType | Translation |
# Genitive | Plural | Imperfekt | Perfekt | Comparative | Superlative | Sentence
COL = {name: idx for idx, name in enumerate(headers)}

deaz_rows: list[dict] = []

def _val(row, col_name: str):
    """Return stripped string or None for empty/missing cells."""
    v = row[COL[col_name]]
    if v is None:
        return None
    s = str(v).strip()
    return s if s else None

for row in ws.iter_rows(min_row=2, values_only=True):
    word = _val(row, 'Word')
    translation = _val(row, 'Translation')
    if not word or not translation:
        continue
    deaz_rows.append({
        'key':         word,
        'value':       translation,
        'article':     _val(row, 'Article'),
        'gender':      _val(row, 'Gender'),
        'main_type':   _val(row, 'MainType'),
        'sub_type':    _val(row, 'SubType'),
        'genitive':    _val(row, 'Genitive'),
        'plural':      _val(row, 'Plural'),
        'imperfekt':   _val(row, 'Imperfekt'),
        'perfekt':     _val(row, 'Perfekt'),
        'comparative': _val(row, 'Comparative'),
        'superlative': _val(row, 'Superlative'),
        'example':     None,          # column not present in this Excel
        'sentence':    _val(row, 'Sentence'),
    })

wb.close()
print(f"  DeAz rows read: {len(deaz_rows)}")

# ---------------------------------------------------------------------------
# 2.  Generate AzDe rows from DeAz translations
#
# For every DeAz entry the Translation field contains numbered items like
#   "1. ilanbalığı\n2. başqa söz"
# Each individual Azerbaijani word becomes an AzDe key. If the same
# Azerbaijani word appears across multiple DeAz entries it gets multiple
# German translations merged in one AzDe row.
# ---------------------------------------------------------------------------

NUM_RE = re.compile(r'^\d+\.\s*')   # leading "N. " prefix


def strip_num(s: str) -> str:
    return NUM_RE.sub('', s).strip()


# az_word → ordered list of (german_word, main_type, sub_type)
az_map: dict[str, list[tuple[str, str | None, str | None]]] = defaultdict(list)

for row in deaz_rows:
    german = row['key']
    mt = row['main_type']
    st = row['sub_type']
    if not row['value']:
        continue
    for line in row['value'].split('\n'):
        line = line.strip()
        # Only process lines that start with a number prefix (e.g. "1. …")
        if not re.match(r'^\d+\.', line):
            continue
        az_word = strip_num(line)
        if az_word:
            az_map[az_word].append((german, mt, st))

print(f"  Unique AzDe keys generated: {len(az_map)}")

azde_rows: list[dict] = []
for az_word, entries in az_map.items():
    values, types, subtypes = [], [], []
    has_sub = False
    for n, (german, mt, st) in enumerate(entries, 1):
        values.append(f"{n}. {german}")
        types.append(f"{n}. {mt}" if mt else f"{n}. ")
        if st:
            subtypes.append(f"{n}. {st}")
            has_sub = True
        else:
            subtypes.append('')
    azde_rows.append({
        'key':       az_word,
        'value':     '\n'.join(values),
        'main_type': '\n'.join(types) if types else None,
        'sub_type':  '\n'.join(s for s in subtypes if s) if has_sub else None,
    })

print(f"  AzDe rows built: {len(azde_rows)}")

# ---------------------------------------------------------------------------
# 3.  Write SQLite database
# ---------------------------------------------------------------------------

if DB_OUT.exists():
    shutil.copy2(DB_OUT, DB_BACKUP)
    print(f"\nBacked up existing DB → {DB_BACKUP}")

if DB_OUT.exists():
    DB_OUT.unlink()

conn = sqlite3.connect(DB_OUT)
cur = conn.cursor()

# Set schema version so the app knows to re-copy on first launch after update
cur.execute(f"PRAGMA user_version = {DB_VERSION}")

cur.executescript("""
CREATE TABLE DeAz (
    key         TEXT,
    value       TEXT,
    article     TEXT,
    gender      TEXT,
    main_type   TEXT,
    sub_type    TEXT,
    genitive    TEXT,
    plural      TEXT,
    imperfekt   TEXT,
    perfekt     TEXT,
    comparative TEXT,
    superlative TEXT,
    example     TEXT,
    sentence    TEXT
);

CREATE TABLE AzDe (
    key       TEXT,
    value     TEXT,
    main_type TEXT,
    sub_type  TEXT
);

CREATE TABLE bookmark (
    key   VARCHAR(100),
    value TEXT,
    date  DATETIME DEFAULT CURRENT_TIMESTAMP,
    type  TEXT,
    PRIMARY KEY (key, value)
);

CREATE TABLE quiz_results (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    score          INTEGER NOT NULL,
    totalQuestions INTEGER NOT NULL,
    dateTime       TEXT    NOT NULL
);
""")

cur.executemany(
    """INSERT INTO DeAz
       (key, value, article, gender, main_type, sub_type,
        genitive, plural, imperfekt, perfekt, comparative, superlative,
        example, sentence)
       VALUES
       (:key, :value, :article, :gender, :main_type, :sub_type,
        :genitive, :plural, :imperfekt, :perfekt, :comparative, :superlative,
        :example, :sentence)""",
    deaz_rows,
)
print(f"\nInserted {cur.rowcount} rows into DeAz")

cur.executemany(
    """INSERT INTO AzDe (key, value, main_type, sub_type)
       VALUES (:key, :value, :main_type, :sub_type)""",
    azde_rows,
)
print(f"Inserted {cur.rowcount} rows into AzDe")

conn.commit()

# Verify
cur.execute("SELECT COUNT(*) FROM DeAz")
print(f"\nVerification — DeAz rows : {cur.fetchone()[0]}")
cur.execute("SELECT COUNT(*) FROM AzDe")
print(f"Verification — AzDe rows : {cur.fetchone()[0]}")
cur.execute("PRAGMA user_version")
print(f"Verification — user_version: {cur.fetchone()[0]}")

conn.close()
print(f"\n✓ New database written to {DB_OUT}")
print(  "  Remember to bump dbVersion to 3 in word_local_data_source_impl.dart")

