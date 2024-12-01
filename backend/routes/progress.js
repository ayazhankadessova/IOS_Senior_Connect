const express = require('express')
const router = express.Router({ mergeParams: true }) // Important for accessing userId param
const progressController = require('../controllers/progressController')

router.post('/batch', progressController.updateBatchProgress)
router.get('/:category', progressController.getCategoryProgress)
router.post('/save-for-later', progressController.saveForLater)
router.post('/request-mentor', progressController.requestMentorHelp)
router.post('/quiz-score', progressController.updateQuizScore)
router.get('/total-completed', progressController.getTotalLessonsCompleted) // New route

module.exports = router
