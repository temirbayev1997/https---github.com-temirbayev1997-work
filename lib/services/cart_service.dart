import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get total => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners(); // Уведомляем слушателей об изменении
  }

  Future<void> _saveCart(String userId) async {
    await _firestore.collection('carts').doc(userId).set({
      'items': _items.map((item) => item.toJson()).toList(),
    });
  }

  Future<void> createOrder(String userId, String deliveryAddress, String deliveryType, String cardHolder, String cardNumber, String cvv, String expiryDate) async {
    final orderId = _firestore.collection('orders').doc().id; // Генерируем уникальный ID для заказа
    final orderData = {
      'date': DateTime.now().toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'deliveryType': deliveryType,
      'items': _items.map((item) => item.toOrderJson()).toList(),
      'payment': {
        'cardHolder': cardHolder,
        'cardNumber': cardNumber,
        'cvv': cvv,
        'expiryDate': expiryDate,
      },
      'rentalPeriod': {
        'startDate': _items.first.startDate.toIso8601String(),
        'endDate': _items.first.endDate.toIso8601String(),
      },
      'total': total,
    };

    await _firestore.collection('orders').doc(orderId).set(orderData);
    _items.clear(); // Очищаем корзину после создания заказа
    notifyListeners();
  }

  void removeItem(CartItem item, String userId) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    
  }
}
