#!/usr/bin/env bash
set -euo pipefail

PREFIX="/opt/konvertor"
BIN_DIR="/usr/local/bin"
REPO_ACTION="ask"
NON_INTERACTIVE="false"
SKIP_APT="false"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_KONVERTOR="${SCRIPT_DIR}/konvertor.py"

APT_PACKAGES=(
  python3
  python3-venv
  python3-pip
  libcairo2
  libpango-1.0-0
  libpangoft2-1.0-0
  libgdk-pixbuf-2.0-0
  libffi-dev
  shared-mime-info
  fonts-dejavu-core
  fonts-liberation
)

print_help() {
  cat <<'EOF'
Upotreba: ./install_system_wide.sh [OPCIJE]

Instalira konvertor kao sistemsku komandu dostupnu svim korisnicima.

Opcije:
  --prefix DIR           Install direktorijum (podrazumevano: /opt/konvertor)
  --bin-dir DIR          Direktorijum za launcher (podrazumevano: /usr/local/bin)
  --skip-apt             Preskoči apt install korak
  --auto-disable-repo    Automatski isključi problematičan repo.purs.rs (bez pitanja)
  --skip-disable-repo    Ne diraj repo.purs.rs (bez pitanja)
  --non-interactive      Ne postavlja pitanja; bez --auto/--skip podrazumevano isključuje repo
  -h, --help             Prikaži ovu pomoć
EOF
}

run_sudo() {
  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    "$@"
  fi
}

run_apt() {
  if command -v sudo >/dev/null 2>&1; then
    sudo apt "$@"
  else
    apt "$@"
  fi
}

disable_broken_purs_repo() {
  local repo_pattern="repo.purs.rs"
  local repo_files=()

  if [[ -f /etc/apt/sources.list ]] && grep -q "$repo_pattern" /etc/apt/sources.list; then
    repo_files+=("/etc/apt/sources.list")
  fi

  while IFS= read -r file; do
    repo_files+=("$file")
  done < <(grep -R -l "$repo_pattern" /etc/apt/sources.list.d 2>/dev/null || true)

  if [[ ${#repo_files[@]} -eq 0 ]]; then
    return 0
  fi

  local should_disable=""
  case "$REPO_ACTION" in
    disable)
      should_disable="yes"
      ;;
    keep)
      should_disable="no"
      ;;
    ask)
      if [[ "$NON_INTERACTIVE" == "true" ]]; then
        should_disable="yes"
        echo "Pronađen repo.purs.rs i uključen --non-interactive: podrazumevano ga isključujem."
      elif [[ -t 0 ]]; then
        echo "Pronađen problematičan APT repo (repo.purs.rs)."
        read -r -p "Da li da ga privremeno isključim? [Y/n]: " odgovor
        case "$odgovor" in
          ""|y|Y|yes|YES|Yes)
            should_disable="yes"
            ;;
          *)
            should_disable="no"
            ;;
        esac
      else
        should_disable="yes"
        echo "Pronađen repo.purs.rs, bez interaktivnog terminala: podrazumevano ga isključujem."
      fi
      ;;
  esac

  if [[ "$should_disable" != "yes" ]]; then
    echo "repo.purs.rs ostaje aktivan po vašem izboru."
    return 0
  fi

  echo "Privremeno isključujem repo.purs.rs..."
  local file
  for file in "${repo_files[@]}"; do
    run_sudo sed -i '/repo\.purs\.rs/s/^\s*deb\s\+/# deb /' "$file"
    echo "  - Isključen unos u: $file"
  done
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
    --skip-apt)
      SKIP_APT="true"
      ;;
    --auto-disable-repo)
      REPO_ACTION="disable"
      ;;
    --skip-disable-repo)
      REPO_ACTION="keep"
      ;;
    --non-interactive)
      NON_INTERACTIVE="true"
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
  echo "Greška: konvertor.py nije pronađen pored install_system_wide.sh" >&2
  exit 1
fi

if [[ "$SKIP_APT" != "true" ]]; then
  if ! command -v apt >/dev/null 2>&1; then
    echo "Greška: apt nije pronađen. Koristite Debian/Ubuntu ili pokrenite sa --skip-apt." >&2
    exit 1
  fi

  echo "[1/5] Provera i instalacija sistemskih paketa..."
  disable_broken_purs_repo
  run_apt update
  run_apt install -y "${APT_PACKAGES[@]}"
else
  echo "[1/5] Preskačem apt install (--skip-apt)."
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
