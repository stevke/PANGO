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

## Napomena za grešku `Exit Code: 127`

`127` znači **command not found**. To se dešava kada se pokrene:

```bash
konvertor.py ...
```

umesto preko odgovarajuće komande (`konvertor`, `python3 konvertor.py` ili `./.venv/bin/python konvertor.py`).
