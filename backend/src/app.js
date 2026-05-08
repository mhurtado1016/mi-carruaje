const express = require('express');
const cors = require('cors');

const authRouter = require('./presentation/routes/auth.routes');
const routesRouter = require('./presentation/routes/routes.routes');
const tripsRouter = require('./presentation/routes/trips.routes');
const gpsPointsRouter = require('./presentation/routes/gpsPoints.routes');
const notificationsRouter = require('./presentation/routes/notifications.routes');
const statsRouter = require('./presentation/routes/stats.routes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/v1/auth', authRouter);
app.use('/v1/routes', routesRouter);
app.use('/v1/trips', tripsRouter);
app.use('/v1/gps-points', gpsPointsRouter);
app.use('/v1/notifications', notificationsRouter);
app.use('/v1/stats', statsRouter);

app.use((err, req, res, next) => {
  console.error(err);
  const status = err.status || err.statusCode || 500;
  res.status(status).json({ error: err.message || 'Internal server error' });
});

module.exports = app;
