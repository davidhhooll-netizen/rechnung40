import { NavLink } from 'react-router-dom'

const NAV_ITEMS = [
  { to: '/', label: 'Dashboard', end: true },
  { to: '/belege', label: 'Rechnungen / Angebote' },
  { to: '/dokumente', label: 'Dokumente' },
  { to: '/pdf-tools', label: 'PDF-Tools' },
]

function Sidebar() {
  return (
    <nav className="sidebar">
      <div className="sidebar-title">Rechnung40</div>
      <ul className="sidebar-nav">
        {NAV_ITEMS.map((item) => (
          <li key={item.to}>
            <NavLink
              to={item.to}
              end={item.end}
              className={({ isActive }) => (isActive ? 'active' : undefined)}
            >
              {item.label}
            </NavLink>
          </li>
        ))}
      </ul>
    </nav>
  )
}

export default Sidebar
