require('dotenv').config()
const express = require('express')
const cors = require('cors')
const connectDB = require('./config/db')
const authRoutes = require('./routes/auth')
const lessonRoutes = require('./routes/lessons')
const progressRoutes = require('./routes/progress')
const eventRoutes = require('./routes/events')
const limiter = require('./middleware/rateLimiter')
// const initializeEvents = require('./utils/initializeEvents')
const mentorshipRoutes = require('./routes/mentorship')
const { initializeIoTLessons } = require('./utils/sampleIOT')

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

// Server startup logic
const startServer = async () => {
  try {
    console.log('🚀 Initializing SeniorConnect Server...')

    // Connect to database first
    await connectDB()
    console.log('Database initialization complete')

    // Then start the server
    const PORT = process.env.PORT || 3000
    app.listen(PORT, () => {
      console.log(
        `Server running in ${
          process.env.NODE_ENV || 'development'
        } mode on port ${PORT}`
      )
    })
    // try {
    //   await initializeIoTLessons()
    //   console.log(' initialization completed')
    // } catch (error) {
    //   console.error('Failed to initialize events:', error)
    // }
  } catch (err) {
    console.error('Failed to start server:', err)
    process.exit(1)
  }
}

// Start server if not in production (for local development)
if (process.env.NODE_ENV !== 'production') {
  startServer()
}

// Export for production (Vercel)
module.exports = app
