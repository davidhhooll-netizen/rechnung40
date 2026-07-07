import Database from 'better-sqlite3';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const dataDir = path.join(__dirname, '../../../data');
const dbPath = path.join(dataDir, 'rechnung40.db');

fs.mkdirSync(dataDir, { recursive: true });

export const db = new Database(dbPath);
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

const schema = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf-8');
db.exec(schema);

const STANDARD_EINHEITEN = ['Stück', 'Pauschale', 'Stunde', 'Tag', 'm²', 'lfm', 'kg'];

const einheitenAnzahl = db.prepare('SELECT COUNT(*) AS anzahl FROM einheiten').get().anzahl;
if (einheitenAnzahl === 0) {
  const insert = db.prepare('INSERT INTO einheiten (name, sortierung) VALUES (?, ?)');
  const insertAlle = db.transaction((einheiten) => {
    einheiten.forEach((name, index) => insert.run(name, index));
  });
  insertAlle(STANDARD_EINHEITEN);
}
