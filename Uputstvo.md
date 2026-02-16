# Uputstvo za Debian (konvertor.py)

Ovo je ažurirano uputstvo za rad sa više korisnika i pokretanje iz bilo kog foldera.

## Preporučeno: sistemska instalacija (multi-user)

Za vaš slučaj je najbolje da koristite globalnu komandu `konvertor`.

Instalacija:

```bash
./install_system_wide.sh
```

Varijante za `repo.purs.rs`:

```bash
./install_system_wide.sh --auto-disable-repo
./install_system_wide.sh --skip-disable-repo
./install_system_wide.sh --non-interactive
./install_system_wide.sh --non-interactive --skip-disable-repo
```

Posle instalacije, svaki korisnik može iz bilo kog foldera:

```bash
konvertor /putanja/do/fajla.lis --encoding iso-8859-2 --font-size 13 --margin 2mm --orientation portrait
```

Brza provera:

```bash
konvertor --help
```

## Gde se instalira

- skripta: `/opt/konvertor/konvertor.py`
- Python okruženje: `/opt/konvertor/.venv`
- launcher komanda: `/usr/local/bin/konvertor`

## Opciono: lokalna instalacija (samo za trenutni projekat)

Ako ne želite sistemsku instalaciju:

```bash
./install_debian.sh
```

ili ručno:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install weasyprint
```

Pokretanje lokalno:

```bash
./.venv/bin/python konvertor.py RPLFD15.00 --encoding iso-8859-2 --font-size 13 --margin 2mm --orientation portrait
```

## Upgrade (ažuriranje)

### Sistemska instalacija (preporučeno)

Kada izmenite `konvertor.py` ili želite novu verziju zavisnosti, iz direktorijuma projekta ponovo pokrenite:

```bash
./install_system_wide.sh --non-interactive
```

Ovo osvežava:

- `/opt/konvertor/konvertor.py`
- `/opt/konvertor/.venv` i `weasyprint`
- `/usr/local/bin/konvertor` launcher

### Lokalna instalacija

Ako koristite lokalni `.venv`, upgrade uradite ovako:

```bash
source .venv/bin/activate
python -m pip install --upgrade pip
pip install --upgrade weasyprint
```

## GitHub: prebacivanje koda (detaljno)

### 1) Priprema lokalnog projekta

Iz direktorijuma projekta pokrenite:

```bash
cd /home/stiv/AI/GEMINI/PANGO
git init
git branch -M main
```

Ako je ovo prvi commit na tom računaru, podesite autora:

```bash
git config --global user.name "stevke"
git config --global user.email "zrn_stevanovic@yahoo.com"
```

Ako želite samo za ovaj repo (bez `--global`):

```bash
git config user.name "stevke"
git config user.email "zrn_stevanovic@yahoo.com"
```

### 2) Prvi commit

```bash
git add .
git commit -m "Initial commit"
```

### 3) Otvaranje repozitorijuma na GitHub-u

1. Otvorite: `https://github.com/new`
2. Owner: `stevke`
3. Repository name: `PANGO`
4. Repo može biti `Public` ili `Private`
5. Nemojte čekirati `Add a README`, `.gitignore` i `license` (da ne bude konflikta pri prvom push-u)
6. Kliknite **Create repository**

### 4) Povezivanje lokalnog projekta sa GitHub repoom

```bash
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/stevke/PANGO.git
git push -u origin main
```

Nakon ovoga grana `main` je povezana sa `origin/main`.

### 5) Sledeća ažuriranja (svaki naredni put)

```bash
git add .
git commit -m "Opis izmene"
git push
```

### 6) Ako traži autentikaciju

- Za HTTPS koristite GitHub username + **Personal Access Token (PAT)** umesto lozinke.
- Alternativa je SSH ključ i SSH remote:

```bash
git remote set-url origin git@github.com:stevke/PANGO.git
git push -u origin main
```

### 7) Brza provera

```bash
git remote -v
git status
```

Ako je sve u redu, videćete `origin https://github.com/stevke/PANGO.git` i čist working tree posle commit-a/push-a.

### 8) Najčešće greške i brzo rešenje

**Greška:** `src refspec main does not match any`

```bash
git add .
git commit -m "Initial commit"
git branch -M main
git push -u origin main
```

**Greška:** `Repository not found`

```bash
git remote -v
git remote set-url origin https://github.com/stevke/PANGO.git
git push -u origin main
```

Proverite i da repo stvarno postoji na GitHub-u pod owner-om `stevke`.

**Greška:** `non-fast-forward`

```bash
git pull --rebase origin main
git push
```

**Greška:** autentikacija preko HTTPS ne prolazi

- Koristite GitHub username + PAT token (umesto lozinke), ili
- pređite na SSH remote:

```bash
git remote set-url origin git@github.com:stevke/PANGO.git
git push -u origin main
```

### 9) Jedna dijagnostička komanda (copy/paste)

Kada želite brz pregled stanja pre slanja na GitHub:

```bash
echo '--- STATUS ---' && git status --short --branch && echo && echo '--- BRANCHES ---' && git branch -vv && echo && echo '--- REMOTE ---' && git remote -v && echo && echo '--- LAST COMMIT ---' && git log --oneline -n 1
```

Ako je sve spremno za push, očekivano je:

- aktivna grana `main`
- `origin` pokazuje na `https://github.com/stevke/PANGO.git` (ili SSH varijantu)
- nema neočekivanih izmena u `git status`

## Napomena za grešku `Exit Code: 127`

`127` znači **command not found**. To se dešava kada se pokrene:

```bash
konvertor.py ...
```

umesto preko odgovarajuće komande (`konvertor`, `python3 konvertor.py` ili `./.venv/bin/python konvertor.py`).
