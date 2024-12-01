const User = require('../models/User')
const Lesson = require('../models/Lesson')
const { calculateAverageQuizScore } = require('../utils/progressCalculator')

exports.updateBatchProgress = async (req, res) => {
  try {
    const { userId } = req.params
    const { category, lessonId, completedSteps, stepActions } = req.body

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ success: false })
    }

    // Find or create progress entry
    let lessonProgress = user.progress[category].find(
      (p) => p.lessonId === lessonId
    )

    // Store previous completion state
    const wasCompletedBefore = lessonProgress?.completed || false

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

    lessonProgress.lastAccessed = new Date()

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

      // Update totalLessonsCompleted if completion status changed
      if (!wasCompletedBefore && allRequiredCompleted) {
        user.overallProgress.totalLessonsCompleted += 1
        console.log(
          `Lesson completed! New total: ${user.overallProgress.totalLessonsCompleted}`
        )
      } else if (wasCompletedBefore && !allRequiredCompleted) {
        user.overallProgress.totalLessonsCompleted = Math.max(
          0,
          user.overallProgress.totalLessonsCompleted - 1
        )
        console.log(
          `Lesson uncompleted. New total: ${user.overallProgress.totalLessonsCompleted}`
        )
      }

      // Update last activity date
      user.overallProgress.lastActivityDate = new Date()
    }

    // Calculate total completed lessons across all categories
    const totalCompleted = Object.values(user.progress).reduce(
      (total, categoryProgress) => {
        return (
          total + categoryProgress.filter((lesson) => lesson.completed).length
        )
      },
      0
    )

    // Ensure overallProgress matches actual completed lessons count
    if (user.overallProgress.totalLessonsCompleted !== totalCompleted) {
      console.log(
        `Fixing totalLessonsCompleted: ${user.overallProgress.totalLessonsCompleted} -> ${totalCompleted}`
      )
      user.overallProgress.totalLessonsCompleted = totalCompleted
    }

    await user.save()
    res.status(200).json({
      success: true,
    })
  } catch (error) {
    console.error('Error updating progress:', error)
    res.status(400).json({ success: false })
  }
}

exports.getCategoryProgress = async (req, res) => {
  try {
    const { userId, category } = req.params
    const user = await User.findById(userId)

    if (!user) {
      return res.status(404).json({ error: 'User not found' })
    }

    res.status(200).json({
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

    console.log('here')

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

    console.log('here')

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
exports.updateQuizScore = async (req, res) => {
  try {
    console.log('Updating quiz score')
    const userId = req.params.userId
    const { lessonId, score, category } = req.body

    // Validate required fields
    if (!lessonId || score === undefined || !category) {
      return res.status(400).json({
        success: false,
        message: 'Please provide lessonId, score, and category',
      })
    }

    console.log(
      `Updating quiz score for: userId=${userId}, lessonId=${lessonId}, category=${category}, score=${score}`
    )

    // Find user and update the specific lesson's quiz score
    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      })
    }

    // Check if the category exists in user progress
    if (!user.progress[category]) {
      return res.status(400).json({
        success: false,
        message: `Invalid category: ${category}`,
      })
    }

    // Find the lesson progress
    const lessonProgress = user.progress[category].find(
      (progress) => progress.lessonId === lessonId
    )

    if (lessonProgress) {
      // Update existing progress
      lessonProgress.quizScores = [
        {
          score,
          attemptDate: new Date(),
        },
      ] // Only keep the latest score
      lessonProgress.lastAccessed = new Date()
    } else {
      // Create new progress entry
      user.progress[category].push({
        lessonId,
        completed: false,
        lastAccessed: new Date(),
        completedSteps: [],
        stepProgress: [],
        quizScores: [
          {
            score,
            attemptDate: new Date(),
          },
        ],
        savedForLater: false,
        needsMentorHelp: false,
      })
    }

    await user.save()
    return res.status(200).json({
      success: true,
      message: 'Quiz score updated successfully',
      data: user.progress[category].find(
        (progress) => progress.lessonId === lessonId
      ),
    })
  } catch (error) {
    console.error('Error in updateQuizScore:', error)
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    })
  }
}

exports.getTotalLessonsCompleted = async (req, res) => {
  try {
    const { userId } = req.params
    const user = await User.findById(userId)

    if (!user) {
      return res.status(404).json({ error: 'User not found' })
    }

    // Calculate total completed lessons across all categories
    const totalCompleted = Object.values(user.progress).reduce(
      (total, categoryProgress) => {
        return (
          total + categoryProgress.filter((lesson) => lesson.completed).length
        )
      },
      0
    )

    res.status(200).json({
      totalLessonsCompleted: totalCompleted,
    })
  } catch (error) {
    console.error('Error fetching total lessons:', error)
    res.status(400).json({ error: error.message })
  }
}
