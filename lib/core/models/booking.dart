import 'user.dart';
import 'service.dart';

class Booking {
  final String id;
  final int customerId;
  final int technicianId;
  final int serviceId;
  final DateTime dateTime;
  final String status;
  final String? notes;
  final double price;
  final User? customer;
  final User? technician;
  final Service? service;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.customerId,
    required this.technicianId,
    required this.serviceId,
    required this.dateTime,
    required this.status,
    this.notes,
    required this.price,
    this.customer,
    this.technician,
    this.service,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      return Booking(
        id: json['id']?.toString() ?? '',
        customerId: json['customerId'] as int? ?? 0,
        technicianId: json['technicianId'] as int? ?? 0,
        serviceId: json['serviceId'] as int? ?? 0,
        dateTime: json['dateTime'] != null
            ? DateTime.parse(json['dateTime'].toString())
            : DateTime.now(),
        status: json['status']?.toString() ?? 'pending',
        notes: json['notes']?.toString(),
        price: _parseDouble(json['price']),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : DateTime.now(),
        service: json['service'] != null
            ? Service.fromJson(json['service'] as Map<String, dynamic>)
            : null,
        customer: json['customer'] != null
            ? User.fromJson(json['customer'] as Map<String, dynamic>)
            : null,
        technician: json['technician'] != null
            ? User.fromJson(json['technician'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('Error parsing Booking JSON: $e');
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
      'customerId': customerId,
      'technicianId': technicianId,
      'serviceId': serviceId,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'price': price,
      'customer': customer?.toJson(),
      'technician': technician?.toJson(),
      'service': service?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String get formattedTime {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String get formattedDateTime => '$formattedDate at $formattedTime';

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  bool get canCancel => isPending || isConfirmed;
  bool get canConfirm => isPending;
  bool get canStart => isConfirmed;
  bool get canComplete => isInProgress;

  String get customerName => customer?.fullName ?? 'Unknown Customer';
  String get technicianName => technician?.fullName ?? 'Unknown Technician';
  String get serviceName => service?.name ?? 'Unknown Service';

  Booking copyWith({
    String? id,
    int? customerId,
    int? technicianId,
    int? serviceId,
    DateTime? dateTime,
    String? status,
    String? notes,
    double? price,
    User? customer,
    User? technician,
    Service? service,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      technicianId: technicianId ?? this.technicianId,
      serviceId: serviceId ?? this.serviceId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      price: price ?? this.price,
      customer: customer ?? this.customer,
      technician: technician ?? this.technician,
      service: service ?? this.service,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
