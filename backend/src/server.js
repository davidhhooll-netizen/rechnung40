import cors from 'cors';
import express from 'express';
import { db } from './db/index.js';

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.get('/api/einheiten', (req, res) => {
  const einheiten = db.prepare('SELECT id, name, sortierung FROM einheiten ORDER BY sortierung').all();
  res.json(einheiten);
});

app.listen(PORT, () => {
  console.log(`Backend läuft auf http://localhost:${PORT}`);
});
