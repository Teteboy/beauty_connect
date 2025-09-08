import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnalyticsProvider with ChangeNotifier {
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAnalytics(String period) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/analytics?period=$period');
      _analyticsData = response;
    } catch (e) {
      _error = 'Failed to fetch analytics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
