// api/index.js
require('dotenv').config()
const express = require('express')
const cors = require('cors')
const connectDB = require('../config/db')
const authRoutes = require('../routes/auth')
const lessonRoutes = require('../routes/lessons')
const progressRoutes = require('../routes/progress')
const eventRoutes = require('../routes/events')
const mentorshipRoutes = require('../routes/mentorship')
const limiter = require('../middleware/rateLimiter')

const app = express()

// Middleware
app.use(cors())
app.use(express.json())

// Routes
app.use('/api/', limiter)
app.use('/api/users', authRoutes)
app.use('/api/lessons', lessonRoutes)
app.use('/api/users/:userId/progress', progressRoutes)
app.use('/api/events', eventRoutes)
app.use('/api/mentorship', mentorshipRoutes)

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' })
})

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(500).json({ error: 'Something went wrong!' })
})

// Connect to database
connectDB().catch(console.error)

module.exports = app
