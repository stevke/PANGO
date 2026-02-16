#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${PROJECT_DIR}/.venv"
REPO_ACTION="ask"
NON_INTERACTIVE="false"

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
Upotreba: ./install_debian.sh [OPCIJA]

Opcije:
  --auto-disable-repo  Automatski isključi problematičan repo.purs.rs (bez pitanja)
  --skip-disable-repo  Ne diraj repo.purs.rs (bez pitanja)
  --non-interactive    Ne postavlja pitanja; sa --auto/--skip bira to ponašanje,
                       a bez njih podrazumevano isključuje repo.purs.rs
  -h, --help           Prikaži ovu pomoć
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
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

if ! command -v apt >/dev/null 2>&1; then
  echo "Greška: Ovaj skript je namenjen Debian/Ubuntu sistemima (apt nije pronađen)." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Greška: python3 nije pronađen. Instalirajte ga pa pokrenite skript ponovo." >&2
  exit 1
fi

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
    if command -v sudo >/dev/null 2>&1; then
      sudo sed -i '/repo\.purs\.rs/s/^\s*deb\s\+/# deb /' "$file"
    else
      sed -i '/repo\.purs\.rs/s/^\s*deb\s\+/# deb /' "$file"
    fi
    echo "  - Isključen unos u: $file"
  done
}

disable_broken_purs_repo

echo "[1/4] Instaliram sistemske pakete..."
run_apt update
run_apt install -y "${APT_PACKAGES[@]}"

echo "[2/4] Kreiram Python virtualno okruženje u ${VENV_DIR}..."
python3 -m venv "${VENV_DIR}"

# shellcheck disable=SC1090
source "${VENV_DIR}/bin/activate"

echo "[3/4] Nadograđujem pip i instaliram WeasyPrint..."
python -m pip install --upgrade pip
pip install weasyprint

echo "[4/4] Brza provera WeasyPrint importa..."
python -c "from weasyprint import HTML; print('WeasyPrint OK')"

echo

echo "Instalacija završena."
echo "Pokretanje konvertora:"
echo "  source .venv/bin/activate"
echo "  python konvertor.py RPLFD15.00 --encoding iso-8859-2 --font-size 13 --margin 2mm --orientation portrait"
