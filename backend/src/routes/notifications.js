const express = require('express');
const supabase = require('../config/supabase');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

// GET /v1/notifications
router.get('/', async (req, res, next) => {
  try {
    let query = supabase
      .from('notifications')
      .select('*')
      .eq('driver_id', req.driver.id)
      .order('created_at', { ascending: false });

    if (req.query.unread === 'true') {
      query = query.eq('read', false);
    }

    const { data, error } = await query;

    if (error) throw error;

    return res.json(data || []);
  } catch (err) {
    next(err);
  }
});

// PATCH /v1/notifications/read-all
router.patch('/read-all', async (req, res, next) => {
  try {
    const { error } = await supabase
      .from('notifications')
      .update({ read: true })
      .eq('driver_id', req.driver.id)
      .eq('read', false);

    if (error) throw error;

    return res.json({ message: 'All notifications marked as read' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
