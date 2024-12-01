// controllers/authController.js
const bcrypt = require('bcryptjs')
const User = require('../models/User')

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body
    const user = await User.findOne({ email })

    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' })
    }

    const isValid = await bcrypt.compare(password, user.password)
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid credentials' })
    }

    const userResponse = user.toObject()
    delete userResponse.password
    res.json(userResponse)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
}

exports.signup = async (req, res) => {
  try {
    const { name, email, password } = req.body
    const hashedPassword = await bcrypt.hash(password, 10)

    const user = new User({
      name,
      email,
      password: hashedPassword,
      progress: {
        smartphoneBasics: [],
        digitalLiteracy: [],
        socialMedia: [],
        iot: [],
      },
      overallProgress: {
        totalLessonsCompleted: 0,
        averageQuizScore: parseFloat((0.0).toFixed(2)),
        lastActivityDate: new Date(),
      },
      registeredEvents: [],
    })

    await user.save()
    const userResponse = user.toObject()
    delete userResponse.password
    res.status(201).json(userResponse)
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}
