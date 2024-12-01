const Event = require('../models/Event')
const User = require('../models/User')

// Admin Controllers
exports.createEvent = async (req, res) => {
  try {
    const eventData = {
      ...req.body,
      // Ensure date is a proper Date object
      date: new Date(req.body.date),
    }

    const event = new Event(eventData)
    await event.save()

    // Fetch the saved event to ensure proper date formatting
    const savedEvent = await Event.findById(event._id)
    res.status(201).json(savedEvent)
  } catch (error) {
    console.error('Error creating event:', error)
    res.status(400).json({ error: error.message })
  }
}

exports.updateEvent = async (req, res) => {
  try {
    const event = await Event.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    })
    if (!event) return res.status(404).json({ error: 'Event not found' })
    res.json(event)
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}

exports.deleteEvent = async (req, res) => {
  try {
    const event = await Event.findByIdAndDelete(req.params.id)
    if (!event) return res.status(404).json({ error: 'Event not found' })
    res.json({ message: 'Event deleted successfully' })
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}

// User Controllers
exports.getEvents = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      search,
      category,
      isOnline,
      city,
      startDate,
      endDate,
    } = req.query

    const query = {}

    // Search by title
    if (search) {
      query.title = { $regex: search, $options: 'i' }
    }

    // Filter by category
    if (category) {
      query.category = category
    }

    // Filter by online/offline
    if (isOnline !== undefined) {
      query.isOnline = isOnline === 'true'
    }

    // Filter by city
    if (city) {
      query['location.city'] = { $regex: city, $options: 'i' }
    }

    // Date range filter
    if (startDate || endDate) {
      query.date = {}
      if (startDate) {
        query.date.$gte = new Date(startDate)
      }
      if (endDate) {
        query.date.$lte = new Date(endDate)
      }
    }

    const options = {
      skip: (Number(page) - 1) * Number(limit),
      limit: Number(limit),
      sort: { date: 1 },
    }

    const [events, total] = await Promise.all([
      Event.find(query, null, options).lean(),
      Event.countDocuments(query),
    ])

    // Transform dates and add isRegistered field
    const formattedEvents = events.map((event) => ({
      ...event,
      date: event.date.toISOString(),
      createdAt: event.createdAt.toISOString(),
      updatedAt: event.updatedAt.toISOString(),
    }))

    res.json({
      events: formattedEvents,
      pagination: {
        currentPage: Number(page),
        totalPages: Math.ceil(total / Number(limit)),
        totalEvents: total,
        hasNextPage: Number(page) * Number(limit) < total,
        hasPreviousPage: Number(page) > 1,
      },
    })
  } catch (error) {
    console.error('Error fetching events:', error)
    res.status(400).json({ error: error.message })
  }
}

exports.joinEvent = async (req, res) => {
  try {
    const { eventId } = req.params
    const { userId } = req.body

    const event = await Event.findById(eventId)
    if (!event) return res.status(404).json({ error: 'Event not found' })

    if (event.isPast()) {
      return res.status(400).json({ error: 'Event has already passed' })
    }

    if (event.isFullyBooked()) {
      return res.status(400).json({ error: 'Event is fully booked' })
    }

    if (event.participants.includes(userId)) {
      return res
        .status(400)
        .json({ error: 'Already registered for this event' })
    }

    event.participants.push(userId)
    event.currentParticipants += 1
    await event.save()

    // Add event to user's registered events
    await User.findByIdAndUpdate(userId, {
      $push: { registeredEvents: eventId },
    })

    res.json(event)
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}

exports.leaveEvent = async (req, res) => {
  try {
    const { eventId } = req.params
    const { userId } = req.body

    const event = await Event.findById(eventId)
    if (!event) return res.status(404).json({ error: 'Event not found' })

    if (event.isPast()) {
      return res.status(400).json({ error: 'Cannot leave a past event' })
    }

    if (!event.participants.includes(userId)) {
      return res.status(400).json({ error: 'Not registered for this event' })
    }

    event.participants = event.participants.filter(
      (id) => id.toString() !== userId
    )
    event.currentParticipants -= 1
    await event.save()

    // Remove event from user's registered events
    await User.findByIdAndUpdate(userId, {
      $pull: { registeredEvents: eventId },
    })

    res.json(event)
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}

exports.getEventDetails = async (req, res) => {
  try {
    const { eventId } = req.params
    const { userId } = req.query

    const event = await Event.findById(eventId).lean()
    if (!event) {
      return res.status(404).json({ error: 'Event not found' })
    }

    // Check if user is registered
    let isRegistered = false
    if (userId) {
      const user = await User.findById(userId)
      isRegistered = user.registeredEvents.includes(eventId)
    }

    res.json({
      ...event,
      date: event.date.toISOString(),
      createdAt: event.createdAt.toISOString(),
      updatedAt: event.updatedAt.toISOString(),
      isRegistered,
    })
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}

exports.checkRegistrationStatus = async (req, res) => {
  try {
    const { eventId } = req.params
    const { userId } = req.query

    if (!eventId || !userId) {
      return res.status(400).json({
        error: 'Both eventId and userId are required',
      })
    }

    const event = await Event.findById(eventId)
    if (!event) {
      return res.status(404).json({
        error: 'Event not found',
      })
    }

    // Assuming your Event model has a participants array
    const isRegistered = event.participants.includes(userId)

    res.status(200).json({
      isRegistered,
    })
  } catch (error) {
    console.error('Error checking registration status:', error)
    res.status(500).json({
      error: 'Internal server error checking registration status',
    })
  }
}

exports.getRegisteredEvents = async (req, res) => {
  try {
    const userId = req.query.userId
    const events = await Event.find({ participants: userId }).exec()
    res.json(events)
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch registered events' })
  }
}
