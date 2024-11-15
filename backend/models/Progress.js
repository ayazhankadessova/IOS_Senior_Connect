const mongoose = require('mongoose')

const progressSchema = new mongoose.Schema({
  lessonId: String,
  completed: Boolean,
  lastAccessed: Date,
  completedSteps: [String],
  stepProgress: [
    {
      stepId: String,
      completedActionItems: [String],
    },
  ],
  quizScores: [
    {
      score: Number,
      attemptDate: Date,
    },
  ],
  savedForLater: Boolean,
  needsMentorHelp: Boolean,
  mentorNotes: String,
})

module.exports = progressSchema
