const Lesson = require('../models/Lesson')

exports.getLessons = async (req, res) => {
  try {
    const { category } = req.query
    const query = category ? { category } : {}
    const lessons = await Lesson.find(query)
    res.json(lessons)
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}

exports.createLesson = async (req, res) => {
  try {
    const lesson = new Lesson(req.body)
    await lesson.save()
    res.status(201).json(lesson)
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}

exports.getLessonById = async (req, res) => {
  try {
    const lesson = await Lesson.findOne({ lessonId: req.params.lessonId })
    if (!lesson) {
      return res.status(404).json({ error: 'Lesson not found' })
    }
    res.json(lesson)
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}
