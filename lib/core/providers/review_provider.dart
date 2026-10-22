import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/api_service.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReviews({int? technicianId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final endpoint = technicianId != null
          ? '/reviews/technician/$technicianId'
          : '/reviews';

      final response = await ApiService.get(endpoint);
      if (response['success']) {
        _reviews = (response['data'] as List)
            .map((json) => Review.fromJson(json))
            .toList();
      } else {
        _error = response['message'] ?? 'Failed to fetch reviews';
      }
    } catch (e) {
      _error = 'Failed to fetch reviews: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/reviews', {
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
      });

      if (response['success']) {
        final newReview = Review.fromJson(response['data']);
        _reviews.insert(0, newReview);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create review';
        return false;
      }
    } catch (e) {
      _error = 'Failed to create review: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await ApiService.put('/reviews/$reviewId', {
        'rating': rating,
        'comment': comment,
      });

      if (response['success']) {
        final updatedReview = Review.fromJson(response['data']);
        final index = _reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          _reviews[index] = updatedReview;
          notifyListeners();
        }
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update review';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to update review: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      final response = await ApiService.delete('/reviews/$reviewId');

      if (response['success']) {
        _reviews.removeWhere((r) => r.id == reviewId);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete review';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete review: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
