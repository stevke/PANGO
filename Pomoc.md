# Konvertor LIS/TXT u PDF - Dokumentacija

Ova skripta konvertuje tekstualne izveštaje (često generisane starim DOS aplikacijama) u PDF format, uz očuvanje formatiranja, grafičkih karaktera (okvira tabela) i interpretaciju ESC/P kontrolnih kodova za štampače.

## Upotreba

```bash
python3 konvertor.py [OPCIJE] ulaz [izlaz]
```

## Argumenti

### Pozicioni argumenti

*   **`ulaz`**
    *   Putanja do ulaznog fajla koji se konvertuje (npr. `izvestaj.lis`, `fajl.txt`).
*   **`izlaz`** (Opciono)
    *   Putanja do izlaznog PDF fajla.
    *   Ako se ne navede, skripta automatski dodaje `.pdf` na ime ulaznog fajla (npr. `izvestaj.lis` -> `izvestaj.lis.pdf`).

### Opcioni argumenti (Zastavice)

| Argument | Opis | Podrazumevano |
| :--- | :--- | :--- |
| **`--encoding`** | Kodni raspored ulaznog fajla. Podržava `cp852`, `iso-8859-2`, `utf-8`, `windows-1250` itd. Ako je `auto`, skripta pokušava sama da detektuje. | `auto` |
| **`--font-size`** | Veličina fonta u pikselima. Za široke izveštaje koji ne staju u red, preporučuje se smanjenje na `7` ili `8`. | `10` |
| **`--margin`** | Margine stranice. Prihvata CSS jedinice. Može se zadati jedna vrednost za sve (npr. `1cm`) ili 4 vrednosti u formatu `"gore desno dole levo"` (npr. `"2cm 1cm 1cm 2.5cm"`). | `1cm` |
| **`--orientation`** | Orijentacija stranice: `portrait` (uspravno) ili `landscape` (položeno). | `portrait` |
| **`--paper-size`** | Format papira: `A4`, `A3`, `Letter`, `Legal`. | `A4` |

## Podržane Kontrolne Sekvence (ESC/P i ANSI)

Skripta automatski prepoznaje i obrađuje sledeće kontrolne kodove unutar teksta, simulirajući ponašanje matričnog štampača:

### Formatiranje teksta
*   **Bold:** `ESC E` (Uključi), `ESC F` (Isključi).
*   **Double Width (Dupla širina):** `ESC W1` (Uključi), `ESC W0` (Isključi).
    *   *Napomena:* Simulira se skaliranjem fonta, tako da tekst zauzima duplo više mesta horizontalno.
*   **Condensed (Zgusnuto):** `SI` (`\x0f`) ili `ESC SI` (`\x1b\x0f`).
    *   *Napomena:* Smanjuje širinu karaktera na ~60% (cca 17 CPI).
*   **Reset Condensed:** `DC2` (`\x12`) ili `ESC P`. Vraća na 10 CPI.
*   **Boje:** ANSI escape sekvence (npr. `\x1b[31m` za crveno).

### Formatiranje stranice
*   **Nova stranica (Form Feed):** `FF` (`\x0c`). Prekida trenutnu stranicu u PDF-u.
*   **Prored (Line Spacing):**
    *   `ESC 2`: 1/6 inča (Standardni prored).
    *   `ESC 0`: 1/8 inča (Zgusnuti prored).
*   **Leva margina:** `ESC l` + *n* (gde je *n* bajt koji definiše pomera u karakterima).

## Grafički karakteri (Tabele)

Skripta sadrži ugrađenu mapu za konverziju **CP852** (DOS Latin 2) grafičkih karaktera (okviri tabela, linije) u odgovarajuće Unicode karaktere. Ovo omogućava da tabele iz starih programa izgledaju ispravno u modernom PDF-u.

## Primeri korišćenja

**1. Osnovna konverzija (automatska detekcija encodinga):**
```bash
python3 konvertor.py izvestaj.lis
```

**2. Konverzija široke tabele (Landscape, A3 papir, manji font):**
```bash
python3 konvertor.py velika_tabela.txt --orientation landscape --paper-size A3 --font-size 8
```

**3. Forsiranje CP852 encodinga i definisanje izlaznog fajla:**
```bash
python3 konvertor.py ulaz.txt gotov_dokument.pdf --encoding cp852
```

**4. Podešavanje margina na 5 milimetara:**
```bash
python3 konvertor.py racun.txt --margin 5mm
```