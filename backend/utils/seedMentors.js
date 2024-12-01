const mongoose = require('mongoose')
// const Mentor = require('./models/mentor')

const mentorSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  expertise: [String],
})

const Mentor = mongoose.model('Mentor', mentorSchema)

// Replace with your MongoDB connection string
MONGODB_URI = ''
// Sample mentor data
const mentors = [
  {
    name: 'John Doe',
    email: 'john@example.com',
    expertise: ['Technology', 'Education'],
  },
  {
    name: 'Jane Smith',
    email: 'jane@example.com',
    expertise: ['Health', 'Social'],
  },
  {
    name: 'Mike Johnson',
    email: 'mike@example.com',
    expertise: ['Entertainment', 'Technology'],
  },
  {
    name: 'Sarah Williams',
    email: 'sarah@example.com',
    expertise: ['Education', 'Health'],
  },
  {
    name: 'David Brown',
    email: 'david@example.com',
    expertise: ['Social', 'Entertainment'],
  },
  {
    name: 'Emily Davis',
    email: 'emily@example.com',
    expertise: ['Technology', 'Health'],
  },
  {
    name: 'Michael Wilson',
    email: 'michael@example.com',
    expertise: ['Education', 'Social'],
  },
  {
    name: 'Emma Taylor',
    email: 'emma@example.com',
    expertise: ['Health', 'Entertainment'],
  },
  {
    name: 'Daniel Anderson',
    email: 'daniel@example.com',
    expertise: ['Social', 'Technology'],
  },
  {
    name: 'Olivia Thomas',
    email: 'olivia@example.com',
    expertise: ['Entertainment', 'Education'],
  },
]

async function seedMentors() {
  try {
    await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      dbName: 'SeniorConnectDB',
    })

    console.log('Connected to MongoDB')

    await Mentor.insertMany(mentors)

    console.log('Mentors seeded successfully')

    mongoose.disconnect()
  } catch (error) {
    console.error('Error seeding mentors:', error)
  }
}

seedMentors()
