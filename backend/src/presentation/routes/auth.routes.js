const { Router } = require('express');
const authMiddleware = require('../middleware/auth');
const { authController } = require('../../config/container');

const router = Router();

router.post('/login', (req, res, next) => authController.login(req, res, next));
router.post('/logout', authMiddleware, (req, res, next) => authController.logout(req, res, next));
router.post('/refresh', (req, res, next) => authController.refresh(req, res, next));

module.exports = router;
