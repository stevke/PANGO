# PANGO konvertor - quick reference

## Pokretanje

```bash
python3 konvertor.py [OPCIJE] ulaz [izlaz]
```

- `ulaz`: ulazni `.lis` / `.txt` fajl
- `izlaz` (opciono): izlazni PDF; ako se ne navede, koristi se `ulaz.pdf`

## Najčešće opcije

| Opcija | Podrazumevano | Primer |
|---|---|---|
| `--encoding` | `auto` | `--encoding iso-8859-2` |
| `--font-size` | `10` | `--font-size 8` |
| `--margin` | `1cm` | `--margin 5mm` |
| `--orientation` | `portrait` | `--orientation landscape` |
| `--paper-size` | `A4` | `--paper-size A3` |

## Primeri

```bash
python3 konvertor.py izvestaj.lis
python3 konvertor.py velika_tabela.txt --orientation landscape --paper-size A3 --font-size 8
python3 konvertor.py ulaz.txt gotov_dokument.pdf --encoding cp852
```

## Sistemska instalacija (svi korisnici)

### Debian/Ubuntu

```bash
sudo ./install_debian_system_wide.sh
```

### openSUSE (Leap/Tumbleweed)

```bash
sudo ./install_opensuse_system_wide.sh
```

Kompatibilnost: `install_system_wide.sh` je alias za Debian skriptu.

## Mini check-list (posle instalacije)

```bash
which konvertor
konvertor --help
konvertor /putanja/do/fajla.lis --encoding iso-8859-2
```

## Troubleshooting

### `konvertor: command not found`

```bash
ls -l /usr/local/bin/konvertor
```

Ako fajl ne postoji, pokreni installer ponovo.

### `ModuleNotFoundError: No module named 'weasyprint'`

```bash
sudo ./install_debian_system_wide.sh --skip-apt
# ili
sudo ./install_opensuse_system_wide.sh --skip-zypper
```

### Greška za Pango/Cairo biblioteke

```bash
# Debian/Ubuntu
sudo apt update && sudo apt install -y libcairo2 libpango-1.0-0 libpangoft2-1.0-0 libgdk-pixbuf-2.0-0 libffi-dev shared-mime-info fonts-dejavu-core fonts-liberation

# openSUSE
sudo zypper refresh && sudo zypper install -y libcairo2 libpango-1_0-0 libgdk_pixbuf-2_0-0 libharfbuzz0 libfribidi0 fontconfig libffi-devel shared-mime-info dejavu-fonts liberation-fonts
```

## Release notes template

Za naredne GitHub release-ove koristi [RELEASE_NOTES_TEMPLATE.md](RELEASE_NOTES_TEMPLATE.md).

Brži način:

```bash
./release.sh create v1.1.1
# ili
./release.sh edit v1.1.0
```

