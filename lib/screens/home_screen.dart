import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/equipment_service.dart';
import '../models/equipment.dart';
import './profile_screen.dart';
import '../models/user_loyalty.dart';
import '../services/loyalty_service.dart';
import '../widgets/loyalty_widget.dart';
import '../models/category.dart';
// AIzaSyDAKV-O_4Plg0wEUEK9RUL4nDKB0jo5kCI api keys - google maps

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final EquipmentService _equipmentService = EquipmentService();
  final _searchController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final LoyaltyService _loyaltyService = LoyaltyService();
  final _deliveryAddressController = TextEditingController();

  List<Map<String, dynamic>> _orderHistory = [];
  late UserLoyalty userLoyalty;
  late TabController _tabController;
  List<Equipment> _equipment = [];
  List<Equipment> _cartItems = [];
  List<String> categories = ['Все', 'Тяжелые Инвентарь', 'Сноуборды', 'Коньки', 'Велосипеды', 'Наборы', 'Легкая Атлетика', 'Уличный Спорт'];
  bool _isLoading = false;
  bool _hasReviewed = false;
  List<Equipment> _favorites = [];
  
  DateTime? _selectedDate;
  String _selectedDeliveryType = 'pickup';
  String _selectedRentalPeriod = 'week';
  String? _selectedCategory;
  String _sortBy = 'price';

  int get cartItemCount => _cartItems.length;

  @override
  void initState() {
    super.initState();
    userLoyalty = UserLoyalty();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);
    try {
      final recommendations = await _equipmentService.getRecommendations('user_id');
      setState(() => _equipment = recommendations);
    } finally {
      setState(() => _isLoading = false);
    }
  }

Future<void> _search(String? query) async {
  if (query == null) return;
  setState(() => _isLoading = true);
  try {
    final results = await _equipmentService.searchEquipment(query);
    setState(() => _equipment = results);
  } finally {
    setState(() => _isLoading = false);
  }
}

void _showOrderHistory() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'История заказов',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Expanded(
            child: _orderHistory.isEmpty
                ? Center(child: Text('История заказов пуста'))
                : ListView.builder(
                    itemCount: _orderHistory.length,
                    itemBuilder: (context, index) {
                      final order = _orderHistory[index];
                      return Card(
                        child: ListTile(
                          title: Text('Заказ от ${_formatDate(order['date'])}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Сумма: ${order['total']} тг'),
                              Text('Способ доставки: ${order['deliveryType']}'),
                              Text('Период аренды: ${order['rentalPeriod']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.receipt_long),
                            onPressed: () => _showOrderDetails(order),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

String _formatDate(DateTime date) {
  return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}';
}
void _filterEquipment() {
  setState(() {
    if (_selectedCategory == null || _selectedCategory == 'Все') {
      _loadRecommendations();
    } else {
      _equipment = _equipment.where((item) => 
        item.category == _selectedCategory).toList();
    }
  });
}


void _showOrderDetails(Map<String, dynamic> order) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Детали заказа'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Дата заказа: ${_formatDate(order['date'])}'),
            Text('Сумма: ${order['total']} тг'),
            Text('Способ доставки: ${order['deliveryType']}'),
            Text('Период аренды: ${order['rentalPeriod']}'),
            Text(''),
            Divider(),
            Text('Товары:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...(order['items'] as List<Equipment>).map(
              (item) => ListTile(
                title: Text(item.name),
                subtitle: Text(_getRentalPrice(item)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Закрыть'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Спортивный инвентарь'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showOrderHistory(),
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: LoyaltyWidget(
                      loyalty: userLoyalty,
                      loyaltyService: _loyaltyService,
                    ),
                  ),
                ),
              );
            },
          ),
          Stack(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _showCart(),
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortEquipment();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'price', child: Text('По цене')),
              const PopupMenuItem(value: 'rating', child: Text('По рейтингу')),
              const PopupMenuItem(value: 'name', child: Text('По названию')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
Column(
  children: [
    Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Поиск инвентаря...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) => _search(value),
      ),
    ),
    // Добавляем категории здесь
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) =>
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip( // Заменяем FilterChip на ChoiceChip
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                  _filterEquipment();
                });
              },
            ),
          ),
        ).toList(),
      ),
    ),
    Expanded(
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _equipment.isEmpty
              ? Center(child: Text('Нет доступного инвентаря'))
              : ListView.builder(
                  itemCount: _equipment.length,
                  itemBuilder: (context, index) {
                    final item = _equipment[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                                  leading: item.images.isNotEmpty
                                      ? Image.network(
                                          item.images.first,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(Icons.sports),
                                  title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.description),
                            Row(
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.amber),
                                Text(' ${item.rating.toStringAsFixed(1)} '),
                                Text('(${item.reviewCount} отзывов)'),
                              ],
                            ),
                          ],
                        ),
                                  trailing: Container(
                                    width: 140,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${item.rentalPrices['day']} KZT/день',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(width: 4),
                                            SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(Icons.add_shopping_cart, size: 20),
                                                onPressed: () => _addToCart(item),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

void _addToCart(Equipment item) {
  setState(() {
    _cartItems.add(item);
  });
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Добавлено'), // Изменено сообщение
      duration: Duration(seconds: 1), // Уменьшено время показа
      action: SnackBarAction(
        label: 'Отмена',
        onPressed: () {
          setState(() {
            _cartItems.remove(item);
          });
        },
      ),
    ),
  );
}


// Обновленный метод _showCart
void _showCart() {
  showModalBottomSheet(
    isScrollControlled: true, // Добавлено для предотвращения переполнения
    context: context,
    builder: (context) => SingleChildScrollView( // Обернуто в SingleChildScrollView
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Добавлено для предотвращения переполнения
          children: [
            Text(
              'Корзина',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Container(
              height: 200, // Фиксированная высота для списка
              child: _cartItems.isEmpty
                  ? Center(child: Text('Корзина пуста'))
                  : ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return ListTile(
                          leading: item.images.isNotEmpty
                              ? Image.network(
                                  item.images.first,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.sports),
                          title: Text(item.name),
                          subtitle: Text(_getRentalPrice(item)),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setState(() {
                                _cartItems.removeAt(index);
                              });
                              Navigator.pop(context);
                              _showCart();
                            },
                          ),
                        );
                      },
                    ),
            ),
            if (_cartItems.isNotEmpty) ...[
              SizedBox(height: 16),
              // Выбор периода аренды
              DropdownButton<String>(
                value: _selectedRentalPeriod,
                items: [
                  DropdownMenuItem(
                    value: 'day',
                    child: Text('1 день'),
                  ),
                  DropdownMenuItem(
                    value: 'week',
                    child: Text('1 неделя'),
                  ),
                  DropdownMenuItem(
                    value: 'twoWeeks',
                    child: Text('2 недели (скидка 40%)'),
                  ),
                  DropdownMenuItem(
                    value: 'month',
                    child: Text('1 месяц'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRentalPeriod = value!;
                  });
                },
              ),
              // Выбор даты
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(_selectedDate == null 
                    ? 'Выберите дату'
                    : 'Дата: ${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'),
              ),
RadioListTile(
  title: Text('Самовывоз'),
  subtitle: Text('Улица Пушкина 25/1'),
  value: 'pickup',
  groupValue: _selectedDeliveryType,
  onChanged: (value) {
    setState(() {
      _selectedDeliveryType = value.toString();
    });
  },
),
RadioListTile(
  title: Text('Доставка (+1000 тг)'),
  value: 'delivery',
  groupValue: _selectedDeliveryType,
  onChanged: (value) {
    setState(() {
      _selectedDeliveryType = value.toString();
    });
  },
),
if (_selectedDeliveryType == 'delivery')
  Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: TextField(
      controller: _deliveryAddressController,
      decoration: InputDecoration(
        labelText: 'Адрес доставки',
        hintText: 'Введите адрес доставки',
      ),
      maxLines: 2,
    ),
  ),
Column(
  children: [
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _cardNumberController,
        decoration: InputDecoration(
          labelText: 'Номер карты',
          hintText: 'XXXX XXXX XXXX XXXX',
        ),
        keyboardType: TextInputType.number,
        maxLength: 16,
      ),
    ),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _cardHolderController,
        decoration: InputDecoration(
          labelText: 'Имя владельца',
          hintText: 'IVAN IVANOV',
        ),
        textCapitalization: TextCapitalization.characters,
      ),
    ),
    Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _expiryDateController,
              decoration: InputDecoration(
                labelText: 'Срок действия',
                hintText: 'MM/YY',
              ),
              keyboardType: TextInputType.number,
              maxLength: 5,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _cvvController,
              decoration: InputDecoration(
                labelText: 'CVV',
                hintText: '***',
              ),
              keyboardType: TextInputType.number,
              maxLength: 3,
              obscureText: true,
            ),
          ),
        ),
      ],
    ),
  ],
),

              Text(
                'Итого: ${_calculateTotal()} тг',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton(
                onPressed: () => _processOrder(),
                child: Text('Оформить заказ'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

// Добавьте эти вспомогательные методы
Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(Duration(days: 30)),
  );
  if (picked != null) {
    setState(() {
      _selectedDate = picked;
    });
  }
}

String _getRentalPrice(Equipment item) {
  switch (_selectedRentalPeriod) {
    case 'week':
      return '${item.rentalPrices['week']} тг/неделя';
    case 'twoWeeks':
      return '${(item.rentalPrices['week']! * 1.4).round()} тг/2 недели'; // 40% скидка от двух недель
    case 'month':
      return '${item.rentalPrices['month']} тг/месяц';
    default:
      return '${item.rentalPrices['day']} тг/день';
  }
}

int _calculateTotal() {
  double total = 0;
  
  for (var item in _cartItems) {
    switch (_selectedRentalPeriod) {
      case 'week':
        total += item.rentalPrices['week']!;
        break;
      case 'twoWeeks':
        total += (item.rentalPrices['week']! * 1.4); // 40% скидка от двух недель
        break;
      case 'month':
        total += item.rentalPrices['month']!;
        break;
      default:
        total += item.rentalPrices['day']!;
    }
  }

  // Добавляем стоимость доставки
  if (_selectedDeliveryType == 'delivery') {
    total += 1000;
  }

  return total.round();
}

void _sortEquipment() {
  setState(() {
    switch (_sortBy) {
      case 'price':
        _equipment.sort((a, b) => 
          a.rentalPrices['day']!.compareTo(b.rentalPrices['day']!));
        break;
      case 'rating':
        _equipment.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        _equipment.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  });
}

void _processOrder() {
  if (_selectedDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Пожалуйста, выберите дату')),
    );
    return;
  }

  if (_selectedDeliveryType == 'delivery' && _deliveryAddressController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Пожалуйста, введите адрес доставки')),
    );
    return;
  }

  if (_cardNumberController.text.length != 16) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Пожалуйста, введите корректный номер карты')),
    );
    return;
  }

  if (_cardHolderController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Пожалуйста, введите имя владельца карты')),
    );
    return;
  }

  if (!_isValidExpiryDate(_expiryDateController.text)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Пожалуйста, введите корректный срок действия карты')),
    );
    return;
  }

  if (_cvvController.text.length != 3) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Пожалуйста, введите корректный CVV код')),
    );
    return;
  }

  final order = {
    'date': DateTime.now(),
    'items': List<Equipment>.from(_cartItems),
    'total': _calculateTotal(),
    'deliveryType': _selectedDeliveryType,
    'deliveryAddress': _selectedDeliveryType == 'pickup' 
        ? 'Улица Пушкина 25/1' 
        : _deliveryAddressController.text,
    'rentalPeriod': _selectedRentalPeriod,
    'selectedDate': _selectedDate,
  };

  setState(() {
    _orderHistory.add(order);
    _cartItems.clear();
  });

  _cardNumberController.clear();
  _cardHolderController.clear();
  _expiryDateController.clear();
  _cvvController.clear();
  _deliveryAddressController.clear();
  _selectedDate = null;

  Navigator.pop(context);
  _showOrderConfirmation();
}

bool _isValidExpiryDate(String date) {
  if (!date.contains('/') || date.length != 5) return false;
  
  final parts = date.split('/');
  if (parts.length != 2) return false;
  
  final month = int.tryParse(parts[0]);
  final year = int.tryParse(parts[1]);
  
  if (month == null || year == null) return false;
  if (month < 1 || month > 12) return false;
  
  final now = DateTime.now();
  final expiry = DateTime(2000 + year, month);
  return expiry.isAfter(now);
}


void _showOrderConfirmation() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Заказ оформлен'),
      content: Text('Спасибо за заказ! Хотите оставить отзыв?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Позже'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _showReviewDialog();
          },
          child: Text('Оставить отзыв'),
        ),
      ],
    ),
  );
}

void _showReviewDialog() {
  final _reviewController = TextEditingController();
  double _rating = 5.0;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Оставить отзыв'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _rating,
            min: 1,
            max: 5,
            divisions: 4,
            label: _rating.toString(),
            onChanged: (value) {
              setState(() {
                _rating = value;
              });
            },
          ),
          TextField(
            controller: _reviewController,
            decoration: InputDecoration(
              labelText: 'Ваш отзыв',
              hintText: 'Расскажите о вашем опыте...',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            // Здесь должна быть логика сохранения отзыва
            setState(() {
              _hasReviewed = true;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Спасибо за ваш отзыв!')),
            );
          },
          child: Text('Отправить'),
        ),
      ],
    ),
  );
}

// В методе _showBookingDialog замените использование DeliveryType на строки:
void _showBookingDialog(BuildContext context, DateTime date, dynamic slot) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Подтверждение бронирования'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Дата: ${date.day}.${date.month}.${date.year}'),
          SizedBox(height: 16),
          Text('Выберите способ получения:'),
          RadioListTile(
            title: Text('Самовывоз'),
            subtitle: Text('Улица Пушкина 25/1'),
            value: 'pickup',
            groupValue: _selectedDeliveryType,
            onChanged: (value) {
              setState(() {
                _selectedDeliveryType = value.toString();
              });
            },
          ),
          RadioListTile(
            title: Text('Доставка'),
            value: 'delivery',
            groupValue: _selectedDeliveryType,
            onChanged: (value) {
              setState(() {
                _selectedDeliveryType = value.toString();
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Подтвердить'),
        ),
      ],
    ),
  );
}


@override
void dispose() {
  _searchController.dispose();
  _tabController.dispose();
  _cardNumberController.dispose();
  _cardHolderController.dispose();
  _expiryDateController.dispose();
  _cvvController.dispose();
  _deliveryAddressController.dispose(); // Добавлено
  super.dispose();
}
}

