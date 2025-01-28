import '../models/equipment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Equipment> getAllEquipment() {
    // Временные данные для тестирования
    return [
      Equipment(
        id: '1',
        name: '',
        description: '',
        images: ['url_to_image'],
        rating: 4.5,
        reviewCount: 10,
        category: '',
        rentalPrices: {
          'day': 1000
        },
      ),
      // Добавьте больше тестовых данных
    ];
  }

  Future<List<Equipment>> searchEquipment(String query) async {
    // Реализация поиска
    return getAllEquipment().where(
      (equipment) => equipment.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<List<Equipment>> getRecommendations(String userId) async {
    // Временно возвращаем все оборудование
    return getAllEquipment();
  }
}
