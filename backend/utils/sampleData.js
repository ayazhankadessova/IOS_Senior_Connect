// utils/sampleData.js
const Lesson = require('../models/Lesson')

const sampleLessons = [
  {
    category: 'smartphoneBasics',
    lessonId: 'intro',
    title: 'Introduction to Android',
    description: 'Learn how to navigate through Android basics',
    videoUrl: 'https://www.youtube.com/watch?v=example1',
    order: 1,
    steps: [
      {
        stepId: 'step1',
        title: 'Getting Started',
        description: 'Basic navigation and controls',
        actionItems: [
          {
            itemId: '1',
            task: 'Locate and test the power button',
            isRequired: true,
          },
          {
            itemId: '2',
            task: 'Practice volume controls',
            isRequired: true,
          },
          {
            itemId: '3',
            task: 'Try different sound modes',
            isRequired: true,
          },
        ],
      },
    ],
    quiz: [
      {
        question: 'Which button is typically used to turn on your smartphone?',
        options: [
          'Volume button',
          'Power button',
          'Home button',
          'Camera button',
        ],
        correctAnswer: 1,
        explanation:
          'The power button is used to turn your smartphone on and off.',
      },
    ],
  },
  {
    category: 'smartphoneBasics',
    lessonId: 'setup',
    title: 'Phone Setup & Controls',
    description: 'Master phone settings and basic controls',
    videoUrl: 'https://www.youtube.com/watch?v=example2',
    order: 2,
    steps: [
      {
        stepId: 'step1',
        title: 'Basic Controls',
        description: 'Learn about essential phone controls',
        actionItems: [
          {
            itemId: '1',
            task: 'Practice using power button',
            isRequired: true,
          },
          {
            itemId: '2',
            task: 'Adjust volume settings',
            isRequired: true,
          },
          {
            itemId: '3',
            task: 'Use notification panel',
            isRequired: true,
          },
        ],
      },
      {
        stepId: 'step2',
        title: 'Phone Settings',
        description: 'Configure basic phone settings',
        actionItems: [
          {
            itemId: '1',
            task: 'Adjust display brightness',
            isRequired: true,
          },
          {
            itemId: '2',
            task: 'Set up sound profiles',
            isRequired: true,
          },
        ],
      },
    ],
  },
  // Add the rest of your lessons here...
]

const initializeSampleData = async () => {
  try {
    const lessonCount = await Lesson.countDocuments()
    if (lessonCount === 0) {
      console.log('Initializing sample lessons...')

      // Add creation timestamp to each lesson
      const lessonsWithTimestamps = sampleLessons.map((lesson) => ({
        ...lesson,
        createdAt: new Date(),
        updatedAt: new Date(),
      }))

      await Lesson.insertMany(lessonsWithTimestamps)
      console.log(`Successfully initialized ${sampleLessons.length} lessons`)
    } else {
      console.log('Sample lessons already exist, skipping initialization')
    }
  } catch (error) {
    console.error('Error initializing sample data:', error)
  }
}

const clearSampleData = async () => {
  try {
    await Lesson.deleteMany({})
    console.log('Successfully cleared all lessons')
  } catch (error) {
    console.error('Error clearing sample data:', error)
  }
}

module.exports = {
  initializeSampleData,
  clearSampleData,
  sampleLessons,
}
