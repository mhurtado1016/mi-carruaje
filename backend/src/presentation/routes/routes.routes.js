const { Router } = require('express');
const authMiddleware = require('../middleware/auth');
const { routesController } = require('../../config/container');

const router = Router();

router.use(authMiddleware);

router.get('/today', (req, res, next) => routesController.getToday(req, res, next));
router.get('/:id', (req, res, next) => routesController.getById(req, res, next));
router.patch('/:id/status', (req, res, next) => routesController.updateStatus(req, res, next));

module.exports = router;
