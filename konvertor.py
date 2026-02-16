#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import os
import re
import argparse

def pokreni_iz_venv_ako_postoji():
    """
    Ako postoji lokalni .venv interpreter i skripta nije već pokrenuta iz njega,
    restartuje proces kroz .venv da bi sve Python zavisnosti bile dostupne.
    """
    putanja_skripte = os.path.abspath(__file__)
    direktorijum_projekta = os.path.dirname(putanja_skripte)
    venv_python = os.path.join(direktorijum_projekta, '.venv', 'bin', 'python')

    if os.environ.get('KONVERTOR_NO_VENV_REEXEC') == '1':
        return

    if not os.path.isfile(venv_python):
        return

    trenutni_python = os.path.abspath(sys.executable)
    ciljni_python = os.path.abspath(venv_python)

    if trenutni_python == ciljni_python:
        return

    os.execv(venv_python, [venv_python] + sys.argv)

pokreni_iz_venv_ako_postoji()

try:
    import html
except ImportError:
    sys.exit("Greška: Ova skripta zahteva Python 3. Modul 'html' nije pronađen.")

try:
    from weasyprint import HTML, CSS
except (ImportError, OSError) as e:
    sys.exit("Greška: Biblioteka 'weasyprint' ne može da se učita.\nDetalji: {}\n\nMogući uzroci:\n1. Biblioteka nije instalirana (pip install weasyprint)\n2. Nedostaju sistemske biblioteke (Pango/Cairo). Na Linux-u instalirajte: libpango-1.0-0, libpangoft2-1.0-0".format(e))

def mapiraj_dos_grafiku(tekst):
    """
    Konvertuje CP852/CP437 grafičke karaktere (okvire) u Unicode.
    Ovo je ključno za tabele u starim izveštajima.
    """
    mapa = {
        # Mapiranje ISO-8859-2 karaktera koji predstavljaju CP852 grafiku
        # (Kada se fajl sa CP852 grafikom čita kao ISO-8859-2)
        'Ä': '─', 'ł': '│', 
        'Ú': '┌', 'ż': '┐', 'Ŕ': '└', 'Ů': '┘',
        'Á': '┴', 'Â': '┬', 'Ă': '├', '´': '┤', 'Ĺ': '┼',
        
        # Duple linije (ISO-8859-2 -> CP852 Box Drawing)
        'Í': '═', 'ş': '║', 'É': '╔', 'ť': '╗', 'Ľ': '╝',
    }
    
    # Kreiramo tabelu za translaciju
    trans_tab = str.maketrans(mapa)
    
    return tekst.translate(trans_tab)

def detektuj_encoding(putanja):
    """
    Automatski detektuje encoding (UTF-8, CP852, ISO-8859-2).
    """
    try:
        with open(putanja, 'rb') as f:
            uzorak = f.read(4096)

        # 1. Provera za UTF-8
        try:
            uzorak.decode('utf-8')
            return 'utf-8'
        except UnicodeError:
            pass

        # 2. Heuristika CP852 vs ISO-8859-2
        # CP852: č=0x9F, ć=0x86 (u ISO-8859-2 su ovo kontrolni znaci)
        if b'\x9f' in uzorak or b'\x86' in uzorak:
            return 'cp852'
            
        # ISO-8859-2: č=0xE8, đ=0xF0 (u CP852 su ovo 'Ř' i '≡')
        if b'\xe8' in uzorak or b'\xf0' in uzorak:
            return 'iso-8859-2'
            
        return 'cp852' # Default fallback
    except Exception:
        return 'cp852'

def obradi_kontrolne_kodove(tekst):
    """
    Pretvara ANSI i ESC/P (Epson) kodove u HTML.
    Rešava paginaciju (\f) i stilizovanje (bold, double width).
    """
    # Regex za tokenizaciju:
    # \x0c          -> Form Feed (Nova strana)
    # \x1b\[.*?m    -> ANSI Escape sekvence (boje)
    # \x1bE         -> Bold ON
    # \x1bF         -> Bold OFF
    # \x1bW1        -> Double Width ON
    # \x1bW0        -> Double Width OFF
    # \x1bP         -> 10 CPI (ignorisaćemo ili reset)
    # \x12          -> DC2 (10 CPI)
    # \x1bl.        -> Left Margin (ESC l n)
    token_re = re.compile(r'(\x0c|\x1b\[[0-9;]*m|\x1bE|\x1bF|\x1bW1|\x1bW0|\x1bP|\x12|\x1b\x0f|\x0f|\x1b2|\x1b0|\x1bl[\s\S])')
    
    delovi = token_re.split(tekst)
    buffer = []
    
    # Počinjemo sa podrazumevanim blokom
    buffer.append('<div style="margin-left: 0ch;">')
    
    # Stanja
    stilovi = set() # 'bold', 'underline'
    boja = None
    double_width = False
    condensed = False
    line_height = None # None = default (1.2)
    left_margin = 0
    
    for deo in delovi:
        if not deo:
            continue
            
        if deo == '\x0c':
            # Ubacujemo prekid stranice
            buffer.append('</div><div style="break-before: page;"></div><div style="margin-left: {}ch;">'.format(left_margin))
            continue
            
        # ANSI kodovi
        if deo.startswith('\x1b['):
            try:
                sadrzaj = deo[2:-1]
                if not sadrzaj:
                    kodovi = [0]
                else:
                    kodovi = [int(k) for k in sadrzaj.split(';') if k.isdigit()]
                
                for k in kodovi:
                    if k == 0:
                        stilovi.clear()
                        boja = None
                        double_width = False
                    elif k == 1: stilovi.add('bold')
                    elif k == 4: stilovi.add('underline')
                    elif 30 <= k <= 37:
                        boje = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]
                        boja = boje[k-30]
            except ValueError:
                pass
            continue

        # ESC/P komande (iz hex dump-a)
        if deo == '\x1bE':
            stilovi.add('bold')
            continue
        if deo == '\x1bF':
            stilovi.discard('bold')
            continue
        if deo == '\x1bW1':
            double_width = True
            continue
        if deo == '\x1bW0':
            double_width = False
            continue
        if deo == '\x0f' or deo == '\x1b\x0f':
            condensed = True
            continue
        if deo == '\x1bP' or deo == '\x12':
            # Reset na 10 CPI (ignorišemo promenu fonta, samo resetujemo ako treba)
            condensed = False
            continue
        if deo == '\x1b2':
            line_height = 1.6 # 1/6 inča (standard)
            continue
        if deo == '\x1b0':
            line_height = 1.2 # 1/8 inča (zgusnuto)
            continue
        if deo.startswith('\x1bl'):
            try:
                left_margin = ord(deo[2])
                buffer.append('</div><div style="margin-left: {}ch;">'.format(left_margin))
            except IndexError:
                pass
            continue
            
        # Običan tekst (sada radimo escape ovde da ne bi pokvarili ESC parametre)
        deo = html.escape(deo)
        css_styles = []
        lh_val = line_height if line_height is not None else 1.2

        if 'bold' in stilovi: css_styles.append("font-weight: bold;")
        if 'underline' in stilovi: css_styles.append("text-decoration: underline;")
        if boja: css_styles.append("color: {};".format(boja))
        if double_width:
            # Simulacija duple širine: font-size 2em (za širinu) + scaleY 0.5 (za visinu)
            # Ovo osigurava da tekst zauzima duplo više mesta u redu (layout), a vizuelno ostaje iste visine.
            css_styles.append("font-size: 2em; display: inline-block; transform: scaleY(0.5); transform-origin: left bottom; line-height: {}em;".format(lh_val / 2.0))
        elif condensed:
            # Simulacija kondenzovanog teksta (~17cpi): font-size 0.6em (za širinu) + scaleY 1.66 (za visinu)
            css_styles.append("font-size: 0.6em; display: inline-block; transform: scaleY(1.6667); transform-origin: left bottom; line-height: {}em;".format(lh_val / 0.6))
        elif line_height is not None:
            css_styles.append("line-height: {};".format(lh_val))
        
        if css_styles:
            buffer.append('<span style="{}">{}</span>'.format(" ".join(css_styles), deo))
        else:
            buffer.append(deo)

    buffer.append('</div>')
    return "".join(buffer)

def konvertuj_lis_u_pdf(ulazni_fajl, izlazni_fajl, encoding='auto', font_size=10, margin="1cm", orientation="portrait", paper_size="A4"):
    try:
        if encoding == 'auto':
            encoding = detektuj_encoding(ulazni_fajl)
            print("Detektovan encoding: {}".format(encoding))

        # 1. Čitanje fajla (Pretpostavka CP852 za naša područja, ili CP437)
        with open(ulazni_fajl, 'r', encoding=encoding, errors='replace') as f:
            sirovi_tekst = f.read()

        # 2. Konverzija grafike i ANSI kodova
        # Prvo mapiramo grafiku dok je tekst još "čist" (opciono, zavisno od encodinga)
        tekst_unicode = mapiraj_dos_grafiku(sirovi_tekst)
        
        # Zatim konvertujemo kontrolne kodove u HTML
        sadrzaj_html = obradi_kontrolne_kodove(tekst_unicode)

        # 3. Priprema HTML omotača za PDF
        # Koristimo monospace font da bi se tabele poravnale
        html_dokument = """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                @page {{
                    size: {} {};
                    margin: {};
                }}
                body {{
                    font-family: 'Courier New', 'Liberation Mono', 'DejaVu Sans Mono', monospace;
                    font-size: {}px;
                    line-height: 1.2;
                    white-space: pre-wrap; /* Čuva razmake i nove redove */
                    background-color: white;
                    color: black;
                }}
            </style>
        </head>
        <body>{}</body>
        </html>
        """.format(paper_size, orientation, margin, font_size, sadrzaj_html)

        # 4. Generisanje PDF-a
        print("Generišem PDF: {}...".format(izlazni_fajl))
        HTML(string=html_dokument).write_pdf(izlazni_fajl)
        print("Uspešno završeno.")

    except FileNotFoundError:
        print("Greška: Fajl '{}' nije pronađen.".format(ulazni_fajl))
    except Exception as e:
        print("Došlo je do greške: {}".format(e))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Konvertor LIS/TXT izveštaja u PDF")
    parser.add_argument("ulaz", help="Putanja do ulaznog fajla")
    parser.add_argument("izlaz", nargs="?", help="Putanja do izlaznog fajla (opciono)")
    parser.add_argument("--encoding", default="auto", help="Encoding ulaznog fajla (npr. cp852, iso-8859-2, utf-8). Podrazumevano: auto")
    parser.add_argument("--font-size", type=int, default=10, help="Veličina fonta u px (podrazumevano: 10). Smanjite na 7-8 da stane na stranu.")
    parser.add_argument("--margin", default="1cm", help="Margine stranice. Format: '1cm' (sve) ili 'gore desno dole levo' (npr. '2cm 1cm 1cm 2cm'). Podrazumevano: 1cm")
    parser.add_argument("--orientation", default="portrait", choices=["portrait", "landscape"], help="Orijentacija stranice (portrait/landscape). Podrazumevano: portrait")
    parser.add_argument("--paper-size", default="A4", choices=["A4", "A3", "Letter", "Legal"], help="Format papira. Podrazumevano: A4")
    
    args = parser.parse_args()
    
    izlaz = args.izlaz
    if not izlaz:
        izlaz = args.ulaz + ".pdf"

    konvertuj_lis_u_pdf(args.ulaz, izlaz, encoding=args.encoding, font_size=args.font_size, margin=args.margin, orientation=args.orientation, paper_size=args.paper_size)
