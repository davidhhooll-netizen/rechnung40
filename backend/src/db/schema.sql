-- Rechnung40 Datenbankschema (Etappe 0: Grundgerüst)
-- Beträge werden durchgehend in Cent (Integer) gespeichert, um Rundungsfehler zu vermeiden.

-- Mandant: eigenes Briefpapier, max. 10 (wird auf Anwendungsebene geprüft)
CREATE TABLE IF NOT EXISTS mandanten (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  adresse TEXT,
  logo_pfad TEXT,
  steuernummer TEXT,
  ust_id TEXT,
  email TEXT,
  telefon TEXT,
  nummernkreis_praefix TEXT,
  nummernkreis_naechste_nummer INTEGER NOT NULL DEFAULT 1,
  fusszeile_spalten INTEGER NOT NULL DEFAULT 3 CHECK (fusszeile_spalten IN (2, 3, 4)),
  fusszeile_config TEXT, -- JSON: Inhalt je Fußzeilen-Spalte
  unterschrift_pfad TEXT,
  stempel_pfad TEXT,
  erstellt_am TEXT NOT NULL DEFAULT (datetime('now')),
  aktualisiert_am TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Bankverbindungen eines Mandanten (ein Mandant kann mehrere haben)
CREATE TABLE IF NOT EXISTS mandant_bankverbindungen (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  mandant_id INTEGER NOT NULL REFERENCES mandanten(id) ON DELETE CASCADE,
  bank_name TEXT,
  iban TEXT,
  bic TEXT,
  reihenfolge INTEGER NOT NULL DEFAULT 0
);

-- Kunde: Basis für Belege, kann bei mehreren Mandanten Belege haben
CREATE TABLE IF NOT EXISTS kunden (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  firma TEXT,
  ansprechpartner TEXT,
  adresse TEXT,
  email TEXT,
  telefon TEXT,
  ust_id TEXT,
  notizen TEXT,
  erstellt_am TEXT NOT NULL DEFAULT (datetime('now')),
  aktualisiert_am TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Einheiten für Positionen, direkt im Dropdown erweiterbar
CREATE TABLE IF NOT EXISTS einheiten (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  sortierung INTEGER NOT NULL DEFAULT 0
);

-- Positionskatalog: gespeicherte Positionen für Autocomplete-Vorschläge
CREATE TABLE IF NOT EXISTS positionskatalog (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  beschreibung TEXT NOT NULL,
  einheit_id INTEGER REFERENCES einheiten(id),
  einzelpreis_cent INTEGER,
  erstellt_am TEXT NOT NULL DEFAULT (datetime('now')),
  aktualisiert_am TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Beleg: Rechnung oder Angebot, gehört zu genau einem Mandanten und einem Kunden
CREATE TABLE IF NOT EXISTS belege (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  mandant_id INTEGER NOT NULL REFERENCES mandanten(id),
  kunde_id INTEGER NOT NULL REFERENCES kunden(id),
  typ TEXT NOT NULL CHECK (typ IN ('angebot', 'rechnung')),
  nummer TEXT,
  datum TEXT,
  datumsfeld_modus TEXT NOT NULL DEFAULT 'keins' CHECK (datumsfeld_modus IN ('keins', 'lieferdatum', 'leistungszeitraum')),
  lieferdatum TEXT,
  leistungszeitraum_von TEXT,
  leistungszeitraum_bis TEXT,
  freitext_oben TEXT,
  freitext_unten TEXT,
  notizen TEXT,
  status TEXT NOT NULL DEFAULT 'offen',
  erstellt_am TEXT NOT NULL DEFAULT (datetime('now')),
  aktualisiert_am TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Zwischentexte: Textbausteine unterhalb der Positionen/Summe
CREATE TABLE IF NOT EXISTS beleg_zwischentexte (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  beleg_id INTEGER NOT NULL REFERENCES belege(id) ON DELETE CASCADE,
  reihenfolge INTEGER NOT NULL DEFAULT 0,
  text TEXT
);

-- Position: Zeile eines Belegs, zwei Mengen-Modi (menge x preis ODER prozent vom gesamtwert)
CREATE TABLE IF NOT EXISTS positionen (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  beleg_id INTEGER NOT NULL REFERENCES belege(id) ON DELETE CASCADE,
  reihenfolge INTEGER NOT NULL DEFAULT 0,
  beschreibung TEXT,
  mengen_modus TEXT NOT NULL DEFAULT 'menge' CHECK (mengen_modus IN ('menge', 'prozent')),
  menge REAL,
  einheit_id INTEGER REFERENCES einheiten(id),
  einzelpreis_cent INTEGER,
  gesamtwert_cent INTEGER, -- nur bei mengen_modus = 'prozent'
  prozent REAL, -- nur bei mengen_modus = 'prozent'
  mwst_satz TEXT NOT NULL DEFAULT '19' CHECK (mwst_satz IN ('19', '7', '0', '13b')),
  zeilensumme_cent INTEGER
);

-- Subposition: reine Beschreibungszeile ohne Preis, eingerückt unter einer Position
CREATE TABLE IF NOT EXISTS subpositionen (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  position_id INTEGER NOT NULL REFERENCES positionen(id) ON DELETE CASCADE,
  reihenfolge INTEGER NOT NULL DEFAULT 0,
  beschreibung TEXT
);

CREATE INDEX IF NOT EXISTS idx_belege_mandant ON belege(mandant_id);
CREATE INDEX IF NOT EXISTS idx_belege_kunde ON belege(kunde_id);
CREATE INDEX IF NOT EXISTS idx_positionen_beleg ON positionen(beleg_id);
CREATE INDEX IF NOT EXISTS idx_subpositionen_position ON subpositionen(position_id);
CREATE INDEX IF NOT EXISTS idx_bankverbindungen_mandant ON mandant_bankverbindungen(mandant_id);
