require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3003;
const JWT_SECRET = process.env.JWT_SECRET || 'supersecreto_para_desarrollo';

app.use(cors());
app.use(express.json());

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

// Middleware de Autenticación
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token requerido' });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Token inválido' });
    req.user = user;
    next();
  });
};

// Obtener estadísticas del usuario y totales del sistema - Ruta actualizada para el ALB de AWS
app.get('/api/dashboard/stats', authenticateToken, async (req, res) => {
  try {
    // 1. Obtener las tareas del usuario logueado
    const statsResult = await pool.query(`
      SELECT status, COUNT(*) as count 
      FROM tasks 
      WHERE user_id = $1 
      GROUP BY status
    `, [req.user.id]);
    
    // 2. Contar el total de usuarios registrados en el sistema
    const usersResult = await pool.query(`
      SELECT COUNT(*) as total_users FROM users
    `);
    
    // 3. Formatear la respuesta para el frontend
    const stats = { 
      total: 0, 
      pendiente: 0, 
      completada: 0, 
      totalUsuarios: parseInt(usersResult.rows[0].total_users) // Agregamos la nueva métrica aquí
    };
    
    statsResult.rows.forEach(row => {
        stats[row.status] = parseInt(row.count);
        stats.total += parseInt(row.count);
    });

    res.json(stats);
  } catch (err) {
    console.error("Error obteniendo estadísticas:", err);
    res.status(500).json({ error: 'Error obteniendo estadísticas' });
  }
});

app.listen(PORT, () => console.log(`Dashboard Service (Final) en puerto ${PORT}`));