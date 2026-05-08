const { Router } = require('express');
const authMiddleware = require('../middleware/auth');
const { gpsPointsController } = require('../../config/container');

const router = Router();

router.use(authMiddleware);

router.post('/batch', (req, res, next) => gpsPointsController.batch(req, res, next));

module.exports = router;
