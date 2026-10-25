#!/usr/bin/env bash
# Encrypts / decrypts the dictionary databases so only the encrypted copies
# are committed. The passphrase comes from the LUGET_DB_PASSPHRASE env var
# (a GitHub Actions secret in CI).
#
#   LUGET_DB_PASSPHRASE=... scripts/luget_db.sh encrypt
#   LUGET_DB_PASSPHRASE=... scripts/luget_db.sh decrypt

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATABASES=(
  "assets/luget.db"
  "java_dic/app/src/main/assets/luget.db"
)

: "${LUGET_DB_PASSPHRASE:?Set LUGET_DB_PASSPHRASE}"

crypt() {
  openssl enc -aes-256-cbc -pbkdf2 -iter 600000 -salt \
    -pass env:LUGET_DB_PASSPHRASE "$@"
}

for relative_path in "${DATABASES[@]}"; do
  plain="$ROOT/$relative_path"
  encrypted="$plain.enc"
  case "${1:-}" in
    encrypt)
      crypt -in "$plain" -out "$encrypted"
      echo "Encrypted $relative_path"
      ;;
    decrypt)
      temporary="$(mktemp)"
      if crypt -d -in "$encrypted" -out "$temporary" 2>/dev/null \
        && head -c 15 "$temporary" | grep -q 'SQLite format 3'; then
        mv "$temporary" "$plain"
        echo "Decrypted $relative_path"
      else
        rm -f "$temporary"
        echo "Wrong passphrase or corrupt $relative_path.enc" >&2
        exit 1
      fi
      ;;
    *)
      echo "Usage: $0 encrypt|decrypt" >&2
      exit 1
      ;;
  esac
done
