# Uputstvo za Debian (konvertor.py)

Ovo je ažurirano uputstvo za rad sa više korisnika i pokretanje iz bilo kog foldera.

## Brzi checklist (Install → Test → Push)

Ako želite najkraći put:

1. **Install**
	- Debian: `./install_system_wide.sh --non-interactive`
	- openSUSE: prvo `zypper` paketi, zatim `./install_system_wide.sh --skip-apt --non-interactive`
2. **Test**
	- `konvertor --help`
	- `konvertor /putanja/do/fajla.lis --encoding iso-8859-2 --font-size 13 --margin 2mm --orientation portrait`
3. **Push**
	- `git add . && git commit -m "Opis izmene" && git push`

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

## Posebna sekcija: openSUSE 15.6 (drugi računar)

Ako se prijavite na drugi računar sa openSUSE 15.6, povežite projekat ovako:

### 1) Preuzimanje projekta sa GitHub-a

```bash
sudo zypper install -y git
git clone https://github.com/stevke/PANGO.git
cd PANGO
```

### 2) Instalacija sistemskih paketa (openSUSE)

```bash
sudo zypper install -y \
	python3 python3-pip python3-virtualenv \
	cairo pango gdk-pixbuf libffi-devel shared-mime-info
```

### 3) Lokalno pokretanje (preporučeno)

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install weasyprint
./.venv/bin/python konvertor.py RPLFD15.00 --encoding iso-8859-2 --font-size 13 --margin 2mm --orientation portrait
```

### 4) Opciono: globalna komanda `konvertor` i na openSUSE

`install_system_wide.sh` koristi `apt`, pa na openSUSE pokrenite ga sa `--skip-apt`:

```bash
./install_system_wide.sh --skip-apt --non-interactive
```

Posle toga radi iz bilo kog foldera:

```bash
konvertor /putanja/do/fajla.lis --encoding iso-8859-2 --font-size 13 --margin 2mm --orientation portrait
```

### 5) Sinhronizacija izmena između računara

Na drugom računaru:

```bash
git pull
```

Za slanje vaših novih izmena nazad na GitHub:

```bash
git add .
git commit -m "Izmene sa openSUSE računara"
git push
```

### 6) Brza provera na openSUSE

Ako želite da odmah proverite da je sve ispravno podešeno:

```bash
python3 -c "from weasyprint import HTML; print('OK')"
konvertor --help
```

Ako koristite samo lokalni `.venv` (bez globalnog launchera), umesto `konvertor --help` koristite:

```bash
./.venv/bin/python konvertor.py --help
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

## Rollback (detaljno)

Ova sekcija pokriva kako da bezbedno vratite izmene kada nešto pođe po zlu.

### Brza tabela: situacija → komanda

| Situacija | Preporučena komanda |
|---|---|
| Odbaci necommitovane izmene u praćenim fajlovima | `git restore .` |
| Obriši nove fajlove/foldere koji nisu u Git-u | `git clean -fd` |
| Vrati poslednji lokalni commit, ali zadrži izmene | `git reset --soft HEAD~1` |
| Vrati poslednji lokalni commit i odbaci izmene | `git reset --hard HEAD~1` |
| Poništi već push-ovan commit (bez prepisivanja istorije) | `git revert <COMMIT_ID> && git push` |
| Poništi poslednja 2 commit-a (push-ovana istorija) | `git revert HEAD~2..HEAD && git push` |
| Vrati granu na stari commit i prepiši remote istoriju | `git reset --hard <COMMIT_ID> && git push --force-with-lease origin main` |
| Rekreiraj lokalni Python env (`.venv`) | `rm -rf .venv && python3 -m venv .venv && source .venv/bin/activate && pip install --upgrade pip weasyprint` |
| Vrati sistemsku instalaciju na trenutno stanje repoa | `./install_system_wide.sh --non-interactive` |

Napomena: Za timski rad uvek prvo birajte `git revert`, a `force-with-lease` koristite samo kad je neophodno.

### 0) Pre rollback-a: proverite stanje

```bash
git status
git log --oneline -n 10
```

Time vidite da li imate necommitovane izmene i koji commit želite da vratite.

### 1) Rollback necommitovanih izmena (lokalno)

Ako želite da odbacite izmene u svim fajlovima koje još niste commit-ovali:

```bash
git restore .
```

Ako želite i da obrišete nove (untracked) fajlove/foldere:

```bash
git clean -fd
```

Pažnja: ovo je destruktivno i ne može lako da se vrati.

### 2) Rollback poslednjeg commit-a koji NIJE push-ovan

Zadržava izmene u radnom direktorijumu (da ih popravite i commit-ujete ponovo):

```bash
git reset --soft HEAD~1
```

Ako želite da potpuno odbacite i commit i sadržaj:

```bash
git reset --hard HEAD~1
```

### 3) Rollback commit-a koji JE već push-ovan (preporučeno: `revert`)

Najbezbednije je da ne prepisujete istoriju, nego da dodate novi commit koji poništava stari:

```bash
git revert <COMMIT_ID>
git push
```

Ako želite poništavanje više commit-a odjednom (primer: poslednja 2):

```bash
git revert HEAD~2..HEAD
git push
```

### 4) Rollback na tačno određeni commit i ponovno objavljivanje

Prvo pređite na željeni commit lokalno:

```bash
git checkout <COMMIT_ID>
```

Ako je taj commit dobar, vratite se na `main` i resetujte je na taj commit:

```bash
git checkout main
git reset --hard <COMMIT_ID>
```

Ako je to već bilo push-ovano na GitHub, za ovakav rollback treba force push:

```bash
git push --force-with-lease origin main
```

Ovo prepisuje istoriju grane; koristite samo kad ste sigurni i tim je usaglašen.

### 5) Rollback sistemske instalacije `konvertor` na staru verziju

Pošto globalna instalacija uzima kod iz trenutnog projekta, rollback je:

1. Vratite Git repo na željeni commit (npr. pomoću `git checkout <COMMIT_ID>` ili `git reset --hard <COMMIT_ID>`).
2. Ponovo instalirajte sistemsku verziju:

```bash
./install_system_wide.sh --non-interactive
```

Time se osvežava `/opt/konvertor/konvertor.py`, `.venv` i launcher.

### 6) Rollback lokalnog `.venv` okruženja

Ako sumnjate da je problem u Python paketima, najčistije je kreirati novo lokalno okruženje:

```bash
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install weasyprint
```

### 7) Brza “sigurna” strategija rollback-a

Ako niste sigurni šta da uradite, koristite ovaj redosled:

1. `git status` i `git log --oneline -n 10`
2. Za push-ovane izmene koristite `git revert <COMMIT_ID>` (ne `reset --hard` + force push)
3. Testirajte lokalno (`konvertor --help` i test konverzija)
4. `git push`

## Napomena za grešku `Exit Code: 127`

`127` znači **command not found**. To se dešava kada se pokrene:

```bash
konvertor.py ...
```

umesto preko odgovarajuće komande (`konvertor`, `python3 konvertor.py` ili `./.venv/bin/python konvertor.py`).
