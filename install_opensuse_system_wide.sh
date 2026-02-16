#!/usr/bin/env bash
set -euo pipefail

PREFIX="/opt/konvertor"
BIN_DIR="/usr/local/bin"
SKIP_ZYPPER="false"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_KONVERTOR="${SCRIPT_DIR}/konvertor.py"

ZYPPER_PACKAGES=(
  python3
  python3-pip
  python3-virtualenv
  libcairo2
  libpango-1_0-0
  libgdk_pixbuf-2_0-0
  libharfbuzz0
  libfribidi0
  fontconfig
  libffi-devel
  shared-mime-info
  dejavu-fonts
  liberation-fonts
)

print_help() {
  cat <<'EOF'
Upotreba: ./install_opensuse_system_wide.sh [OPCIJE]

Instalira konvertor kao sistemsku komandu dostupnu svim korisnicima na openSUSE.

Opcije:
  --prefix DIR         Install direktorijum (podrazumevano: /opt/konvertor)
  --bin-dir DIR        Direktorijum za launcher (podrazumevano: /usr/local/bin)
  --skip-zypper        Preskoči zypper install korak
  -h, --help           Prikaži ovu pomoć
EOF
}

run_sudo() {
  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    "$@"
  fi
}

run_zypper() {
  if command -v sudo >/dev/null 2>&1; then
    sudo zypper "$@"
  else
    zypper "$@"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)
      PREFIX="${2:-}"
      shift
      ;;
    --bin-dir)
      BIN_DIR="${2:-}"
      shift
      ;;
    --skip-zypper)
      SKIP_ZYPPER="true"
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "Greška: Nepoznata opcija: $1" >&2
      print_help
      exit 1
      ;;
  esac
  shift
done

if [[ ! -f "$SOURCE_KONVERTOR" ]]; then
  echo "Greška: konvertor.py nije pronađen pored install_opensuse_system_wide.sh" >&2
  exit 1
fi

if [[ "$SKIP_ZYPPER" != "true" ]]; then
  if ! command -v zypper >/dev/null 2>&1; then
    echo "Greška: zypper nije pronađen. Ovaj skript je namenjen openSUSE sistemima." >&2
    exit 1
  fi

  echo "[1/5] Provera i instalacija sistemskih paketa (zypper)..."
  run_zypper refresh
  run_zypper install -y "${ZYPPER_PACKAGES[@]}"
else
  echo "[1/5] Preskačem zypper install (--skip-zypper)."
fi

echo "[2/5] Kreiram sistemski direktorijum: ${PREFIX}"
run_sudo mkdir -p "$PREFIX"

echo "[3/5] Kopiram konvertor.py"
run_sudo cp "$SOURCE_KONVERTOR" "$PREFIX/konvertor.py"
run_sudo chmod 755 "$PREFIX/konvertor.py"

echo "[4/5] Kreiram/obnavljam virtualno okruženje i instaliram WeasyPrint"
run_sudo python3 -m venv "$PREFIX/.venv"
run_sudo "$PREFIX/.venv/bin/python" -m pip install --upgrade pip
run_sudo "$PREFIX/.venv/bin/pip" install --upgrade weasyprint

echo "[5/5] Kreiram launcher komandu: ${BIN_DIR}/konvertor"
run_sudo mkdir -p "$BIN_DIR"
run_sudo tee "$BIN_DIR/konvertor" >/dev/null <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec "${PREFIX}/.venv/bin/python" "${PREFIX}/konvertor.py" "\$@"
EOF
run_sudo chmod 755 "$BIN_DIR/konvertor"

echo
echo "Instalacija završena. Komanda za sve korisnike:"
echo "  konvertor RPLFD15.00 --encoding iso-8859-2 --font-size 13 --margin 2mm --orientation portrait"
