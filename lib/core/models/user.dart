import '../utils/asset_url.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String role;
  final String? location;
  final String? bio;
  final String? profileImage;
  final String? specialty;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.role,
    this.location,
    this.bio,
    this.profileImage,
    this.specialty,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: _parseId(json['id']),
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone']?.toString(),
        role: json['role'] as String? ?? '',
        location: json['location'] as String?,
        bio: json['bio'] as String?,
        profileImage: resolveAssetUrl(json['profileImage'] as String?),
        specialty: json['specialty'] as String?,
        isVerified: json['isVerified'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing User JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int _parseId(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.parse(id);
    throw ArgumentError('Invalid ID type: ${id.runtimeType}');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'location': location,
      'bio': bio,
      'profileImage': profileImage,
      'specialty': specialty,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  String get initials {
    String firstInitial =
        firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  bool get isTechnician => role == 'technician';
  bool get isCustomer => role == 'customer';
  bool get isAdmin => role == 'admin';

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? role,
    String? location,
    String? bio,
    String? profileImage,
    String? specialty,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      specialty: specialty ?? this.specialty,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
