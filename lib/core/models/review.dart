import 'user.dart';
import 'booking.dart';

class Review {
  final int id;
  final String bookingId;
  final int customerId;
  final int technicianId;
  final int rating;
  final String? comment;
  final User? customer;
  final User? technician;
  final Booking? booking;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.technicianId,
    required this.rating,
    this.comment,
    this.customer,
    this.technician,
    this.booking,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      bookingId: json['bookingId'].toString(),
      customerId: json['customerId'],
      technicianId: json['technicianId'],
      rating: json['rating'],
      comment: json['comment'],
      customer: json['customer'] != null ? User.fromJson(json['customer']) : null,
      technician: json['technician'] != null ? User.fromJson(json['technician']) : null,
      booking: json['booking'] != null ? Booking.fromJson(json['booking']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'customerId': customerId,
      'technicianId': technicianId,
      'rating': rating,
      'comment': comment,
      'customer': customer?.toJson(),
      'technician': technician?.toJson(),
      'booking': booking?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
