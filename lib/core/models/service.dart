import 'user.dart';
import '../models/service_image.dart';
import '../utils/asset_url.dart';

class Service {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String category;
  final String? imageUrl;
  final bool isAvailable;
  final int technicianId;
  final User? technician;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ServiceImage> images;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.category,
    this.imageUrl,
    required this.isAvailable,
    required this.technicianId,
    required this.technician,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    try {
      return Service(
        id: json['id'] as int,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: _parseDouble(json['price']),
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        category: json['category']?.toString() ?? '',
        imageUrl: resolveAssetUrl(json['imageUrl']?.toString()),
        isAvailable: json['isAvailable'] as bool? ?? true,
        technicianId: json['technicianId'] as int,
        technician: json['technician'] != null
            ? User.fromJson(json['technician'] as Map<String, dynamic>)
            : null,
        images: json['images'] != null
            ? List<ServiceImage>.from(
                json['images'].map((x) => ServiceImage.fromJson(x)))
            : [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing Service JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'technicianId': technicianId,
      'technician': technician?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get formattedDuration {
    if (durationMinutes < 60) {
      return '${durationMinutes}min';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      if (minutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${minutes}min';
      }
    }
  }

  String get technicianName => technician?.fullName ?? 'Unknown Technician';

  Service copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    int? technicianId,
    User? technician,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      technicianId: technicianId ?? this.technicianId,
      technician: technician ?? this.technician,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
