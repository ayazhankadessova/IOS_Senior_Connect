// models/Lesson.js

const mongoose = require('mongoose')
const { CATEGORIES } = require('../config/constants')

const lessonSchema = new mongoose.Schema({
  category: {
    type: String,
    enum: Object.values(CATEGORIES),
    required: true,
  },
  lessonId: {
    type: String,
    required: true,
    unique: true,
  },
  title: String,
  description: String,
  videoUrl: String,
  order: Number,
  steps: [
    {
      stepId: String,
      title: String,
      description: String,
      actionItems: [
        {
          itemId: String,
          task: String,
          isRequired: Boolean,
        },
      ],
    },
  ],
  quiz: [
    {
      question: String,
      options: [String],
      correctAnswer: Number,
      explanation: String,
    },
  ],
})

// Use a try-catch block to handle potential model registration issues
let Lesson
try {
  // Check if model is already registered
  Lesson = mongoose.models.Lesson || mongoose.model('Lesson', lessonSchema)
} catch (error) {
  Lesson = mongoose.model('Lesson', lessonSchema)
}

module.exports = Lesson
