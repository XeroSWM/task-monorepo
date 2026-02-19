require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3001;
const JWT_SECRET = process.env.JWT_SECRET || 'supersecreto_para_desarrollo';

app.use(cors());
app.use(express.json());

const pool = new Pool({ 
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false // Esencial para aceptar el certificado de seguridad de AWS
  }
});
// Inicializar tabla de usuarios
pool.query(`
  CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
`).catch(err => console.error("Error creando tabla users:", err));

// Registro de usuario - Ruta actualizada para el ALB de AWS
app.post('/api/auth/register', async (req, res) => {
  const { email, password } = req.body;
  try {
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    
    const newUser = await pool.query(
      'INSERT INTO users (email, password) VALUES ($1, $2) RETURNING id, email',
      [email, hashedPassword]
    );
    res.status(201).json({ message: 'Usuario creado', user: newUser.rows[0] });
  } catch (err) {
    if (err.code === '23505') return res.status(400).json({ error: 'El email ya existe' });
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// Login - Ruta actualizada para el ALB de AWS
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userResult.rows.length === 0) return res.status(401).json({ error: 'Credenciales inválidas' });

    const user = userResult.rows[0];
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) return res.status(401).json({ error: 'Credenciales inválidas' });

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '1h' });
    res.json({ token, user: { id: user.id, email: user.email } });
  } catch (err) {
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

app.listen(PORT, () => console.log(`Auth Service (Final) en puerto ${PORT}`));