import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../services/api';

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  // 1. Declaramos la función primero
  const fetchStats = async () => {
    try {
      const response = await api.get('/api/dashboard/stats');
      setStats(response.data);
    } catch {
      // Quitamos la variable (err) para que el linter no se queje
      setError('Error cargando métricas. Verifica tu sesión.');
    }
  };

  // 2. Luego la usamos en el useEffect
  useEffect(() => {
    fetchStats();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('token');
    navigate('/login');
  };

  if (!stats && !error) return <div style={{ textAlign: 'center', marginTop: '50px' }}>Cargando métricas...</div>;

  return (
    <div style={{ maxWidth: '800px', margin: '50px auto', fontFamily: 'sans-serif' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
        <h2>Dashboard Principal</h2>
        <div>
          <Link to="/tasks" style={{ marginRight: '15px', color: '#007bff', textDecoration: 'none', fontWeight: 'bold' }}>Ir a mis Tareas</Link>
          <button onClick={handleLogout} style={{ padding: '8px 16px', background: '#dc3545', color: 'white', border: 'none', cursor: 'pointer', borderRadius: '4px' }}>Salir</button>
        </div>
      </div>

      {error ? (
        <p style={{ color: 'red', textAlign: 'center' }}>{error}</p>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '30px' }}>
          
          {/* Fila 1: Estadísticas de las Tareas del Usuario */}
          <div>
            <h3 style={{ borderBottom: '2px solid #eee', paddingBottom: '10px' }}>Mis Tareas</h3>
            <div style={{ display: 'flex', gap: '20px', justifyContent: 'space-between', textAlign: 'center', marginTop: '15px' }}>
              <div style={{ padding: '20px', background: '#f8f9fa', border: '1px solid #ddd', borderRadius: '8px', flex: 1 }}>
                <h4 style={{ margin: '0 0 10px 0' }}>Total</h4>
                <p style={{ fontSize: '28px', fontWeight: 'bold', margin: 0 }}>{stats.total || 0}</p>
              </div>
              <div style={{ padding: '20px', background: '#fff3cd', border: '1px solid #ffeeba', borderRadius: '8px', flex: 1 }}>
                <h4 style={{ margin: '0 0 10px 0' }}>Pendientes</h4>
                <p style={{ fontSize: '28px', fontWeight: 'bold', color: '#856404', margin: 0 }}>{stats.pendiente || 0}</p>
              </div>
              <div style={{ padding: '20px', background: '#d4edda', border: '1px solid #c3e6cb', borderRadius: '8px', flex: 1 }}>
                <h4 style={{ margin: '0 0 10px 0' }}>Completadas</h4>
                <p style={{ fontSize: '28px', fontWeight: 'bold', color: '#155724', margin: 0 }}>{stats.completada || 0}</p>
              </div>
            </div>
          </div>

          {/* Fila 2: Estadísticas Globales del Sistema */}
          <div>
            <h3 style={{ borderBottom: '2px solid #eee', paddingBottom: '10px' }}>Métricas del Sistema</h3>
            <div style={{ display: 'flex', justifyContent: 'center', textAlign: 'center', marginTop: '15px' }}>
              <div style={{ padding: '20px', background: '#e2e3e5', border: '1px solid #d6d8db', borderRadius: '8px', width: '100%' }}>
                <h4 style={{ margin: '0 0 10px 0' }}>👥 Total de Usuarios Registrados</h4>
                <p style={{ fontSize: '32px', fontWeight: 'bold', color: '#383d41', margin: 0 }}>
                  {stats.totalUsuarios || 0}
                </p>
              </div>
            </div>
          </div>

        </div>
      )}
    </div>
  );
};

export default Dashboard;