#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SCRIPT="${SCRIPT_DIR}/install_debian_system_wide.sh"

if [[ ! -x "$TARGET_SCRIPT" ]]; then
  echo "Greška: $TARGET_SCRIPT nije pronađen ili nije izvršan." >&2
  exit 1
fi

echo "Napomena: install_system_wide.sh je kompatibilni alias."
echo "Pokrećem install_debian_system_wide.sh..."
exec "$TARGET_SCRIPT" "$@"
