import Sidebar from './Sidebar.jsx'

function Layout({ children }) {
  return (
    <div className="app-shell">
      <Sidebar />
      <main className="content">{children}</main>
    </div>
  )
}

export default Layout
