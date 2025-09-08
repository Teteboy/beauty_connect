import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/analytics_provider.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/review_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'This Month';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  void _loadAnalytics() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<AnalyticsProvider>().fetchAnalytics(_selectedPeriod);
      if (user.role == 'technician') {
        context.read<BookingProvider>().fetchTechnicianBookings(user.id);
        context.read<ReviewProvider>().fetchReviews(technicianId: user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadAnalytics();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'This Week', child: Text('This Week')),
              const PopupMenuItem(value: 'This Month', child: Text('This Month')),
              const PopupMenuItem(value: 'Last 3 Months', child: Text('Last 3 Months')),
              const PopupMenuItem(value: 'This Year', child: Text('This Year')),
            ],
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return RefreshIndicator(
            onRefresh: () async => _loadAnalytics(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  Text(
                    _selectedPeriod,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Key Metrics
                  Consumer3<AnalyticsProvider, BookingProvider, ReviewProvider>(
                    builder: (context, analyticsProvider, bookingProvider, reviewProvider, _) {
                      if (analyticsProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final analytics = analyticsProvider.analyticsData;
                      final bookings = bookingProvider.bookings ?? [];
                      final reviews = reviewProvider.reviews ?? [];
                      
                      final totalBookings = bookings.length;
                      final completedBookings = bookings.where((b) => b.status == 'completed').length;
                      final totalRevenue = bookings
                          .where((b) => b.status == 'completed')
                          .fold(0.0, (sum, b) => sum + (b.price ?? 0));
                      final avgRating = reviews.isNotEmpty 
                          ? reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length 
                          : 0.0;

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  title: 'Total Bookings',
                                  value: totalBookings.toString(),
                                  icon: Icons.calendar_today,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricCard(
                                  title: 'Completed',
                                  value: completedBookings.toString(),
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  title: 'Total Revenue',
                                  value: '\$${totalRevenue.toStringAsFixed(2)}',
                                  icon: Icons.attach_money,
                                  color: Colors.purple,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricCard(
                                  title: 'Avg. Rating',
                                  value: avgRating.toStringAsFixed(1),
                                  icon: Icons.star,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Recent Activity
                          const Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Show real bookings instead of hardcoded data
                          ...bookings.take(5).map((booking) => _ActivityItem(
                            title: 'Booking #${booking.id}',
                            subtitle: '${booking.serviceName} - \$${booking.price.toStringAsFixed(2)}',
                            status: booking.status,
                            date: booking.createdAt ?? DateTime.now(),
                          )),

                          const SizedBox(height: 32),

                          // Performance Insights
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Performance Insights',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _InsightItem(
                                    icon: Icons.trending_up,
                                    title: 'Booking Growth',
                                    description: analytics?['growth'] ?? '+15% compared to last month',
                                    color: Colors.green,
                                  ),
                                  _InsightItem(
                                    icon: Icons.schedule,
                                    title: 'Peak Hours',
                                    description: analytics?['peakHours'] ?? '2:00 PM - 5:00 PM',
                                    color: Colors.blue,
                                  ),
                                  _InsightItem(
                                    icon: Icons.favorite,
                                    title: 'Most Popular Service',
                                    description: analytics?['popularService'] ?? 'Hair Styling',
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final DateTime date;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InsightItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}







