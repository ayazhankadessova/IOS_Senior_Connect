# SeniorConnect 🌟

A comprehensive digital learning platform designed specifically for seniors, helping them navigate the modern digital world with confidence. The platform offers structured courses, mentorship opportunities, and community events to make technology accessible and engaging for elderly users.

## Backend

- Feel free to check out routes and use the backend, there is a rate limiter, so don't flood with requests

https://senior-connect-app-backend.vercel.app/api/events

## Features 🚀

### Learning Modules

- **Smartphone Basics** 📱

  - Interactive lessons on smartphone fundamentals
  - Step-by-step guides for common tasks
  - Practical exercises and tutorials

- **Digital Literacy** 💻

  - Online safety and security awareness
  - Interactive video lessons
  - Knowledge verification quizzes
  - Curated content from trusted sources

- **Social Media Navigation** 🤝

  - WhatsApp, Facebook, and Instagram basics
  - Safe social media practices
  - Interactive tutorials
  - Progress tracking

- **IoT & Smart Devices** 🏠
  - Smart home device tutorials
  - Health monitoring tools integration
  - Interactive device control lessons
  - Practical applications

### Additional Features

- **Mentorship System** 👥

  - Request help from experienced mentors
  - Real-time assistance
  - Progress tracking with mentors
  - Customized learning paths

- **Community Events** 📅

  - Register for local and online events
  - Filter events by category and location
  - Track registered events
  - Online/offline event options

- **Progress Tracking** 📊
  - Overall learning progress dashboard
  - Course-specific progress tracking
  - Achievement system
  - Personal learning history

## Technical Stack 🛠

### Frontend

- **Swift UI**
  - Native iOS application
  - Intuitive user interface
  - Responsive design
  - Accessibility features

### Backend

- **Express.js**
  - RESTful API architecture
  - Secure authentication
  - Event management
  - Progress tracking system

### Database

- **MongoDB**
  - User profiles
  - Course content
  - Progress tracking
  - Event management

## Getting Started 🏁

### Prerequisites

- Node.js (v14 or higher)
- MongoDB
- Xcode (for iOS development)
- iOS 14.0 or later

### Installation

1. Clone the repository

```bash
git clone https://github.com/yourusername/senior-connect.git
```

2. No need to install backend dependencies (unless u want to) -> backend is deployed on Vercel: https://senior-connect-app-backend.vercel.app/api/events

3. Set up environment variables

```bash
cp .env.example .env
# Edit .env with your configuration
```

1. Open iOS project

```bash
cd ../ios
open SeniorConnect.xcodeproj
```

## Contributing 🤝

We welcome contributions! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## Acknowledgments 🙏

- Educational content creators from Youtube (I will add their usernames soon)

## Development Logs 📝

### November 13-15, 2023

- ✅ Implemented core lesson functionality
- ✅ Set up backend structure
- ✅ Added progress tracking system
- ✅ Implemented lesson fetching from backend
- ✅ Fixed progress tracking bugs
- ✅ Enhanced user experience with tutorial improvements

### November 16-18, 2023

- ✅ Implemented event management system
- ✅ Added video URL support
- ✅ Enhanced lesson content
- ✅ Added sample events
- ✅ Implemented category filtering
- ✅ Added registered events tab

### November 19-20, 2023

- ✅ Implemented mentorship system
- ✅ Enhanced help request functionality
- ✅ Added Digital Literacy courses
- ✅ Improved home page with progress tracking
- ✅ UI/UX improvements
- ✅ Added YouTube video integration

### December 1, 2023

- ✅ Implemented IoT section
- ✅ Fixed learning progress tracking
- ✅ Backend deployment to Vercel
- 🔄 API endpoint: https://senior-connect-app-backend.vercel.app/api/events

### Known Issues & Future Improvements

- ⏳ Event registration status display optimization
- ⏳ Infinite scroll implementation
- ⏳ Code organization improvements
- ⏳ Quiz system for Digital Literacy section
- ⏳ Event view model optimization
- ⏳ Contact button implementation
- 💡 Potential offline support

## Dec 1

- [ ] contact button
- [x] IOT section
- [ ] deploy the backend, fix the baseurls
- [ ] add placeholder picture
- [x] Your learning progress fix

Ideas:

1. Add offline support?
