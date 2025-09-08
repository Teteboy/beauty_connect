import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class ProfileProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  File? _selectedImage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  File? get selectedImage => _selectedImage;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  Future<void> takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to take photo: $e';
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
    String? location,
    String? bio,
    String? specialty,
    File? profileImage,
    required AuthProvider authProvider,
  }) async {
    _setLoading(true);
    try {
      Map<String, dynamic> updateData = {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'location': location,
        'bio': bio,
        'specialty': specialty,
      };

      // If there's a profile image, upload it first
      if (profileImage != null) {
        final imageUrl = await _uploadProfileImage(profileImage);
        if (imageUrl != null) {
          updateData['profileImage'] = imageUrl;
        }
      }

      print('Sending update data: $updateData');
      final response = await ApiService.put('/auth/profile', updateData);
      print('Update response: $response');
      
      // Check if response has success field or user field
      if (response['success'] == true || response['user'] != null) {
        // Update the user in AuthProvider
        final userData = response['user'] ?? response;
        final updatedUser = User.fromJson(userData);
        authProvider.updateUser(updatedUser);
        
        _selectedImage = null;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update profile';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Profile update error: $e');
      _error = 'Failed to update profile: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      // This would typically upload to a cloud storage service
      // For now, we'll simulate the upload
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, you'd upload to AWS S3, Firebase Storage, etc.
      // and return the URL
      return 'https://example.com/profile-images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    } catch (e) {
      _error = 'Failed to upload image: $e';
      return null;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await ApiService.put('/auth/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to change password: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    try {
      await ApiService.delete('/auth/account');
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete account: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getProfileStats() async {
    try {
      final response = await ApiService.get('/auth/profile/stats');
      return response;
    } catch (e) {
      _error = 'Failed to fetch profile stats: $e';
      notifyListeners();
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
