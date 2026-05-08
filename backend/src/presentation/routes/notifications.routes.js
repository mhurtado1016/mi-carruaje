const { Router } = require('express');
const authMiddleware = require('../middleware/auth');
const { notificationsController } = require('../../config/container');

const router = Router();

router.use(authMiddleware);

router.get('/', (req, res, next) => notificationsController.getAll(req, res, next));
router.patch('/read-all', (req, res, next) => notificationsController.readAll(req, res, next));

module.exports = router;
