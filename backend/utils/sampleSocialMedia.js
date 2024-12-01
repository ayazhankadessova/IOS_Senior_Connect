const Lesson = require('../models/Lesson')

const socialMediaLessons = [
  {
    category: 'socialMedia',
    lessonId: 'whatsappBasics',
    title: 'Getting Started with WhatsApp',
    description:
      'Learn the fundamentals of using WhatsApp for messaging and calls',
    videoUrl: 'https://www.youtube.com/watch?v=example1',
    order: 1,
    steps: [
      {
        stepId: 'step1',
        title: 'Watch the Video',
        description: 'Learn basic WhatsApp features and navigation',
        actionItems: [
          {
            itemId: '1',
            task: 'Complete the video on WhatsApp basics',
            isRequired: true,
          },
        ],
      },
    ],
    quiz: [
      {
        question: 'How do you know if your WhatsApp message was delivered?',
        options: [
          'One grey tick',
          'Two grey ticks',
          'Two blue ticks',
          'No ticks appear',
        ],
        correctAnswer: 1,
        explanation:
          'Two grey ticks indicate that your message was delivered to the recipient.',
      },
      {
        question: 'What can you share on WhatsApp Status?',
        options: [
          'Only text',
          'Only photos',
          'Photos, videos, and text updates',
          'Only voice messages',
        ],
        correctAnswer: 2,
        explanation:
          'WhatsApp Status allows you to share photos, videos, and text updates that disappear after 24 hours.',
      },
      {
        question: 'How can you make a voice call on WhatsApp?',
        options: [
          'Not possible on WhatsApp',
          'Click the phone icon in a chat',
          'Send a text message first',
          'Only in group chats',
        ],
        correctAnswer: 1,
        explanation:
          'Clicking the phone icon in a chat allows you to make voice calls over the internet.',
      },
    ],
  },
  {
    category: 'socialMedia',
    lessonId: 'facebookBasics',
    title: 'Navigating Facebook',
    description:
      'Master the basics of Facebook to connect with family and friends',
    videoUrl: 'https://www.youtube.com/watch?v=example2',
    order: 2,
    steps: [
      {
        stepId: 'step1',
        title: 'Watch the Video',
        description: 'Learn essential Facebook features',
        actionItems: [
          {
            itemId: '1',
            task: 'Complete the video on Facebook navigation',
            isRequired: true,
          },
        ],
      },
    ],
    quiz: [
      {
        question: 'How do you add a friend on Facebook?',
        options: [
          'Send them an email',
          'Click the "Add Friend" button on their profile',
          'Call them on phone',
          'Message them first',
        ],
        correctAnswer: 1,
        explanation:
          'The "Add Friend" button on a profile allows you to send a friend request.',
      },
      {
        question: 'What is a Facebook Timeline?',
        options: [
          'A clock feature',
          'Your profile page showing your posts and activity',
          'A calendar app',
          'A gaming feature',
        ],
        correctAnswer: 1,
        explanation:
          'Your Timeline is your profile page where your posts, photos, and activities appear.',
      },
      {
        question: 'How can you control who sees your Facebook posts?',
        options: [
          'You cannot control this',
          'Using privacy settings when posting',
          'Delete the post immediately',
          'Only post at night',
        ],
        correctAnswer: 1,
        explanation:
          'Privacy settings let you choose who can see your posts: Public, Friends, or Custom audiences.',
      },
    ],
  },
  {
    category: 'socialMedia',
    lessonId: 'instagramBasics',
    title: 'Understanding Instagram',
    description: 'Learn how to use Instagram for sharing and connecting',
    videoUrl: 'https://www.youtube.com/watch?v=example3',
    order: 3,
    steps: [
      {
        stepId: 'step1',
        title: 'Watch the Video',
        description: 'Learn Instagram basics and features',
        actionItems: [
          {
            itemId: '1',
            task: 'Complete the video on Instagram features',
            isRequired: true,
          },
        ],
      },
    ],
    quiz: [
      {
        question: 'What is an Instagram Story?',
        options: [
          'A regular post',
          'A 24-hour temporary photo or video',
          'A private message',
          'A written article',
        ],
        correctAnswer: 1,
        explanation:
          'Instagram Stories are photos or videos that disappear after 24 hours.',
      },
      {
        question: 'How do you like a post on Instagram?',
        options: [
          'Send a message',
          'Double tap the photo or tap the heart icon',
          'Share the post',
          'Save the post',
        ],
        correctAnswer: 1,
        explanation:
          'You can like a post by double-tapping the photo or tapping the heart icon below it.',
      },
      {
        question: 'What are Instagram hashtags used for?',
        options: [
          'Decorating posts',
          'Categorizing and discovering content',
          'Sending messages',
          'Making calls',
        ],
        correctAnswer: 1,
        explanation:
          'Hashtags help categorize posts and make them discoverable to people interested in that topic.',
      },
    ],
  },
]

async function initializeSampleData() {
  try {
    // const lessonCount = await Lesson.countDocuments()
    if (true) {
      console.log('Initializing social media lessons...')

      // Add creation timestamp to each lesson
      const lessonsWithTimestamps = socialMediaLessons.map((lesson) => ({
        ...lesson,
        createdAt: new Date(),
        updatedAt: new Date(),
      }))

      await Lesson.insertMany(lessonsWithTimestamps)
      console.log(
        `Successfully initialized ${socialMediaLessons.length} lessons`
      )
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

module.exports = initializeSampleData
