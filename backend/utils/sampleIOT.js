const Lesson = require('../models/Lesson')

const iotLessons = [
  {
    category: 'iot',
    lessonId: 'bluetooth-basics',
    title: 'Bluetooth Basics',
    description:
      'Learn how to connect your smartphone to Bluetooth devices like speakers and headphones',
    videoUrl: 'https://www.youtube.com/watch?v=-f1-UUUWN0A',
    order: 1,
    steps: [
      {
        stepId: 'step1',
        title: 'Understanding Bluetooth',
        description: 'Learn what Bluetooth is and how it works',
        actionItems: [
          {
            itemId: '1',
            task: 'Watch the video about Bluetooth basics',
            isRequired: true,
          },
          {
            itemId: '2',
            task: "Locate the Bluetooth icon in your phone's settings",
            isRequired: true,
          },
          {
            itemId: '3',
            task: 'Turn Bluetooth on and off',
            isRequired: true,
          },
        ],
      },
      {
        stepId: 'step2',
        title: 'Connecting to a Device',
        description: 'Connect your phone to a Bluetooth device',
        actionItems: [
          {
            itemId: '4',
            task: 'Put your Bluetooth device in pairing mode',
            isRequired: true,
          },
          {
            itemId: '5',
            task: "Find the device in your phone's Bluetooth settings",
            isRequired: true,
          },
          {
            itemId: '6',
            task: 'Connect to the device',
            isRequired: true,
          },
        ],
      },
    ],
    quiz: [
      {
        question:
          'What should you do first when connecting to a Bluetooth device?',
        options: [
          'Turn off your phone',
          'Enable Bluetooth on your phone',
          'Call someone',
          'Close all apps',
        ],
        correctAnswer: 1,
        explanation:
          'You need to enable Bluetooth on your phone before you can connect to any Bluetooth devices.',
      },
    ],
  },
  {
    category: 'iot',
    lessonId: 'smart-home',
    title: 'Smart Home Basics',
    description:
      'Learn how to control basic smart home devices like lights and plugs',
    videoUrl: 'https://www.youtube.com/watch?v=-_vtoUmkot4',
    order: 2,
    steps: [
      {
        stepId: 'step1',
        title: 'Smart Light Basics',
        description: 'Learn how to control smart lights from your phone',
        actionItems: [
          {
            itemId: '1',
            task: 'Watch the video about smart lights',
            isRequired: true,
          },
          {
            itemId: '2',
            task: 'Download a recommended smart home app',
            isRequired: true,
          },
          {
            itemId: '3',
            task: 'Learn how to turn lights on/off from your phone',
            isRequired: true,
          },
        ],
      },
      {
        stepId: 'step2',
        title: 'Smart Plug Basics',
        description: 'Control regular appliances with smart plugs',
        actionItems: [
          {
            itemId: '4',
            task: 'Learn what a smart plug can do',
            isRequired: true,
          },
          {
            itemId: '5',
            task: 'Practice setting schedules for devices',
            isRequired: true,
          },
        ],
      },
    ],
    quiz: [
      {
        question: 'What can you do with a smart plug?',
        options: [
          'Make old appliances smart',
          'Create a new WiFi network',
          'Charge your phone faster',
          'Download apps',
        ],
        correctAnswer: 0,
        explanation:
          'Smart plugs can make regular appliances smart by letting you control their power from your phone.',
      },
    ],
  },
  {
    category: 'iot',
    lessonId: 'voice-assistant',
    title: 'Voice Assistant Basics',
    description: 'Learn to use voice assistants like Siri or Google Assistant',
    videoUrl: 'https://www.youtube.com/watch?v=CusRswT-1_U',
    order: 3,
    steps: [
      {
        stepId: 'step1',
        title: 'Voice Commands',
        description: 'Learn basic voice commands for your assistant',
        actionItems: [
          {
            itemId: '1',
            task: 'Watch the introduction video',
            isRequired: true,
          },
          {
            itemId: '2',
            task: 'Try setting an alarm with voice',
            isRequired: true,
          },
          {
            itemId: '3',
            task: 'Ask about the weather',
            isRequired: true,
          },
        ],
      },
      {
        stepId: 'step2',
        title: 'Useful Features',
        description: 'Discover helpful voice assistant features',
        actionItems: [
          {
            itemId: '4',
            task: 'Make a phone call using voice',
            isRequired: true,
          },
          {
            itemId: '5',
            task: 'Set a reminder using voice',
            isRequired: true,
          },
        ],
      },
    ],
    quiz: [
      {
        question: 'What can a voice assistant help you with?',
        options: [
          'Only playing music',
          'Making coffee',
          'Setting alarms and making calls',
          'Washing dishes',
        ],
        correctAnswer: 2,
        explanation:
          'Voice assistants can help with many tasks including setting alarms, making calls, checking weather, and more.',
      },
    ],
  },
]

async function initializeIoTLessons() {
  try {
    // Check if IoT lessons exist
    const existingLessons = await Lesson.find({ category: 'iot' })

    if (existingLessons.length === 0) {
      console.log('🤖 Initializing IoT lessons...')

      // Add timestamps to lessons
      const lessonsWithTimestamps = iotLessons.map((lesson) => ({
        ...lesson,
        createdAt: new Date(),
        updatedAt: new Date(),
      }))

      // Insert lessons
      await Lesson.insertMany(lessonsWithTimestamps)
      console.log(
        `✅ Successfully initialized ${iotLessons.length} IoT lessons`
      )
    } else {
      console.log('ℹ️ IoT lessons already exist, skipping initialization')
      console.log(`📊 Found ${existingLessons.length} existing IoT lessons`)
    }
  } catch (error) {
    console.error('❌ Error initializing IoT lessons:', error)
    throw error
  }
}

async function clearIoTLessons() {
  try {
    await Lesson.deleteMany({ category: 'iot' })
    console.log('🧹 Successfully cleared all IoT lessons')
  } catch (error) {
    console.error('❌ Error clearing IoT lessons:', error)
    throw error
  }
}

// Function to reinitialize IoT lessons
async function reinitializeIoTLessons() {
  try {
    console.log('🔄 Starting IoT lessons reinitialization...')

    // Clear existing IoT lessons
    await clearIoTLessons()

    // Initialize new IoT lessons
    await initializeIoTLessons()

    console.log('✨ IoT lessons reinitialization complete')
  } catch (error) {
    console.error('❌ Error reinitializing IoT lessons:', error)
    throw error
  }
}

// Export all functions
module.exports = {
  initializeIoTLessons,
  clearIoTLessons,
  reinitializeIoTLessons,
}

// Add this to your main initialization code
async function initializeAllSampleData() {
  try {
    await initializeIoTLessons()
    // Add other initialization functions here
  } catch (error) {
    console.error('Error in sample data initialization:', error)
  }
}
