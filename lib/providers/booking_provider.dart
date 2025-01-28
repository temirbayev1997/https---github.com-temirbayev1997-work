import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';
import '../models/fitness_center.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> loadBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      _bookings = snapshot.docs
          .map((doc) => Booking.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error loading bookings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBooking(Booking booking) async {
    try {
      await _firestore.collection('bookings').add(booking.toJson());
      await loadBookings(booking.userId);
    } catch (e) {
      print('Error creating booking: $e');
      throw e;
    }
  }

  Future<void> cancelBooking(String bookingId, String userId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
      await loadBookings(userId);
    } catch (e) {
      print('Error canceling booking: $e');
      throw e;
    }
  }
}
