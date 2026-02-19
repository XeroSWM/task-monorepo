require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3002;
const JWT_SECRET = process.env.JWT_SECRET || 'supersecreto_para_desarrollo';

app.use(cors());
app.use(express.json());

const pool = new Pool({ 
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false // Esencial para aceptar el certificado de seguridad de AWS
  }
});

// Inicializar tabla de tareas
pool.query(`
  CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'pendiente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
`).catch(err => console.error("Error creando tabla tasks:", err));

// Middleware de Autenticación
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token requerido' });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Token inválido' });
    req.user = user; // Guarda los datos del usuario (id) en la request
    next();
  });
};

// Obtener tareas del usuario logueado - Ruta actualizada para el ALB
app.get('/api/core/tasks', authenticateToken, async (req, res) => {
  try {
    const tasks = await pool.query('SELECT * FROM tasks WHERE user_id = $1 ORDER BY created_at DESC', [req.user.id]);
    res.json(tasks.rows);
  } catch (err) {
    res.status(500).json({ error: 'Error obteniendo tareas' });
  }
});

// Crear tarea - Ruta actualizada para el ALB
app.post('/api/core/tasks', authenticateToken, async (req, res) => {
  const { title, description } = req.body;
  try {
    const newTask = await pool.query(
      'INSERT INTO tasks (user_id, title, description) VALUES ($1, $2, $3) RETURNING *',
      [req.user.id, title, description]
    );
    res.status(201).json(newTask.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Error creando tarea' });
  }
});

// Actualizar estado de la tarea - Ruta actualizada para el ALB
app.put('/api/core/tasks/:id', authenticateToken, async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  try {
    const updatedTask = await pool.query(
      'UPDATE tasks SET status = $1 WHERE id = $2 AND user_id = $3 RETURNING *',
      [status, id, req.user.id]
    );
    if (updatedTask.rows.length === 0) return res.status(404).json({ error: 'Tarea no encontrada o sin permisos' });
    res.json(updatedTask.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Error actualizando tarea' });
  }
});

// Eliminar tarea - Ruta actualizada para el ALB
app.delete('/api/core/tasks/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
      const result = await pool.query('DELETE FROM tasks WHERE id = $1 AND user_id = $2 RETURNING *', [id, req.user.id]);
      if (result.rowCount === 0) return res.status(404).json({ error: 'Tarea no encontrada' });
      res.json({ message : 'Tarea eliminada correctamente' });
    } catch (err) {
      res.status(500).json({ error: 'Error eliminando tarea' });
    }
});

app.listen(PORT, () => console.log(`Core Service (Final) en puerto ${PORT}`));