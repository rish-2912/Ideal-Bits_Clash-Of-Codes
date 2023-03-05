import { Outlet, Navigate, useLocation } from "react-router-dom"
import AuthConsumer from './useAuth'

const AdminLoginAuth = () => {
  const { authedAdmin } = AuthConsumer()
  const location = useLocation()
  return (
    true ? <Outlet /> : <Navigate to="./adminLogin" state={{ from: location }} replace />
  )
}

export default AdminLoginAuth