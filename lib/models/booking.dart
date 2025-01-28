import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String fitnesscenterId;
  final DateTime date;
  final String timeSlot;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.fitnesscenterId,
    required this.date,
    required this.timeSlot,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['userId'],
      fitnesscenterId: json['fitnesscenterId'],
      date: (json['date'] as Timestamp).toDate(),
      timeSlot: json['timeSlot'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fitnesscenterId': fitnesscenterId,
      'date': date,
      'timeSlot': timeSlot,
      'createdAt': createdAt,
    };
  }
}
