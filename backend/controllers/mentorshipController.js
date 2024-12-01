const MentorshipRequest = require('../models/mentorshipRequest')

exports.createMentorshipRequest = async (req, res) => {
  console.log('Creating mentorship request')
  try {
    const userId = req.params.userId
    const { topic, phoneNumber, description, skillLevel } = req.body

    // Validate required fields
    if (!topic || !phoneNumber || !description || !skillLevel) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields',
      })
    }

    // Create mentorship request
    const mentorshipRequest = await MentorshipRequest.create({
      user: userId,
      topic,
      phoneNumber,
      description,
      skillLevel,
    })

    return res.status(201).json({
      success: true,
      data: mentorshipRequest,
      message: 'Mentorship request created successfully',
    })
  } catch (error) {
    console.error('Error in createMentorshipRequest:', error)

    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: Object.values(error.errors)
          .map((err) => err.message)
          .join(', '),
      })
    }

    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    })
  }
}

exports.getMentorshipRequests = async (req, res) => {
  try {
    const userId = req.params.userId

    const requests = await MentorshipRequest.find({ user: userId }).sort(
      '-createdAt'
    )

    return res.status(200).json({
      success: true,
      data: requests,
    })
  } catch (error) {
    console.error('Error in getMentorshipRequests:', error)
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    })
  }
}

exports.getSingleMentorshipRequest = async (req, res) => {
  try {
    const userId = req.params.userId
    const requestId = req.params.requestId

    const request = await MentorshipRequest.findById(requestId)

    if (!request) {
      return res.status(404).json({
        success: false,
        message: 'Mentorship request not found',
      })
    }

    // Check if the request belongs to the user
    if (request.user.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this request',
      })
    }

    return res.status(200).json({
      success: true,
      data: request,
    })
  } catch (error) {
    console.error('Error in getSingleMentorshipRequest:', error)
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    })
  }
}

// Add this new export to your existing controller
exports.deleteMentorshipRequest = async (req, res) => {
  try {
    const userId = req.params.userId
    const requestId = req.params.requestId

    // Find the request first to verify ownership
    const request = await MentorshipRequest.findById(requestId)

    if (!request) {
      return res.status(404).json({
        success: false,
        message: 'Mentorship request not found',
      })
    }

    // Check if the request belongs to the user
    if (request.user.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this request',
      })
    }

    // Delete the request
    await MentorshipRequest.findByIdAndDelete(requestId)

    return res.status(200).json({
      success: true,
      message: 'Mentorship request deleted successfully',
    })
  } catch (error) {
    console.error('Error in deleteMentorshipRequest:', error)
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    })
  }
}
