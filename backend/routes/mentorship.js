const express = require('express')
const router = express.Router()
const {
  createMentorshipRequest,
  getMentorshipRequests,
  getSingleMentorshipRequest,
  deleteMentorshipRequest,
} = require('../controllers/mentorshipController')

router.post('/requests/:userId', createMentorshipRequest)
router.get('/requests/:userId', getMentorshipRequests)
router.get(
  '/requests/:userId/mentorship/:requestId',
  getSingleMentorshipRequest
)
router.delete(
  '/requests/:userId/mentorship/:requestId',
  deleteMentorshipRequest
)

module.exports = router
