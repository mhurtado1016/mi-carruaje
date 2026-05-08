const { Router } = require('express');
const authMiddleware = require('../middleware/auth');
const { tripsController } = require('../../config/container');

const router = Router();

router.use(authMiddleware);

router.post('/start', (req, res, next) => tripsController.start(req, res, next));
router.get('/history', (req, res, next) => tripsController.history(req, res, next));
router.get('/:id', (req, res, next) => tripsController.getById(req, res, next));
router.post('/:id/end', (req, res, next) => tripsController.end(req, res, next));
router.patch('/:id/pause', (req, res, next) => tripsController.pause(req, res, next));
router.patch('/:id/resume', (req, res, next) => tripsController.resume(req, res, next));

module.exports = router;
