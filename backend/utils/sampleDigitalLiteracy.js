const Lesson = require('../models/Lesson')

const digitalLiteracyLessons = [
  {
    category: 'digitalLiteracy',
    lessonId: 'onlineSafety1',
    title: 'Internet Safety Basics',
    description: 'Learn fundamental concepts of staying safe online',
    videoUrl: 'https://www.youtube.com/watch?v=_LElWqXi7Ag',
    order: 1,
    steps: [
      {
        stepId: 'step1',
        title: 'Watch the Video',
        description: 'Learn about basic internet safety concepts',
        actionItems: [
          {
            itemId: '1',
            task: 'Watch the complete video on Internet Safety',
            isRequired: true,
          },
        ],
      },
    ],
    quiz: [
      {
        question:
          "What should you do if someone you don't know tries to contact you online?",
        options: [
          'Share your personal information',
          'Ignore or block them',
          'Meet them in person',
          'Share your location',
        ],
        correctAnswer: 1,
        explanation:
          "It's safest to ignore or block unknown contacts to protect yourself from potential threats.",
      },
      {
        question: 'Which password is most secure?',
        options: ['123456', 'password', 'P@ssw0rd2024!', 'qwerty'],
        correctAnswer: 2,
        explanation:
          'Strong passwords contain a mix of uppercase, lowercase, numbers, and special characters.',
      },
      {
        question: 'What should you do if you receive a suspicious email?',
        options: [
          'Click on all links to check them',
          'Reply with your personal information',
          'Delete it and mark as spam',
          'Forward it to all your contacts',
        ],
        correctAnswer: 2,
        explanation:
          'Suspicious emails should be deleted and marked as spam to protect yourself from phishing attempts.',
      },
      {
        question: 'How often should you update your passwords?',
        options: [
          'Never',
          'Every few years',
          'Every 3-6 months',
          'Only when accounts are hacked',
        ],
        correctAnswer: 2,
        explanation:
          'Regular password updates every 3-6 months help maintain account security.',
      },
    ],
  },
  {
    category: 'digitalLiteracy',
    lessonId: 'onlineSafety2',
    title: 'Protecting Personal Information',
    description: 'Learn how to protect your personal data online',
    videoUrl: 'https://www.youtube.com/watch?v=yrln8nyVBLU',
    order: 2,
    steps: [
      {
        stepId: 'step1',
        title: 'Watch the Video',
        description: 'Learn about protecting personal information online',
        actionItems: [
          {
            itemId: '1',
            task: 'Complete the video on Personal Information Protection',
            isRequired: true,
          },
        ],
      },
    ],
    quiz: [
      {
        question: 'Which information is safe to share publicly online?',
        options: [
          'Your full name and address',
          'Your bank account details',
          'Your hobbies and interests',
          'Your social security number',
        ],
        correctAnswer: 2,
        explanation:
          'General interests and hobbies are usually safe to share, while personal and financial information should be kept private.',
      },
      {
        question: 'What is two-factor authentication?',
        options: [
          'Using the same password twice',
          'Having two email accounts',
          'A second security step after password',
          'Sharing login info with two people',
        ],
        correctAnswer: 2,
        explanation:
          'Two-factor authentication adds an extra layer of security by requiring a second verification step.',
      },
      {
        question:
          'What should you check before entering payment information online?',
        options: [
          "The website's color scheme",
          'How many visitors the site has',
          'The padlock symbol and https://',
          "The website's age",
        ],
        correctAnswer: 2,
        explanation:
          'A secure website should have https:// and a padlock symbol in the address bar.',
      },
      {
        question: 'How can you protect your online accounts?',
        options: [
          'Use the same password for all accounts',
          'Share passwords with friends',
          'Use unique, strong passwords',
          'Never change passwords',
        ],
        correctAnswer: 2,
        explanation:
          'Using unique, strong passwords for each account helps prevent unauthorized access.',
      },
    ],
  },
  {
    category: 'digitalLiteracy',
    lessonId: 'onlineSearch',
    title: 'Searching for Information Online',
    description:
      'Master effective online search techniques and evaluate information reliability',
    videoUrl: 'https://www.youtube.com/watch?v=LTJygQwYV84',
    order: 3,
    steps: [
      {
        stepId: 'step1',
        title: 'Watch the Video',
        description: 'Learn about effective online search strategies',
        actionItems: [
          {
            itemId: '1',
            task: 'Complete the video on Online Search Techniques',
            isRequired: true,
          },
        ],
      },
    ],
    quiz: [
      {
        question: 'What makes a search term effective?',
        options: [
          'Using as many words as possible',
          'Using specific keywords related to your topic',
          'Using only single letters',
          'Writing full sentences',
        ],
        correctAnswer: 1,
        explanation:
          'Specific keywords help narrow down search results to find relevant information.',
      },
      {
        question: 'How can you check if online information is reliable?',
        options: [
          'Believe everything you read',
          'Check multiple sources and author credentials',
          'Only read the headlines',
          'Use the first result only',
        ],
        correctAnswer: 1,
        explanation:
          'Verifying information across multiple reliable sources helps ensure accuracy.',
      },
      {
        question: 'What does putting quotation marks around search terms do?',
        options: [
          'Makes the search faster',
          'Searches for the exact phrase',
          'Translates the terms',
          'Removes all results',
        ],
        correctAnswer: 1,
        explanation:
          'Quotation marks help find exact phrases in search results.',
      },
      {
        question:
          'Which source is typically most reliable for academic information?',
        options: [
          'Social media posts',
          'Academic journals and educational websites',
          'Anonymous blogs',
          'Advertisement websites',
        ],
        correctAnswer: 1,
        explanation:
          'Academic journals and educational websites typically provide verified, reliable information.',
      },
    ],
  },
  {
    category: 'digitalLiteracy',
    lessonId: 'onlineCollaboration',
    title: 'Online Collaboration',
    description:
      'Learn how to effectively collaborate with others online using various tools',
    videoUrl: 'https://www.youtube.com/watch?v=RXRT3dHu6_o',
    order: 4,
    steps: [
      {
        stepId: 'step1',
        title: 'Watch the Video',
        description:
          'Learn about online collaboration tools and best practices',
        actionItems: [
          {
            itemId: '1',
            task: 'Complete the video on Online Collaboration',
            isRequired: true,
          },
        ],
      },
    ],
    quiz: [
      {
        question: 'What is a key benefit of online collaboration tools?',
        options: [
          'They only work offline',
          'They allow real-time sharing and editing',
          'They require in-person meetings',
          'They only work for one person',
        ],
        correctAnswer: 1,
        explanation:
          'Online collaboration tools enable real-time sharing and editing among multiple users.',
      },
      {
        question: 'Which is a good practice for online meetings?',
        options: [
          'Join whenever you want',
          'Keep your microphone unmuted always',
          'Be on time and mute when not speaking',
          'Ignore the chat feature',
        ],
        correctAnswer: 2,
        explanation:
          'Being punctual and managing your microphone helps maintain meeting efficiency.',
      },
      {
        question: 'How should you share feedback in online collaboration?',
        options: [
          'Be aggressive and critical',
          'Be constructive and respectful',
          "Don't give any feedback",
          'Only give negative feedback',
        ],
        correctAnswer: 1,
        explanation:
          'Constructive and respectful feedback promotes positive collaboration.',
      },
      {
        question: 'What should you do before sharing documents online?',
        options: [
          'Share with everyone publicly',
          'Check permissions and remove sensitive info',
          'Never share documents',
          'Delete the original copy',
        ],
        correctAnswer: 1,
        explanation:
          'Checking permissions and removing sensitive information ensures secure document sharing.',
      },
    ],
  },
  {
    category: 'digitalLiteracy',
    lessonId: 'socialLearning',
    title: 'Social Learning (WhatsApp, Instagram)',
    description:
      'Learn how to use social media platforms for learning and communication',
    videoUrl: 'https://www.youtube.com/watch?v=BWcqWD9vE_4',
    order: 5,
    steps: [
      {
        stepId: 'step1',
        title: 'Watch the Video',
        description:
          'Learn about using social media for learning and communication',
        actionItems: [
          {
            itemId: '1',
            task: 'Complete the video on Social Learning',
            isRequired: true,
          },
        ],
      },
    ],
    quiz: [
      {
        question: 'What is a benefit of joining WhatsApp learning groups?',
        options: [
          'To spam others',
          'To share learning resources and discuss topics',
          'To advertise products',
          'To collect personal information',
        ],
        correctAnswer: 1,
        explanation:
          'WhatsApp groups can be valuable for sharing educational resources and discussions.',
      },
      {
        question: 'How can Instagram be used for learning?',
        options: [
          'Only for posting selfies',
          'Following educational accounts and infographic pages',
          'Ignoring all content',
          'Sharing private information',
        ],
        correctAnswer: 1,
        explanation:
          'Instagram can be a source of visual learning through educational accounts and infographics.',
      },
      {
        question:
          'What should you consider when joining online learning communities?',
        options: [
          'Join as many as possible',
          'Check their privacy settings and guidelines',
          'Share personal details immediately',
          'Ignore all rules',
        ],
        correctAnswer: 1,
        explanation:
          'Reviewing privacy settings and guidelines helps ensure a safe learning experience.',
      },
      {
        question:
          'How can you maintain privacy while using social media for learning?',
        options: [
          'Share everything publicly',
          'Use private accounts and control sharing settings',
          'Accept all friend requests',
          'Never use privacy settings',
        ],
        correctAnswer: 1,
        explanation:
          'Managing privacy settings helps protect personal information while learning online.',
      },
    ],
  },
]

async function initializeSampleData() {
  try {
    // const lessonCount = await Lesson.countDocuments()
    if (true) {
      console.log('Initializing sample lessons...')

      // Add creation timestamp to each lesson
      const lessonsWithTimestamps = digitalLiteracyLessons.map((lesson) => ({
        ...lesson,
        createdAt: new Date(),
        updatedAt: new Date(),
      }))

      await Lesson.insertMany(lessonsWithTimestamps)
      console.log(
        `Successfully initialized ${digitalLiteracyLessons.length} lessons`
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
