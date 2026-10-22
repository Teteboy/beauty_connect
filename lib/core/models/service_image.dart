import 'dart:convert';
import '../utils/asset_url.dart';

class ServiceImage {
  final int id;
  final int serviceId;
  final String imageUrl;
  final String? caption;
  final DateTime createdAt;

  ServiceImage({
    required this.id,
    required this.serviceId,
    required this.imageUrl,
    this.caption,
    required this.createdAt,
  });

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(
      id: json['id'],
      serviceId: json['serviceId'],
      imageUrl: resolveAssetUrl(json['imageUrl']) ?? '',
      caption: json['caption'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
