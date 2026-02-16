#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTES_FILE="${SCRIPT_DIR}/RELEASE_NOTES_TEMPLATE.md"

print_help() {
  cat <<'EOF'
Upotreba:
  ./release.sh create <verzija>
  ./release.sh edit <verzija>

Primeri:
  ./release.sh create v1.1.1
  ./release.sh edit v1.1.0

Napomena:
  Skripta koristi RELEASE_NOTES_TEMPLATE.md kao izvor release beleški.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  print_help
  exit 0
fi

if [[ $# -ne 2 ]]; then
  echo "Greška: očekujem 2 argumenta." >&2
  print_help
  exit 1
fi

ACTION="$1"
VERSION="$2"

if [[ "$ACTION" != "create" && "$ACTION" != "edit" ]]; then
  echo "Greška: prvi argument mora biti 'create' ili 'edit'." >&2
  print_help
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Greška: GitHub CLI (gh) nije instaliran." >&2
  exit 1
fi

if [[ ! -f "$NOTES_FILE" ]]; then
  echo "Greška: nije pronađen fajl $NOTES_FILE" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Greška: niste ulogovani u gh. Pokrenite: gh auth login" >&2
  exit 1
fi

if [[ "$ACTION" == "create" ]]; then
  GH_PAGER=cat gh release create "$VERSION" --title "$VERSION" --notes-file "$NOTES_FILE"
else
  GH_PAGER=cat gh release edit "$VERSION" --notes-file "$NOTES_FILE"
fi

echo "Uspešno: release '$VERSION' ($ACTION)."
