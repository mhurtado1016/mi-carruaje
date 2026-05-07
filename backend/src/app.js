const express = require('express');
const cors = require('cors');

const authRouter = require('./routes/auth');
const routesRouter = require('./routes/routes');
const tripsRouter = require('./routes/trips');
const gpsPointsRouter = require('./routes/gpsPoints');
const notificationsRouter = require('./routes/notifications');
const statsRouter = require('./routes/stats');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/v1/auth', authRouter);
app.use('/v1/routes', routesRouter);
app.use('/v1/trips', tripsRouter);
app.use('/v1/gps-points', gpsPointsRouter);
app.use('/v1/notifications', notificationsRouter);
app.use('/v1/stats', statsRouter);

// Global error handler
app.use((err, req, res, next) => {
  console.error(err);
  const status = err.status || err.statusCode || 500;
  res.status(status).json({ error: err.message || 'Internal server error' });
});

module.exports = app;
