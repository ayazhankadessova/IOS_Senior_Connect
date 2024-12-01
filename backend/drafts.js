// middleware/adminAuth.js
const adminAuth = (req, res, next) => {
  // This is a simple example. In production, use proper authentication
  const isAdmin = req.headers['admin-token'] === 'your-admin-secret'
  if (!isAdmin) {
    return res.status(403).json({ error: 'Admin access required' })
  }
  next()
}

module.exports = adminAuth

// Updated routes/events.js with admin protection
const express = require('express')
const router = express.Router()
const eventController = require('../controllers/eventController')
const adminAuth = require('../middleware/adminAuth')

// Public routes
router.get('/', eventController.getEvents)
router.post('/:eventId/join', eventController.joinEvent)
router.post('/:eventId/leave', eventController.leaveEvent)

// Admin protected routes
router.post('/', adminAuth, eventController.createEvent)
router.put('/:id', adminAuth, eventController.updateEvent)
router.delete('/:id', adminAuth, eventController.deleteEvent)

module.exports = router
