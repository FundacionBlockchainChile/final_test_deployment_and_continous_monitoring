const express = require('express');
const client = require('prom-client');

const app = express();
const port = process.env.PORT || 8080;

// Habilita la recolección de métricas por defecto (CPU, memoria, etc.)
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

// Crea un contador para las peticiones totales
const requestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

// Middleware para contar todas las peticiones
app.use((req, res, next) => {
  res.on('finish', () => {
    requestCounter.inc({ 
      method: req.method, 
      route: req.path,
      status_code: res.statusCode 
    });
  });
  next();
});

// Endpoint de la API de ejemplo
app.get('/api/barcos', (req, res) => {
  const barcos = [
    { id: 1, nombre: 'El Veloz', tipo: 'Carguero' },
    { id: 2, nombre: 'La Sirena', tipo: 'Pesquero' },
  ];
  res.json(barcos);
});

// Endpoint para exponer las métricas a Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.listen(port, () => {
  console.log(`Servicio de barcos escuchando en http://localhost:${port}`);
}); 