import 'package:flutter/material.dart';
import 'dart:io';
import '../models/service.dart';
import '../models/service_image.dart';
import '../services/api_service.dart';

class ServiceProvider with ChangeNotifier {
  List<Service> _services = [];
  List<Service> _myServices = [];
  List<Service> _technicianServices = [];
  bool _isLoading = false;
  String? _error;

  List<Service> get services => _services;
  List<Service> get myServices => _myServices;
  List<Service> get technicianServices => _technicianServices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/services');
      print('Services response type: ${response.runtimeType}');
      print('Services response: $response');

      if (response is List) {
        _services = response
            .map((json) => Service.fromJson(json as Map<String, dynamic>))
            .toList();
        print('Parsed ${_services.length} services');
      } else {
        print(
            'Invalid response format - expected List, got ${response.runtimeType}');
        _error = 'Invalid response format';
        _services = [];
      }
    } catch (e) {
      print('Error fetching services: $e');
      _error = 'Failed to fetch services: $e';
      _services = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/services/my-services');
      print('My services response type: ${response.runtimeType}');
      print('My services response: $response');

      if (response is List) {
        _myServices = response
            .map((json) => Service.fromJson(json as Map<String, dynamic>))
            .toList();
        print('Parsed ${_myServices.length} my services');
      } else {
        print(
            'Invalid response format - expected List, got ${response.runtimeType}');
        _myServices = [];
        _error = 'Invalid response format';
      }
    } catch (e) {
      print('Error loading my services: $e');
      _error = 'Failed to load services: $e';
      _myServices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTechnicianServices(int technicianId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await ApiService.get('/services/technician/$technicianId');
      if (response is List) {
        _technicianServices = response
            .map((json) => Service.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _error = 'Invalid response format';
        _technicianServices = [];
      }
    } catch (e) {
      _error = 'Failed to fetch technician services: $e';
      _technicianServices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createService({
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required String category,
    String? imageUrl,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? finalImageUrl = imageUrl;

      // If imageFile is provided, upload it first to get URL
      if (imageFile != null) {
        finalImageUrl = await _uploadImage(imageFile);
        if (finalImageUrl == null) {
          _error = 'Failed to upload image';
          return false;
        }
      }

      Map<String, dynamic> serviceData = {
        'name': name,
        'description': description,
        'price': price,
        'durationMinutes': durationMinutes,
        'category': category,
      };

      // Add imageUrl if available
      if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
        serviceData['imageUrl'] = finalImageUrl;
      }

      final response = await ApiService.post('/services', serviceData);
      final newService = Service.fromJson(response);

      // Add to relevant lists
      _myServices.add(newService);
      _services.add(newService);

      return true;
    } catch (e) {
      _error = 'Failed to create service: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateService({
    required String serviceId,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    String? category,
    String? imageUrl,
    File? imageFile,
    bool? isAvailable,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? finalImageUrl = imageUrl;

      // If imageFile is provided, upload it first to get URL
      if (imageFile != null) {
        finalImageUrl = await _uploadImage(imageFile);
        if (finalImageUrl == null) {
          _error = 'Failed to upload image';
          return false;
        }
      }

      Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (durationMinutes != null)
        updateData['durationMinutes'] = durationMinutes;
      if (category != null) updateData['category'] = category;
      if (finalImageUrl != null) updateData['imageUrl'] = finalImageUrl;
      if (isAvailable != null) updateData['isAvailable'] = isAvailable;

      final response = await ApiService.put('/services/$serviceId', updateData);

      if (response is Map<String, dynamic>) {
        final updatedService = Service.fromJson(response);

        // Update in all relevant lists
        final myIndex =
            _myServices.indexWhere((s) => s.id.toString() == serviceId);
        if (myIndex != -1) {
          _myServices[myIndex] = updatedService;
        }

        final servicesIndex =
            _services.indexWhere((s) => s.id.toString() == serviceId);
        if (servicesIndex != -1) {
          _services[servicesIndex] = updatedService;
        }

        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update service: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteService(String serviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.delete('/services/$serviceId');

      // Remove from all lists
      _myServices.removeWhere((s) => s.id.toString() == serviceId);
      _services.removeWhere((s) => s.id.toString() == serviceId);
      _technicianServices.removeWhere((s) => s.id.toString() == serviceId);

      return true;
    } catch (e) {
      _error = 'Failed to delete service: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Service?> fetchServiceById(int serviceId) async {
    try {
      final response = await ApiService.get('/services/$serviceId');
      print('Service by ID response: $response');

      if (response is Map<String, dynamic>) {
        return Service.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching service by ID: $e');
      _error = 'Failed to fetch service: $e';
      notifyListeners();
      return null;
    }
  }

  // Upload image file and return URL
  Future<String?> _uploadImage(File imageFile) async {
    try {
      return await ApiService.uploadImage(imageFile);
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Fetch service images
  Future<List<ServiceImage>> fetchServiceImages(int serviceId) async {
    try {
      final response = await ApiService.get('/services/$serviceId/images');
      return List<ServiceImage>.from(
          response.map((x) => ServiceImage.fromJson(x)));
    } catch (e) {
      _error = 'Failed to load service images: $e';
      notifyListeners();
      return [];
    }
  }

  // Add image to service
  Future<bool> addServiceImage(int serviceId, File imageFile,
      {String? caption}) async {
    try {
      final imageUrl = await _uploadImage(imageFile);
      if (imageUrl == null) {
        _error = 'Failed to upload image';
        notifyListeners();
        return false;
      }

      await ApiService.post('/services/$serviceId/images', {
        'imageUrl': imageUrl,
        if (caption != null) 'caption': caption,
      });
      return true;
    } catch (e) {
      print('Error adding service image: $e');
      return false;
    }
  }

  // Delete service image
  Future<bool> deleteServiceImage(int serviceId, int imageId) async {
    try {
      await ApiService.delete('/services/$serviceId/images/$imageId');
      return true;
    } catch (e) {
      _error = 'Failed to delete service image: $e';
      notifyListeners();
      return false;
    }
  }
}
