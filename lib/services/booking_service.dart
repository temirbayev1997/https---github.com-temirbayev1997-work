import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/training.dart';
import '../models/gym_room.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение списка доступных тренировок
  Future<List<Training>> getAvailableTrainings() async {
    final snapshot = await _firestore.collection('trainings').get();
    return snapshot.docs.map((doc) => Training(
      id: doc.id,
      name: doc['name'],
      description: doc['description'],
      trainerName: doc['trainerName'],
      imageUrl: doc['imageUrl'],
      maxParticipants: doc['maxParticipants'],
      currentParticipants: doc['currentParticipants'],
      price: doc['price'].toDouble(),
      startTime: (doc['startTime'] as Timestamp).toDate(),
      endTime: (doc['endTime'] as Timestamp).toDate(),
      roomId: doc['roomId'],
      equipment: List<String>.from(doc['equipment']),
    )).toList();
  }

  // Получение списка залов
  Future<List<GymRoom>> getAvailableRooms() async {
    final snapshot = await _firestore.collection('gymRooms').get();
    return snapshot.docs.map((doc) => GymRoom(
      id: doc.id,
      name: doc['name'],
      description: doc['description'],
      images: List<String>.from(doc['images']),
      capacity: doc['capacity'],
      prices: Map<String, double>.from(doc['prices']),
      equipment: List<String>.from(doc['equipment']),
    )).toList();
  }

  // Бронирование тренировки
  Future<void> bookTraining(String trainingId, String userId) async {
    await _firestore.collection('bookings').add({
      'trainingId': trainingId,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'confirmed'
    });

    // Обновляем количество участников
    await _firestore.collection('trainings').doc(trainingId).update({
      'currentParticipants': FieldValue.increment(1)
    });
  }

  // Бронирование зала
  Future<void> bookGymRoom(String roomId, String userId, DateTime startTime, DateTime endTime) async {
    await _firestore.collection('roomBookings').add({
      'roomId': roomId,
      'userId': userId,
      'startTime': startTime,
      'endTime': endTime,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'confirmed'
    });
  }

  // Проверка доступности зала
  Future<bool> checkRoomAvailability(String roomId, DateTime startTime, DateTime endTime) async {
    final snapshot = await _firestore
        .collection('roomBookings')
        .where('roomId', isEqualTo: roomId)
        .where('startTime', isLessThanOrEqualTo: endTime)
        .where('endTime', isGreaterThanOrEqualTo: startTime)
        .get();

    return snapshot.docs.isEmpty;
  }
}
