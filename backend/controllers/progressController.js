const User = require('../models/User')
const Lesson = require('../models/Lesson')
const { calculateAverageQuizScore } = require('../utils/progressCalculator')

exports.updateBatchProgress = async (req, res) => {
  try {
    const { userId } = req.params
    const {
      category,
      lessonId,
      completedSteps,
      stepActions,
      savedForLater,
      needsMentorHelp,
      mentorNotes,
    } = req.body

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ error: 'User not found' })
    }

    // Find or create progress entry
    let lessonProgress = user.progress[category].find(
      (p) => p.lessonId === lessonId
    )

    if (!lessonProgress) {
      lessonProgress = {
        lessonId,
        completed: false,
        lastAccessed: new Date(),
        completedSteps: [],
        stepProgress: [],
        quizScores: [],
        savedForLater: false,
        needsMentorHelp: false,
      }
      user.progress[category].push(lessonProgress)
    }

    // Update step progress
    if (stepActions) {
      lessonProgress.stepProgress = stepActions.map(
        ({ stepId, actionItems }) => ({
          stepId,
          completedActionItems: actionItems,
        })
      )
    }

    if (completedSteps) {
      lessonProgress.completedSteps = completedSteps
    }

    // Update other fields
    if (savedForLater !== undefined) {
      lessonProgress.savedForLater = savedForLater
    }

    if (needsMentorHelp !== undefined) {
      lessonProgress.needsMentorHelp = needsMentorHelp
      if (mentorNotes) {
        lessonProgress.mentorNotes = mentorNotes
      }
    }

    // Check lesson completion
    const lesson = await Lesson.findOne({ lessonId })
    if (lesson) {
      const allRequiredCompleted = lesson.steps.every((step) => {
        const stepProgress = lessonProgress.stepProgress.find(
          (sp) => sp.stepId === step.stepId
        )
        return step.actionItems
          .filter((item) => item.isRequired)
          .every((item) =>
            stepProgress?.completedActionItems.includes(item.itemId)
          )
      })

      lessonProgress.completed = allRequiredCompleted
    }

    lessonProgress.lastAccessed = new Date()

    // Update overall progress
    user.overallProgress = {
      totalLessonsCompleted: Object.values(user.progress)
        .flat()
        .filter((p) => p.completed).length,
      averageQuizScore: calculateAverageQuizScore(user.progress),
      lastActivityDate: new Date(),
    }

    await user.save()
    res.json({
      progress: lessonProgress,
      overallProgress: user.overallProgress,
    })
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}

exports.getCategoryProgress = async (req, res) => {
  try {
    const { userId, category } = req.params
    const user = await User.findById(userId)

    if (!user) {
      return res.status(404).json({ error: 'User not found' })
    }

    res.json({
      categoryProgress: user.progress[category],
      overallProgress: user.overallProgress,
    })
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}

exports.saveForLater = async (req, res) => {
  try {
    const { userId } = req.params
    const { category, lessonId } = req.body

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ error: 'User not found' })
    }

    let lessonProgress = user.progress[category].find(
      (p) => p.lessonId === lessonId
    )

    if (!lessonProgress) {
      lessonProgress = {
        lessonId,
        completed: false,
        lastAccessed: new Date(),
        completedSteps: [],
        stepProgress: [],
        quizScores: [],
        savedForLater: true,
        needsMentorHelp: false,
      }
      user.progress[category].push(lessonProgress)
    } else {
      lessonProgress.savedForLater = true
    }

    await user.save()
    res.json({ progress: lessonProgress })
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}

exports.requestMentorHelp = async (req, res) => {
  try {
    const { userId } = req.params
    const { category, lessonId, notes } = req.body

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ error: 'User not found' })
    }

    let lessonProgress = user.progress[category].find(
      (p) => p.lessonId === lessonId
    )

    if (!lessonProgress) {
      lessonProgress = {
        lessonId,
        completed: false,
        lastAccessed: new Date(),
        completedSteps: [],
        stepProgress: [],
        quizScores: [],
        savedForLater: false,
        needsMentorHelp: true,
        mentorNotes: notes,
      }
      user.progress[category].push(lessonProgress)
    } else {
      lessonProgress.needsMentorHelp = true
      lessonProgress.mentorNotes = notes
    }

    await user.save()
    res.json({ progress: lessonProgress })
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}
