const express = require('express')
const router = express.Router()
const eventController = require('../controllers/eventController')
const validateEventData = require('../middleware/validateEvent')

// Admin routes for event management
router.post('/', validateEventData, eventController.createEvent)
router.put('/:id', eventController.updateEvent)
router.delete('/:id', eventController.deleteEvent)

// User routes for event interaction
router.get('/', eventController.getEvents)
router.post('/:eventId/join', eventController.joinEvent)
router.post('/:eventId/leave', eventController.leaveEvent)
router.get(
  '/:eventId/registration-status',
  eventController.checkRegistrationStatus
)
router.get('/registered', eventController.getRegisteredEvents)

module.exports = router
