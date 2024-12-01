// config/db.js
const mongoose = require('mongoose')

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      dbName: 'SeniorConnectDB',
      // Add reasonable timeouts
      connectTimeoutMS: 10000,
      socketTimeoutMS: 45000,
    })

    mongoose.connection.on('connected', () => {
      console.log('🎉 Connected to SeniorConnect Database')
      console.log(`📍 Database Host: ${conn.connection.host}`)
      console.log(`📚 Database Name: ${conn.connection.name}`)
    })

    mongoose.connection.on('error', (err) => {
      console.error('MongoDB connection error:', err)
    })

    mongoose.connection.on('disconnected', () => {
      console.log('Database disconnected')
    })

    // Handle graceful shutdown
    process.on('SIGINT', async () => {
      try {
        await mongoose.connection.close()
        console.log('Database connection closed through app termination')
        process.exit(0)
      } catch (err) {
        console.error('Error during database disconnection:', err)
        process.exit(1)
      }
    })

    return conn
  } catch (error) {
    console.error('Database connection failed:', error)
    process.exit(1)
  }
}

module.exports = connectDB

// const connectDB = async () => {
//   try {
//     await mongoose.connect(process.env.MONGODB_URI, {
//       useNewUrlParser: true,
//       useUnifiedTopology: true,
//       // Add these Cosmos DB specific options
//       maxPoolSize: 10,
//       serverSelectionTimeoutMS: 5000,
//       socketTimeoutMS: 45000,
//       // Set lower throughput options
//       writeConcern: {
//         w: 'majority',
//       },
//       retryWrites: false,
//       // Add connection options to reduce RU consumption
//       readPreference: 'secondaryPreferred',
//     })

//     // Optimize schemas for lower RU consumption
//     mongoose.set('autoIndex', false)

//     console.log('MongoDB connected successfully')
//   } catch (error) {
//     console.error('MongoDB connection error:', error)
//     process.exit(1)
//   }
// }
