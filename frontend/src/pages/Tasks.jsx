import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../services/api';

const Tasks = () => {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const navigate = useNavigate();

  // 1. Declaramos la función primero
  const fetchTasks = async () => {
    try {
      const response = await api.get('/api/core/tasks');
      setTasks(response.data);
    } catch (err) {
      console.error("Error obteniendo tareas", err);
    }
  };

  // 2. Luego la usamos en el useEffect
  useEffect(() => {
    fetchTasks();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const createTask = async (e) => {
    e.preventDefault();
    if (!title) return;
    try {
      await api.post('/api/core/tasks', { title, description });
      setTitle('');
      setDescription('');
      fetchTasks(); // Recargar lista
    } catch (err) {
      console.error("Error creando tarea", err);
    }
  };

  const toggleStatus = async (id, currentStatus) => {
    const newStatus = currentStatus === 'pendiente' ? 'completada' : 'pendiente';
    try {
      await api.put(`/api/core/tasks/${id}`, { status: newStatus });
      fetchTasks();
    } catch (err) {
      console.error("Error actualizando tarea", err);
    }
  };

  const deleteTask = async (id) => {
    if (!window.confirm('¿Seguro que quieres eliminar esta tarea?')) return;
    try {
      await api.delete(`/api/core/tasks/${id}`);
      fetchTasks();
    } catch (err) {
      console.error("Error eliminando tarea", err);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    navigate('/login');
  };

  return (
    <div style={{ maxWidth: '600px', margin: '50px auto', fontFamily: 'sans-serif' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
        <h2>Mis Tareas</h2>
        <div>
          <Link to="/" style={{ marginRight: '15px', color: '#007bff', textDecoration: 'none' }}>Volver al Dashboard</Link>
          <button onClick={handleLogout} style={{ padding: '5px 10px', background: '#dc3545', color: 'white', border: 'none', cursor: 'pointer' }}>Salir</button>
        </div>
      </div>

      {/* Formulario para crear tarea */}
      <form onSubmit={createTask} style={{ display: 'flex', flexDirection: 'column', gap: '10px', marginBottom: '30px', padding: '15px', background: '#f4f4f4', borderRadius: '8px' }}>
        <input 
          type="text" 
          placeholder="Título de la tarea" 
          value={title} 
          onChange={(e) => setTitle(e.target.value)} 
          required 
          style={{ padding: '8px' }}
        />
        <input 
          type="text" 
          placeholder="Descripción (opcional)" 
          value={description} 
          onChange={(e) => setDescription(e.target.value)} 
          style={{ padding: '8px' }}
        />
        <button type="submit" style={{ padding: '10px', background: '#28a745', color: 'white', border: 'none', cursor: 'pointer' }}>Agregar Tarea</button>
      </form>

      {/* Lista de tareas */}
      <div>
        {tasks.length === 0 ? <p>No hay tareas registradas.</p> : (
          tasks.map(task => (
            <div key={task.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px', borderBottom: '1px solid #eee', background: task.status === 'completada' ? '#f8f9fa' : '#fff' }}>
              <div>
                <h4 style={{ margin: '0 0 5px 0', textDecoration: task.status === 'completada' ? 'line-through' : 'none' }}>{task.title}</h4>
                <p style={{ margin: 0, fontSize: '14px', color: '#666' }}>{task.description}</p>
              </div>
              <div style={{ display: 'flex', gap: '10px' }}>
                <button 
                  onClick={() => toggleStatus(task.id, task.status)}
                  style={{ padding: '5px 10px', background: task.status === 'completada' ? '#ffc107' : '#17a2b8', color: 'white', border: 'none', cursor: 'pointer', borderRadius: '4px' }}
                >
                  {task.status === 'completada' ? 'Reabrir' : 'Completar'}
                </button>
                <button 
                  onClick={() => deleteTask(task.id)}
                  style={{ padding: '5px 10px', background: '#dc3545', color: 'white', border: 'none', cursor: 'pointer', borderRadius: '4px' }}
                >
                  Eliminar
                </button>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default Tasks;