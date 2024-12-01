// scripts/initDb.js
require('dotenv').config()
const mongoose = require('mongoose')
const { initializeSampleData, clearSampleData } = require('../utils/sampleData')
const connectDB = require('../config/db')

const initializeDatabase = async () => {
  try {
    // Connect to database
    await connectDB()
    console.log('Connected to database')

    // Clear existing data if --clear flag is provided
    if (process.argv.includes('--clear')) {
      await clearSampleData()
    }

    // Initialize sample data
    await initializeSampleData()

    console.log('Database initialization complete')
    process.exit(0)
  } catch (error) {
    console.error('Database initialization failed:', error)
    process.exit(1)
  }
}

initializeDatabase()
