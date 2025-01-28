import 'package:flutter/material.dart';
import '../models/inventory_model.dart';

class InventoryDetailsScreen extends StatefulWidget {
  final InventoryModel inventory;

  InventoryDetailsScreen({required this.inventory});

  @override
  _InventoryDetailsScreenState createState() => _InventoryDetailsScreenState();
}

class _InventoryDetailsScreenState extends State<InventoryDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.inventory.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Галерея изображений
            Container(
              height: 300,
              child: PageView.builder(
                itemCount: widget.inventory.images.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    widget.inventory.images[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Основная информация
                  Text(
                    widget.inventory.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(widget.inventory.description),
                  SizedBox(height: 16),

                  // Цены
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _PriceRow(
                            title: 'День',
                            price: widget.inventory.pricePerDay,
                          ),
                          _PriceRow(
                            title: 'Неделя',
                            price: widget.inventory.pricePerWeek,
                          ),
                          _PriceRow(
                            title: 'Месяц',
                            price: widget.inventory.pricePerMonth,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Характеристики
                  Text(
                    'Характеристики',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...widget.inventory.specifications.entries.map(
                    (entry) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            '${entry.key}:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Text(entry.value),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // ReviewsSection(inventoryId: widget.inventory.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String title;
  final double price;

  const _PriceRow({required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            '$price KZT',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
