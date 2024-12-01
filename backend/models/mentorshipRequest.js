const mongoose = require('mongoose')

const mentorshipRequestSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'User is required'],
      index: true,
    },
    mentor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      index: true,
    },
    topic: {
      type: String,
      required: [true, 'Topic is required'],
      trim: true,
      minLength: [3, 'Topic must be at least 3 characters long'],
      maxLength: [100, 'Topic cannot be longer than 100 characters'],
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
      trim: true,
      minLength: [10, 'Description must be at least 10 characters long'],
      maxLength: [1000, 'Description cannot be longer than 1000 characters'],
    },
    phoneNumber: {
      type: String,
      required: [true, 'Phone number is required'],
      trim: true,
      validate: {
        validator: function (v) {
          // Basic phone validation - matches international format
          return /^\+?[\d\s-]+$/.test(v)
        },
        message: (props) => `${props.value} is not a valid phone number!`,
      },
    },
    status: {
      type: String,
      enum: {
        values: ['Open', 'In Progress', 'Completed', 'Cancelled'],
        message: '{VALUE} is not a valid status',
      },
      default: 'Open',
      index: true,
    },
    skillLevel: {
      type: String,
      enum: {
        values: ['Beginner', 'Intermediate', 'Advanced'],
        message: '{VALUE} is not a valid skill level',
      },
      required: true,
    },
    tags: [
      {
        type: String,
        trim: true,
      },
    ],
    isActive: {
      type: Boolean,
      default: true,
      index: true,
    },
    completedAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
)

// Indexes for common queries
mentorshipRequestSchema.index({ createdAt: -1 })
mentorshipRequestSchema.index({ topic: 'text', description: 'text' })

// Pre-save middleware to handle status changes
mentorshipRequestSchema.pre('save', function (next) {
  if (this.isModified('status')) {
    if (this.status === 'Completed' && !this.completedAt) {
      this.completedAt = new Date()
    }
  }
  next()
})

// Static method to find active mentorship requests
mentorshipRequestSchema.statics.findActive = function () {
  return this.find({ isActive: true, status: { $ne: 'Completed' } })
}

// Instance method to add a message
mentorshipRequestSchema.methods.addMessage = function (senderId, content) {
  this.messages.push({
    sender: senderId,
    content: content,
  })
  return this.save()
}

const MentorshipRequest = mongoose.model(
  'MentorshipRequest',
  mentorshipRequestSchema
)

module.exports = MentorshipRequest
