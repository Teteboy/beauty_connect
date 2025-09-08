import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  List<Booking> _customerBookings = [];
  List<Booking> _technicianBookings = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  List<Booking> get customerBookings => _customerBookings;
  List<Booking> get technicianBookings => _technicianBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Booking> get upcomingBookings {
    final now = DateTime.now();
    return _customerBookings
        .where((booking) => 
            booking.dateTime.isAfter(now) && 
            booking.status != 'cancelled' &&
            booking.status != 'completed')
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Booking> get todayBookings {
    final now = DateTime.now();
    return _technicianBookings
        .where((booking) => 
            booking.dateTime.year == now.year &&
            booking.dateTime.month == now.month &&
            booking.dateTime.day == now.day)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Booking> get pendingBookings {
    return _technicianBookings
        .where((booking) => booking.status == 'pending')
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/bookings');
      print('Bookings response type: ${response.runtimeType}');
      print('Bookings response: $response');
      
      if (response is List) {
        _bookings = response.map((json) => Booking.fromJson(json as Map<String, dynamic>)).toList();
        _customerBookings = _bookings;
        print('Parsed ${_bookings.length} bookings');
      } else {
        print('Invalid bookings response format - expected List, got ${response.runtimeType}');
        _error = 'Invalid response format';
        _bookings = [];
        _customerBookings = [];
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      _error = 'Failed to fetch bookings: $e';
      _bookings = [];
      _customerBookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTechnicianBookings(int technicianId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/bookings/technician/$technicianId');
      print('Technician bookings response type: ${response.runtimeType}');
      print('Technician bookings response: $response');
      
      if (response is List) {
        _bookings = response.map((json) => Booking.fromJson(json as Map<String, dynamic>)).toList();
        _technicianBookings = _bookings;
        print('Parsed ${_bookings.length} technician bookings');
      } else {
        print('Invalid technician bookings response format - expected List, got ${response.runtimeType}');
        _error = 'Invalid response format';
        _bookings = [];
        _technicianBookings = [];
      }
    } catch (e) {
      print('Error fetching technician bookings: $e');
      _error = 'Failed to fetch technician bookings: $e';
      _bookings = [];
      _technicianBookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking({
    required int serviceId,
    required DateTime dateTime,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/bookings', {
        'serviceId': serviceId,
        'dateTime': dateTime.toIso8601String(),
        'notes': notes,
      });

      if (response['success']) {
        final newBooking = Booking.fromJson(response['data']);
        _customerBookings.add(newBooking);
        _bookings = _customerBookings;
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create booking';
        return false;
      }
    } catch (e) {
      _error = 'Failed to create booking: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.put('/bookings/$bookingId/status', {
        'status': status,
      });

      // Backend returns booking data directly with message, not wrapped in success/data
      if (response != null && response is Map<String, dynamic>) {
        // Check if response has booking data or message indicating success
        if (response.containsKey('booking') || response.containsKey('message')) {
          final bookingData = response['booking'] ?? response;
          final updatedBooking = Booking.fromJson(bookingData);
          
          // Update in customer bookings
          final customerIndex = _customerBookings.indexWhere((b) => b.id == bookingId);
          if (customerIndex != -1) {
            _customerBookings[customerIndex] = updatedBooking;
          }
          
          // Update in technician bookings
          final technicianIndex = _technicianBookings.indexWhere((b) => b.id == bookingId);
          if (technicianIndex != -1) {
            _technicianBookings[technicianIndex] = updatedBooking;
          }
          
          // Update main bookings list
          final mainIndex = _bookings.indexWhere((b) => b.id == bookingId);
          if (mainIndex != -1) {
            _bookings[mainIndex] = updatedBooking;
          }
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      
      _error = 'Failed to update booking status';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update booking status: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Booking?> fetchBookingById(String bookingId) async {
    try {
      final response = await ApiService.get('/bookings/$bookingId');
      print('Booking by ID response: $response');
      
      // Backend returns booking data directly, not wrapped in success/data
      if (response is Map<String, dynamic>) {
        return Booking.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching booking by ID: $e');
      _error = 'Failed to fetch booking: $e';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}









