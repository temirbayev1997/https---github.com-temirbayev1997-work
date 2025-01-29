import 'equipment.dart'; // Убедитесь, что путь правильный

class CartItem {
  final Equipment equipment;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String imageUrl;
  final String userId; // Добавляем поле userId

  CartItem({
    required this.equipment,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.imageUrl,
    required this.userId, 
  });

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment.toJson(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
      'imageUrl': imageUrl,
    };
  }

  Map<String, dynamic> toOrderJson() {
    return {
      'image': imageUrl,
      'name': equipment.name,
      'price': totalPrice,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      equipment: Equipment.fromJson(json['equipment'] ?? {}),
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      totalPrice: (json['totalPrice']?.toDouble() ?? 0.0),
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
