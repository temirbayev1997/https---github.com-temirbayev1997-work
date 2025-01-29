import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';

class CartFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveCartToFirestore(List<CartItem> items) async {
    final cartRef = _db.collection('carts').doc();
    await cartRef.set({
      'createdAt': FieldValue.serverTimestamp(),
      'items': items.map((item) => item.toJson()).toList(),
    });
  }
}
