import 'package:flutter/material.dart';
import '../models/training.dart';
import '../models/gym_room.dart';
import '../services/booking_service.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  late TabController _tabController;
  List<Training> _trainings = [];
  List<GymRoom> _rooms = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final trainings = await _bookingService.getAvailableTrainings();
      final rooms = await _bookingService.getAvailableRooms();
      setState(() {
        _trainings = trainings;
        _rooms = rooms;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Бронирование'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Тренировки'),
            Tab(text: 'Залы'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrainingsTab(),
          _buildRoomsTab(),
        ],
      ),
    );
  }

  Widget _buildTrainingsTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _trainings.length,
      itemBuilder: (context, index) {
        final training = _trainings[index];
        return Card(
          margin: EdgeInsets.all(8),
          child: ListTile(
            leading: Image.network(training.imageUrl),
            title: Text(training.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(training.description),
                Text('Тренер: ${training.trainerName}'),
                Text('${training.currentParticipants}/${training.maxParticipants} участников'),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _bookTraining(training),
              child: Text('Записаться'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomsTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return Card(
          margin: EdgeInsets.all(8),
          child: Column(
            children: [
              Image.network(room.images.first),
              ListTile(
                title: Text(room.name),
                subtitle: Text(room.description),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${room.prices['hourly']} тг/час'),
                    ElevatedButton(
                      onPressed: () => _bookRoom(room),
                      child: Text('Забронировать'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

void _bookTraining(Training training) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Бронирование тренировки',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(training.name),
                subtitle: Text(training.description),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Тренер: ${training.trainerName}'),
              ),
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Время: ${DateFormat('dd.MM.yyyy HH:mm').format(training.startTime)} - '
                    '${DateFormat('HH:mm').format(training.endTime)}'),
              ),
              ListTile(
                leading: Icon(Icons.group),
                title: Text('Участники: ${training.currentParticipants}/${training.maxParticipants}'),
              ),
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text('Стоимость: ${training.price} тг'),
              ),
              SizedBox(height: 16),
              // Платежная информация
              TextField(
                decoration: InputDecoration(
                  labelText: 'Номер карты',
                  hintText: 'XXXX XXXX XXXX XXXX',
                ),
                keyboardType: TextInputType.number,
                maxLength: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Срок действия',
                        hintText: 'MM/YY',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '***',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Отмена'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _bookingService.bookTraining(
                          training.id,
                          'current_user_id', // Замените на реальный ID пользователя
                        );
                        
                        Navigator.pop(context);
                        _showSuccessDialog('Тренировка успешно забронирована!');
                      } catch (e) {
                        _showErrorDialog('Ошибка при бронировании: $e');
                      }
                    },
                    child: Text('Подтвердить бронирование'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

void _bookRoom(GymRoom room) {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Бронирование зала',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(room.name),
                subtitle: Text(room.description),
              ),
              // Выбор даты
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text(selectedDate == null 
                    ? 'Выберите дату' 
                    : DateFormat('dd.MM.yyyy').format(selectedDate!)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              // Выбор времени начала
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text(startTime == null 
                    ? 'Время начала' 
                    : startTime!.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => startTime = picked);
                  }
                },
              ),
              // Выбор времени окончания
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text(endTime == null 
                    ? 'Время окончания' 
                    : endTime!.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => endTime = picked);
                  }
                },
              ),
              // Стоимость
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text('Стоимость: ${_calculateRoomPrice(room, startTime, endTime)} тг'),
              ),
              SizedBox(height: 16),
              // Платежная информация
              TextField(
                decoration: InputDecoration(
                  labelText: 'Номер карты',
                  hintText: 'XXXX XXXX XXXX XXXX',
                ),
                keyboardType: TextInputType.number,
                maxLength: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Срок действия',
                        hintText: 'MM/YY',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '***',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Отмена'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedDate == null || startTime == null || endTime == null) {
                        _showErrorDialog('Пожалуйста, выберите дату и время');
                        return;
                      }

                      final startDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        startTime!.hour,
                        startTime!.minute,
                      );

                      final endDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        endTime!.hour,
                        endTime!.minute,
                      );

                      try {
                        // Проверка доступности
                        final isAvailable = await _bookingService.checkRoomAvailability(
                          room.id,
                          startDateTime,
                          endDateTime,
                        );

                        if (!isAvailable) {
                          _showErrorDialog('Зал уже забронирован на это время');
                          return;
                        }

                        // Бронирование
                        await _bookingService.bookGymRoom(
                          room.id,
                          'current_user_id', // Замените на реальный ID пользователя
                          startDateTime,
                          endDateTime,
                        );

                        Navigator.pop(context);
                        _showSuccessDialog('Зал успешно забронирован!');
                      } catch (e) {
                        _showErrorDialog('Ошибка при бронировании: $e');
                      }
                    },
                    child: Text('Подтвердить бронирование'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

// Вспомогательные методы
void _showSuccessDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Успешно'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Ошибка'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

double _calculateRoomPrice(GymRoom room, TimeOfDay? startTime, TimeOfDay? endTime) {
  if (startTime == null || endTime == null) return 0;
  
  final start = startTime.hour + startTime.minute / 60;
  final end = endTime.hour + endTime.minute / 60;
  final hours = end - start;
  
  return room.prices['hourly']! * hours;
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
