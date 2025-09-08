exports.getAnalytics = async (req, res) => {
  try {
    const userId = req.user.id;
    const { period } = req.query;
    
    // Calculate date range based on period
    const dateRange = getDateRange(period);
    
    const analytics = await calculateAnalytics(userId, dateRange);
    
    res.json(analytics);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};