const Event = require('../models/Event')

const sampleEvents = [
  {
    title: 'Smart Home Technology Workshop',
    description:
      'Learn how to set up and manage smart home devices. Perfect for seniors looking to make their homes more automated and convenient.',
    category: 'technology',
    date: '2025-01-15T09:00:00.000Z',
    startTime: '9:00 AM',
    endTime: '11:30 AM',
    location: {
      address: 'Digital Learning Center, 45 Innovation Street',
      city: 'Astana',
      zipCode: '010000',
    },
    organizer: {
      name: 'David Tech',
      contact: 'david.tech@seniorconnect.kz',
      type: 'staff',
    },
    imageUrl: 'https://picsum.photos/id/1/200/300',
    quota: 15,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['smart home', 'technology', 'automation', 'beginner'],
  },
  {
    title: 'Healthy Living After 60',
    description:
      'Join our health experts for a comprehensive seminar on maintaining good health, nutrition, and exercise habits for seniors.',
    category: 'health',
    date: '2025-02-01T14:00:00.000Z',
    startTime: '2:00 PM',
    endTime: '4:00 PM',
    location: {
      address: 'Community Health Center, 78 Wellness Avenue',
      city: 'Astana',
      zipCode: '010001',
    },
    organizer: {
      name: 'Dr. Sarah Health',
      contact: 'sarah.health@seniorconnect.kz',
      type: 'partner',
    },
    imageUrl: 'https://picsum.photos/id/2/200/300',
    quota: 30,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['health', 'wellness', 'nutrition', 'exercise'],
  },
  {
    title: 'Digital Photography Basics',
    description:
      'Master the fundamentals of digital photography with your smartphone or camera. Learn composition, lighting, and basic editing.',
    category: 'technology',
    date: '2025-02-15T10:00:00.000Z',
    startTime: '10:00 AM',
    endTime: '12:30 PM',
    location: {
      address: 'Creative Arts Center, 23 Photo Lane',
      city: 'Astana',
      zipCode: '010002',
    },
    organizer: {
      name: 'Mike Camera',
      contact: 'mike.camera@seniorconnect.kz',
      type: 'staff',
    },
    imageUrl: 'https://picsum.photos/id/3/200/300',
    quota: 20,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['photography', 'technology', 'creative', 'beginner'],
  },
  {
    title: 'Senior Book Club Meeting',
    description:
      'Join our monthly book club meeting to discuss interesting books and share your thoughts with fellow readers.',
    category: 'social',
    date: '2025-03-01T15:00:00.000Z',
    startTime: '3:00 PM',
    endTime: '4:30 PM',
    location: {
      address: 'City Library, 56 Reading Street',
      city: 'Astana',
      zipCode: '010003',
    },
    organizer: {
      name: 'Lisa Books',
      contact: 'lisa.books@seniorconnect.kz',
      type: 'volunteer',
    },
    imageUrl: 'https://picsum.photos/id/4/200/300',
    quota: 25,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['books', 'social', 'discussion', 'literature'],
  },
  {
    title: 'Memory Enhancement Workshop',
    description:
      'Learn effective techniques and exercises to maintain and improve your memory as you age.',
    category: 'educational',
    date: '2025-03-15T10:00:00.000Z',
    startTime: '10:00 AM',
    endTime: '11:30 AM',
    location: {
      address: 'Online Event',
      city: 'Astana',
      zipCode: '010000',
    },
    organizer: {
      name: 'Dr. John Mind',
      contact: 'john.mind@seniorconnect.kz',
      type: 'partner',
    },
    imageUrl: 'https://picsum.photos/id/5/200/300',
    quota: 40,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: true,
    tags: ['memory', 'health', 'education', 'mental fitness'],
  },
  {
    title: 'Evening Dance Social',
    description:
      'Enjoy an evening of dancing, music, and socializing. All dance levels welcome!',
    category: 'entertainment',
    date: '2025-04-01T18:00:00.000Z',
    startTime: '6:00 PM',
    endTime: '9:00 PM',
    location: {
      address: 'Community Center, 89 Dance Avenue',
      city: 'Astana',
      zipCode: '010004',
    },
    organizer: {
      name: 'Dance Team',
      contact: 'dance@seniorconnect.kz',
      type: 'staff',
    },
    imageUrl: 'https://picsum.photos/id/6/200/300',
    quota: 50,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['dance', 'social', 'entertainment', 'music'],
  },
  {
    title: 'Smartphone Security Workshop',
    description:
      'Learn essential security practices to keep your smartphone and personal information safe.',
    category: 'technology',
    date: '2025-04-15T14:00:00.000Z',
    startTime: '2:00 PM',
    endTime: '4:00 PM',
    location: {
      address: 'Tech Center, 45 Security Road',
      city: 'Astana',
      zipCode: '010005',
    },
    organizer: {
      name: 'Security Team',
      contact: 'security@seniorconnect.kz',
      type: 'staff',
    },
    imageUrl: 'https://picsum.photos/id/7/200/300',
    quota: 25,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['security', 'technology', 'smartphone', 'privacy'],
  },
  {
    title: 'Garden Club Meeting',
    description:
      'Share gardening tips and tricks with fellow enthusiasts. Learn about seasonal planting and maintenance.',
    category: 'social',
    date: '2025-05-01T09:00:00.000Z',
    startTime: '9:00 AM',
    endTime: '11:00 AM',
    location: {
      address: 'Community Garden, 78 Green Street',
      city: 'Astana',
      zipCode: '010006',
    },
    organizer: {
      name: 'Garden Club',
      contact: 'garden@seniorconnect.kz',
      type: 'volunteer',
    },
    imageUrl: 'https://picsum.photos/id/8/200/300',
    quota: 30,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['gardening', 'social', 'nature', 'hobby'],
  },
  {
    title: 'Online Chess Tournament',
    description:
      'Participate in our monthly online chess tournament. All skill levels welcome!',
    category: 'entertainment',
    date: '2025-05-15T13:00:00.000Z',
    startTime: '1:00 PM',
    endTime: '5:00 PM',
    location: {
      address: 'Online Event',
      city: 'Astana',
      zipCode: '010000',
    },
    organizer: {
      name: 'Chess Club',
      contact: 'chess@seniorconnect.kz',
      type: 'volunteer',
    },
    imageUrl: 'https://picsum.photos/id/9/200/300',
    quota: 32,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: true,
    tags: ['chess', 'competition', 'games', 'mental fitness'],
  },
  {
    title: 'Art Therapy Session',
    description:
      'Express yourself through art in this therapeutic and creative session.',
    category: 'health',
    date: '2025-06-01T10:00:00.000Z',
    startTime: '10:00 AM',
    endTime: '12:00 PM',
    location: {
      address: 'Art Studio, 34 Creative Lane',
      city: 'Astana',
      zipCode: '010007',
    },
    organizer: {
      name: 'Art Therapy Team',
      contact: 'art.therapy@seniorconnect.kz',
      type: 'partner',
    },
    imageUrl: 'https://picsum.photos/id/10/200/300',
    quota: 15,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['art', 'therapy', 'creative', 'wellness'],
  },
  {
    title: 'Virtual Travel Experience',
    description:
      'Take a virtual tour of famous destinations around the world from the comfort of your home.',
    category: 'entertainment',
    date: '2025-06-15T15:00:00.000Z',
    startTime: '3:00 PM',
    endTime: '4:30 PM',
    location: {
      address: 'Online Event',
      city: 'Astana',
      zipCode: '010000',
    },
    organizer: {
      name: 'Travel Team',
      contact: 'travel@seniorconnect.kz',
      type: 'staff',
    },
    imageUrl: 'https://picsum.photos/id/11/200/300',
    quota: 50,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: true,
    tags: ['travel', 'virtual', 'culture', 'education'],
  },
  {
    title: 'Mindfulness Meditation',
    description:
      'Learn and practice mindfulness meditation techniques for better mental well-being.',
    category: 'health',
    date: '2025-07-01T09:00:00.000Z',
    startTime: '9:00 AM',
    endTime: '10:30 AM',
    location: {
      address: 'Wellness Center, 56 Peace Street',
      city: 'Astana',
      zipCode: '010008',
    },
    organizer: {
      name: 'Mindfulness Team',
      contact: 'mindfulness@seniorconnect.kz',
      type: 'partner',
    },
    imageUrl: 'https://picsum.photos/id/12/200/300',
    quota: 20,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['meditation', 'mindfulness', 'wellness', 'mental health'],
  },
  {
    title: 'Digital Art Workshop',
    description:
      'Create beautiful digital artwork using tablets and simple art applications.',
    category: 'technology',
    date: '2025-07-15T14:00:00.000Z',
    startTime: '2:00 PM',
    endTime: '4:00 PM',
    location: {
      address: 'Digital Arts Studio, 67 Tech Avenue',
      city: 'Astana',
      zipCode: '010009',
    },
    organizer: {
      name: 'Digital Arts Team',
      contact: 'digital.arts@seniorconnect.kz',
      type: 'staff',
    },
    imageUrl: 'https://picsum.photos/id/13/200/300',
    quota: 15,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['digital art', 'technology', 'creative', 'tablets'],
  },
  {
    title: 'Cooking Class: Healthy Meals',
    description:
      'Learn to prepare nutritious and delicious meals with our expert chef.',
    category: 'educational',
    date: '2025-08-01T10:00:00.000Z',
    startTime: '10:00 AM',
    endTime: '12:30 PM',
    location: {
      address: 'Community Kitchen, 89 Food Street',
      city: 'Astana',
      zipCode: '010010',
    },
    organizer: {
      name: 'Cooking Team',
      contact: 'cooking@seniorconnect.kz',
      type: 'staff',
    },
    imageUrl: 'https://picsum.photos/id/14/200/300',
    quota: 12,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['cooking', 'health', 'nutrition', 'education'],
  },
  {
    title: 'Movie Discussion Club',
    description:
      'Watch and discuss classic films with fellow movie enthusiasts.',
    category: 'entertainment',
    date: '2025-08-15T18:00:00.000Z',
    startTime: '6:00 PM',
    endTime: '9:00 PM',
    location: {
      address: 'Community Center, 45 Cinema Lane',
      city: 'Astana',
      zipCode: '010011',
    },
    organizer: {
      name: 'Film Club',
      contact: 'film.club@seniorconnect.kz',
      type: 'volunteer',
    },
    imageUrl: 'https://picsum.photos/id/15/200/300',
    quota: 30,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['movies', 'discussion', 'entertainment', 'social'],
  },
  {
    title: 'Gentle Yoga Class',
    description:
      'Practice gentle yoga poses suitable for seniors of all fitness levels.',
    category: 'health',
    date: '2025-09-01T09:00:00.000Z',
    startTime: '9:00 AM',
    endTime: '10:00 AM',
    location: {
      address: 'Wellness Center, 23 Health Avenue',
      city: 'Astana',
      zipCode: '010012',
    },
    organizer: {
      name: 'Yoga Team',
      contact: 'yoga@seniorconnect.kz',
      type: 'partner',
    },
    imageUrl: 'https://picsum.photos/id/16/200/300',
    quota: 20,
    currentParticipants: 0,
    status: 'upcoming',
    isOnline: false,
    tags: ['yoga', 'exercise', 'health', 'wellness'],
  },
]

async function initializeEvents() {
  try {
    // Check if events already exist
    const existingCount = await Event.countDocuments()
    if (existingCount > 0) {
      console.log('Events already initialized')
      return
    }

    // Insert all events
    const result = await Event.insertMany(sampleEvents)
    console.log(`Successfully initialized ${result.length} events`)
  } catch (error) {
    console.error('Error initializing events:', error)
    throw error
  }
}

// Export the function to be used in your application
module.exports = initializeEvents
