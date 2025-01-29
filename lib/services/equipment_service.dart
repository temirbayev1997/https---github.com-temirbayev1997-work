import '../models/equipment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Equipment> getAllEquipment() {
    // Временные данные для тестирования
    return [
      // Тренажерный зал 1
      Equipment(
        id: '1',
        name: 'Тренажерный зал "Фитнес Плюс"',
        description: 'Современный тренажерный зал',
        images: ['https://giowellness.ru/ozera-39.jpg'],
        rating: 4.8,
        reviewCount: 2,
        category: 'Тренажерные залы',
        rentalPrices: {
          'day': 1500,
          'month': 3000,
        },
        price: 1500,
      ),
      Equipment(
        id: '2',
        name: 'Легкая тренировка',
        description: 'Тренировка для начинающих.',
        images: ['https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhknlO7F_d3jw65BZDSl8iNyh4uIeV5cj30Q&s'],
        rating: 4.5,
        reviewCount: 1,
        category: 'Тренировки',
        rentalPrices: {
          'day': 500,
          'month': 1000,
        },
        price: 500,
      ),
      Equipment(
        id: '3',
        name: 'Тяжелая тренировка',
        description: 'Тренировка для опытных спортсменов.',
        images: ['https://akbulak-olympic.kz/thumb/2/yAzSZj2E_rZ7PmTeBzhWag/800r533/d/img_5479.jpg'],
        rating: 4.7,
        reviewCount: 2,
        category: 'Тренировки',
        rentalPrices: {
          'day': 700,
          'month': 1400,
        },
        price: 700,
      ),
      // Тренажерный зал 2
      Equipment(
        id: '4',
        name: 'Тренажерный зал "Сила и Выносливость"',
        description: 'Тренажерный зал.',
        images: ['https://hammerlegend.kz/wp-content/uploads/2021/01/Rectangle-264-e1611820190427.png'],
        rating: 4.6,
        reviewCount: 3,
        category: 'Тренажерные залы',
        rentalPrices: {
          'day': 1600,
          'month': 3200,
        },
        price: 1600,
      ),
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
