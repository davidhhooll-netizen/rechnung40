import { Navigate, Route, Routes } from 'react-router-dom'
import Layout from './components/Layout.jsx'
import Dashboard from './pages/Dashboard.jsx'
import Belege from './pages/Belege.jsx'
import Dokumente from './pages/Dokumente.jsx'
import PdfTools from './pages/PdfTools.jsx'

function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/belege" element={<Belege />} />
        <Route path="/dokumente" element={<Dokumente />} />
        <Route path="/pdf-tools" element={<PdfTools />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Layout>
  )
}

export default App
