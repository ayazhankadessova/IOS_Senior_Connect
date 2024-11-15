const mongoose = require('mongoose')
const progressSchema = require('./Progress')

const userSchema = new mongoose.Schema({
  name: String,
  email: { type: String, unique: true },
  password: String,
  progress: {
    smartphoneBasics: [progressSchema],
    digitalLiteracy: [progressSchema],
    socialMedia: [progressSchema],
    iot: [progressSchema],
  },
  overallProgress: {
    totalLessonsCompleted: { type: Number, default: 0 },
    averageQuizScore: {
      type: Number,
      default: 0.0,
      get: (v) => parseFloat(v.toFixed(2)),
    },
    lastActivityDate: Date,
  },
})

userSchema.set('toJSON', {
  getters: true,
  transform: (doc, ret) => {
    ret.overallProgress.averageQuizScore = parseFloat(
      ret.overallProgress.averageQuizScore.toFixed(2)
    )
    return ret
  },
})

userSchema.set('toObject', {
  getters: true,
  transform: (doc, ret) => {
    ret.overallProgress.averageQuizScore = parseFloat(
      ret.overallProgress.averageQuizScore.toFixed(2)
    )
    return ret
  },
})

module.exports = mongoose.model('User', userSchema)
