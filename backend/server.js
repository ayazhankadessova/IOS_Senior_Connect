// server.js
require('dotenv').config()
const express = require('express')
const cors = require('cors')
const connectDB = require('./config/db')

const authRoutes = require('./routes/auth')
const lessonRoutes = require('./routes/lessons')
const progressRoutes = require('./routes/progress')

const app = express()

// Middleware
app.use(cors())
app.use(express.json())

// Connect to MongoDB
connectDB()

// Routes
app.use('/api/users', authRoutes)
app.use('/api/lessons', lessonRoutes)
app.use('/api/users/:userId/progress', progressRoutes)

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' })
})

// Initialize sample data
// require('./utils/sampleData').initializeSampleData()

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(500).json({ error: 'Something went wrong!' })
})

// Export for Vercel
module.exports = app

// Local development server
if (process.env.NODE_ENV !== 'production') {
  const PORT = process.env.PORT || 3000
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`)
  })
}
