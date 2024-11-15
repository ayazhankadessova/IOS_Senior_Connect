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

module.exports = mongoose.model('Lesson', lessonSchema)
