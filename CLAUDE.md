# Rechnungs-App (rechnung40) — Projektkontext für Claude Code

## Vision (Gesamtbild)

Eine **browserbasierte** Web-App (zunächst Desktop, später ggf. mobiltauglich) für Rechnungsstellung und Dokumentenverwaltung. Ziel: das Beste aus Softwarenetz (Briefpapier-Anpassung), Lexware Office (flexible Datumsfelder, Layout) und den Anforderungen aus der Baubranche vereinen. Module:

1. **Rechnungsmodul** mit bis zu 10 Mandanten (= eigene Briefpapiere) — **AKTUELLER FOKUS**
2. **Dokumentenablage** (KI kommt erst später)
3. **E-Mail-Versand** von Rechnungen mit gesonderter Archivierung
4. **PDF-Tools**: Konvertierung und Textbearbeitung bestehender PDFs

**Wichtig: Zuerst wird das komplette Rechnungsprogramm gebaut. KI vorerst außen vor. Die App muss zuverlässig PDFs erzeugen können — das hat hohe Priorität.**

## Tech-Stack

- Frontend: React + Vite
- Backend: Node.js + Express
- Datenbank: SQLite (Datei-basiert, einfaches Backup)
- PDF-Erzeugung: serverseitig (z. B. Puppeteer/HTML-zu-PDF oder pdf-lib)
- Styling: schlicht, hell, funktional — kein aufwendiges Design nötig

## Grundlayout

Desktop-Layout mit Seitenleiste links. Bereiche:
- **Dashboard** (Startseite)
- **Rechnungen / Angebote** (inkl. Kunden und Mandanten)
- **Dokumente** (kommt später)
- **PDF-Tools** (kommt später)

### Dashboard (Startseite)
- Mandant auswählen -> zeigt Rechnungs- und Angebotsübersicht dieses Mandanten
- Alternativ nach Kunde wählen -> zeigt alle Rechnungen/Angebote dieses Kunden **mandantenübergreifend** (ein Kunde kann bei mehreren Mandanten Belege haben)

## Datenmodell (Kern)

- **Mandant** (max. 10): Name, Adresse, Logo (Upload in **allen gängigen Formaten**: PNG, JPG, SVG, GIF, BMP, WEBP), Bankverbindung(en) (IBAN, BIC, Bank), Steuernummer, USt-ID, E-Mail, Telefon, Nummernkreis (Präfix + fortlaufende Nummer), Fußzeilen-Konfiguration (2/3/4 Spalten, s. u.), optional Unterschrift-Grafik, optional "Bar erhalten"-Stempel. Jeder Mandant = ein Briefpapier.
- **Kunde**: Firma/Name, Ansprechpartner, Adresse, E-Mail, Telefon, optional USt-ID, Memofeld/Notizen. Kunden sind die Basis — ein Beleg wird immer für einen Kunden geschrieben. Kunde kann bei mehreren Mandanten Belege haben.
- **Beleg** (Rechnung ODER Angebot): gehört zu genau einem Mandanten und einem Kunden. Typ (Angebot/Rechnung), Nummer (aus Nummernkreis des Mandanten), Datum, Datums-/Leistungszeitraum-Feld (s. u.), Freitext oben, Positionen, Zwischentexte, Freie Notizen, Freitext/Schlusstext unten, Status.
- **Position**: Beschreibung, Menge, Einheit, Einzelpreis netto, MwSt-Satz (19 % / 7 % / 0 % / §13b), Zeilensumme. Zwei Mengen-Modi (s. u.). Darunter beliebig viele **Subpositionen** (reine Beschreibungszeilen ohne Preis, eingerückt).
- **Positionskatalog**: Jede eingegebene Position wird gespeichert; bei Neueingabe erscheinen Vorschläge (Autocomplete) mit Text, Einheit, Preis — editierbar.
- **Einheiten**: vordefiniert (Stück, Pauschale, Stunde, Tag, m², lfm, kg), erweiterbar direkt im Dropdown.

## Wichtige Funktionsdetails

### Prozent-/Teilleistungs-Positionen (Baubranche!)
Sehr wichtig für Kostenvoranschläge, die an Banken zur Finanzierung geschickt werden. Jede Position hat zwei Mengen-Modi, umschaltbar:
1. **Menge × Einzelpreis** (klassisch)
2. **Prozentualer Anteil an einem Gesamtwert**: Position hat einen Gesamtwert (z. B. "Mauerwerk-Abriss = 10.000 €"), und es wird nur ein Prozentsatz davon abgerechnet (z. B. 20 % -> 2.000 €). Der Prozentsatz ist frei eingebbar, die Zeilensumme berechnet sich automatisch (Gesamtwert × Prozent). Sowohl Gesamtwert als auch abgerechneter Prozentsatz sollen auf dem PDF erkennbar sein.

### Datums-/Leistungszeitraum-Feld (wie Lexware, oben rechts)
Pro Beleg wählbar, welche Datumsangaben oben rechts erscheinen — Felder sollen **ein-/ausblendbar und anpassbar** sein (nicht wie bei Softwarenetz starr):
1. **Kein Lieferdatum**
2. **Lieferdatum** — ein Datum per Kalender-Picker
3. **Leistungszeitraum** — von/bis mit zwei Kalender-Pickern
Nicht benötigte Datumsfelder oben rechts löschbar/anpassbar.

### Angebote -> Rechnungen
Angebote sollen sich später per Klick in eine Rechnung umwandeln lassen (Positionen werden übernommen, neue Rechnungsnummer wird vergeben).

### Rechnungsnummern
- Nummernkreis pro Mandant, automatische Vergabe.
- **Warnung bei doppelter Rechnungsnummer** innerhalb desselben Mandanten (vor dem Speichern/Finalisieren prüfen und warnen).

### Fußzeile
Konfigurierbar mit **2, 3 oder 4 Spalten** (Vorbild: Softwarenetz / "Rechnung 10"). Typische Inhalte: Anschrift, Bankverbindung, Steuernummer/USt-ID, Kontakt. Pro Mandant einstellbar.

### Zwischentexte & Notizen
- Verschiedene **Zwischentexte** unterhalb der Positionen/Summe einfügbar (Textbausteine).
- **Freie Notizen** pro Beleg.

### Unterschrift & Stempel
- Unterschrift als Grafik hochladbar (bestimmtes Format, z. B. PNG mit Transparenz) und auf den Beleg setzbar -> Selbst-Signatur vor dem PDF-Export.
- Klassischer **"Bar erhalten"-Stempel** direkt auf die Rechnung setzbar, bevor sie als PDF gespeichert wird.

### Rechnungslayout
Orientiert sich an der Referenzdatei `referenz/rechnung-10.pdf` (falls vorhanden). Klassisch deutsch: Briefkopf mit Logo/Absender, Empfängeradresse im Fensterbereich, Belegdaten rechts, Positionstabelle (Pos. | Beschreibung inkl. Subpositionen | Menge/% | Einheit | Einzelpreis/Gesamtwert | Gesamt), Summenblock (Netto, MwSt getrennt nach Sätzen, Brutto), Freitexte/Zwischentexte, Fußzeile.

### Übersicht & Suche
- Belegliste filterbar pro Mandant und pro Kunde, Typ (Angebot/Rechnung), Zeitraum, Status
- Volltextsuche (Nummer, Kunde, Positionstexte)
- Summen: offen / bezahlt, pro Monat / Jahr
- Status per Klick umschaltbar (bezahlt/offen)

## Konventionen

- Oberfläche: **Deutsch**
- Beträge: deutsches Format (1.234,56 €), intern in Cent (Integer) rechnen (keine Rundungsfehler)
- Datumsformat: TT.MM.JJJJ
- Rechnungsnummern nach Finalisierung nie ändern
- Alle erzeugten PDFs werden gespeichert (Basis für spätere Dokumentenablage)
- Geschäftslogik kommentieren

## Etappenplan

- **Etappe 0**: Grundgerüst (Setup, Layout mit Seitenleiste, DB) [x]
  - React+Vite-Frontend (`frontend/`), Express-Backend (`backend/`), SQLite-DB (`data/rechnung40.db`) via better-sqlite3.
  - Desktop-Layout mit Seitenleiste (Dashboard, Rechnungen/Angebote, Dokumente, PDF-Tools); Dokumente/PDF-Tools als Platzhalter.
  - Alle Tabellen aus dem Datenmodell angelegt (`backend/src/db/schema.sql`); Einheiten-Tabelle mit den 7 Standardeinheiten befüllt.
  - `npm run dev` im Projekt-Root startet Frontend (Vite, Port 5173) und Backend (Express, Port 3001) gemeinsam via `concurrently`; Vite proxied `/api` zum Backend.
- **Etappe 1**: Mandanten- (inkl. Logo, Fußzeilen-Spalten, Bankdaten) und Kundenverwaltung [ ]
- **Etappe 2**: Belege schreiben — Positionen mit Autocomplete, Einheiten, Subpositionen, Prozent-/Teilleistungs-Modus, Datums-/Leistungszeitraum-Feld, Zwischentexte, Notizen, Nummernkreis mit Dublettenwarnung, PDF-Erzeugung [ ]
- **Etappe 3**: Dashboard + Übersicht (nach Mandant und nach Kunde), Suche, Summen, Status [ ]
- **Etappe 4**: Angebote und Umwandlung Angebot -> Rechnung [ ]
- **Etappe 5**: Unterschrift-Upload + "Bar erhalten"-Stempel auf Beleg [ ]
- **Etappe 6**: E-Mail-Versand [ ]
- **Etappe 7**: Dokumentenablage (ohne KI) [ ]
- **Etappe 8**: KI-Funktionen (Ablage-Zuordnung, KI-Suche) [ ]
- **Etappe 9**: PDF-Tools (Konvertierung, Textbearbeitung, OCR) [ ]

Nach Abschluss einer Etappe: Haken hier setzen und kurz notieren, was gebaut wurde.