import { useEffect, useState } from 'react'

function Dashboard() {
  const [einheiten, setEinheiten] = useState(null)
  const [fehler, setFehler] = useState(null)

  useEffect(() => {
    fetch('/api/einheiten')
      .then((res) => {
        if (!res.ok) throw new Error('Antwort nicht ok')
        return res.json()
      })
      .then(setEinheiten)
      .catch(() => setFehler('Backend nicht erreichbar.'))
  }, [])

  return (
    <div className="page">
      <h1>Dashboard</h1>
      <p>
        Die Mandanten- und Kundenauswahl mit Belegübersicht folgt in einer
        späteren Etappe.
      </p>

      <div className="status-card">
        <h2>Verbindungstest</h2>
        {fehler && <p className="error">{fehler}</p>}
        {!fehler && !einheiten && <p>Lade Einheiten aus der Datenbank …</p>}
        {einheiten && (
          <>
            <p>Backend und Datenbank sind erreichbar. Vordefinierte Einheiten:</p>
            <ul className="tag-list">
              {einheiten.map((einheit) => (
                <li key={einheit.id}>{einheit.name}</li>
              ))}
            </ul>
          </>
        )}
      </div>
    </div>
  )
}

export default Dashboard
