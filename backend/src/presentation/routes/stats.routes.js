const { Router } = require('express');
const authMiddleware = require('../middleware/auth');
const { statsController } = require('../../config/container');

const router = Router();

router.use(authMiddleware);

router.get('/driver/:id', (req, res, next) => statsController.getDriverStats(req, res, next));

module.exports = router;
