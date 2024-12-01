const validateEventData = (req, res, next) => {
  try {
    // Validate date format
    const date = new Date(req.body.date)
    if (isNaN(date.getTime())) {
      return res.status(400).json({
        error:
          'Invalid date format. Please use ISO format (e.g., "2024-12-01T10:00:00.000Z")',
      })
    }

    // Validate time format
    const timeRegex = /^(0?[1-9]|1[0-2]):[0-5][0-9] (AM|PM)$/
    if (
      !timeRegex.test(req.body.startTime) ||
      !timeRegex.test(req.body.endTime)
    ) {
      return res.status(400).json({
        error: 'Invalid time format. Please use "HH:MM AM/PM" format',
      })
    }

    next()
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}

module.exports = validateEventData
