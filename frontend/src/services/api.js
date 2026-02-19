import axios from 'axios';

const api = axios.create({
  // Se deja en blanco para que detecte automáticamente el dominio del ALB en AWS
  baseURL: '', 
});

// Interceptor para enviar el token en cada petición
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;