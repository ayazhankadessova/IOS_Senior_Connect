// models/Event.js
const mongoose = require('mongoose')

const eventSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
    },
    category: {
      type: String,
      required: true,
      enum: [
        'educational',
        'social',
        'health',
        'technology',
        'entertainment',
        'other',
      ],
    },
    imageUrl: {
      type: String,
      default: 'https://picsum.photos/id/237/200/300',
    },
    date: {
      type: Date,
      required: true,
    },
    startTime: {
      type: String,
      required: true,
    },
    endTime: {
      type: String,
      required: true,
    },
    location: {
      address: {
        type: String,
        required: true,
      },
      city: String,
      zipCode: String,
    },
    organizer: {
      name: {
        type: String,
        required: true,
      },
      contact: {
        type: String,
        required: true,
      },
      type: {
        type: String,
        enum: ['staff', 'partner', 'volunteer'],
        default: 'staff',
      },
    },
    quota: {
      type: Number,
      required: true,
      min: 1,
    },
    currentParticipants: {
      type: Number,
      default: 0,
    },
    participants: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
    status: {
      type: String,
      enum: ['upcoming', 'ongoing', 'completed', 'cancelled'],
      default: 'upcoming',
    },
    isOnline: {
      type: Boolean,
      default: false,
    },
    tags: [String],
  },
  {
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        // Transform dates to ISO format
        if (ret.date) {
          ret.date = ret.date.toISOString()
        }
        if (ret.createdAt) {
          ret.createdAt = ret.createdAt.toISOString()
        }
        if (ret.updatedAt) {
          ret.updatedAt = ret.updatedAt.toISOString()
        }
        return ret
      },
    },
  }
)

// const eventSchema = new mongoose.Schema(
//   {
//     title: {
//       type: String,
//       required: true,
//       trim: true,
//     },
//     description: {
//       type: String,
//       required: true,
//     },
//     category: {
//       type: String,
//       required: true,
//       enum: [
//         'educational',
//         'social',
//         'health',
//         'technology',
//         'entertainment',
//         'other',
//       ],
//     },
//     date: {
//       type: Date,
//       required: true,
//       index: true, // Index only necessary fields
//     },
//     startTime: String,
//     endTime: String,
//     location: {
//       address: String,
//       city: String,
//       zipCode: String,
//     },
//     organizer: {
//       name: String,
//       contact: String,
//       type: {
//         type: String,
//         enum: ['staff', 'partner', 'volunteer'],
//         default: 'staff',
//       },
//     },
//     quota: {
//       type: Number,
//       required: true,
//       min: 1,
//     },
//     currentParticipants: {
//       type: Number,
//       default: 0,
//     },
//     participants: [
//       {
//         type: mongoose.Schema.Types.ObjectId,
//         ref: 'User',
//       },
//     ],
//     status: {
//       type: String,
//       enum: ['upcoming', 'ongoing', 'completed', 'cancelled'],
//       default: 'upcoming',
//       index: true,
//     },
//   },
//   {
//     // Add timestamp options but don't index them
//     timestamps: true,
//     // Optimize for Cosmos DB
//     strict: true,
//     strictQuery: true,
//     // Disable version key to reduce document size
//     versionKey: false,
//     // Optimize for reads
//     bufferCommands: false,
//   }
// )

// Add methods to the schema
eventSchema.methods.isFullyBooked = function () {
  return this.currentParticipants >= this.quota
}

eventSchema.methods.isPast = function () {
  return new Date() > this.date
}

eventSchema.pre('save', function (next) {
  if (this.isModified('participants')) {
    this.currentParticipants = this.participants.length
  }
  next()
})

const Event = mongoose.model('Event', eventSchema)
module.exports = Event

// // Update User.js to include events
// const userSchema = mongoose.Schema({
//   // ... existing fields ...
//   registeredEvents: [
//     {
//       type: mongoose.Schema.Types.ObjectId,
//       ref: 'Event',
//     },
//   ],
// })
