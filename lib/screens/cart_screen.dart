import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_kursovaya/models/equipment.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/сart_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

User? currentUser = FirebaseAuth.instance.currentUser;

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Корзина')),
      body: Consumer<CartService>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(child: Text('Корзина пуста'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return CartItemCard(item: item);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Итого:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${cart.total.toStringAsFixed(2)} KZT',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showPaymentSheet(context),
                      child: Text('Перейти к оплате'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
// Пример добавления элемента в корзину
void _addItemToCart(BuildContext context, Equipment equipment) {
final cartService = context.read<CartService>();
final currentUser = FirebaseAuth.instance.currentUser;
if (currentUser != null) {
  final cartItem = CartItem(
    equipment: equipment,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 1)),
    totalPrice: equipment.price,
    imageUrl: equipment.images.isNotEmpty ? equipment.images[0] : '',
    userId: currentUser.uid, // Добавляем userId при создании
  );
  cartService.addItem(cartItem); // Теперь передаем только cartItem
}}


  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaymentSheet(),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  const CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.equipment.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Период аренды: ${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}'),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${item.totalPrice.toStringAsFixed(2)} KZT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.delete),
              onPressed: () {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  context.read<CartService>().removeItem(item, currentUser.uid);
                }
              }

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

class PaymentSheet extends StatefulWidget {
  @override
  _PaymentSheetState createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    final cartService = context.read<CartService>();
    await CartFirestoreService().saveCartToFirestore(cartService.items);
    cartService.clear();

    Navigator.of(context).pop(); // Закрываем оплату
    Navigator.of(context).pop(); // Возвращаемся назад

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Оплата прошла успешно')),
    );

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Оплата картой', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            child: _isProcessing ? CircularProgressIndicator() : Text('Оплатить'),
            style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }
}
