import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedTimeSlot = '';
  final List<String> timeSlots = [
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
    '19:00 - 20:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Расписание'),
      ),
      body: Column(
        children: [
          // Календарь
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Выберите дату',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8),
                CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 30)),
                  onDateChanged: (DateTime value) {
                    setState(() {
                      selectedDate = value;
                      selectedTimeSlot = '';
                    });
                  },
                ),
              ],
            ),
          ),

          // Временные слоты
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Доступное время',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: timeSlots.length,
                      itemBuilder: (context, index) {
                        final timeSlot = timeSlots[index];
                        final isSelected = timeSlot == selectedTimeSlot;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedTimeSlot = timeSlot;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              timeSlot,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Кнопка бронирования
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selectedTimeSlot.isEmpty
                  ? null
                  : () => _handleBooking(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Забронировать',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBooking(BuildContext context) async {
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final userId = 'current-user-id'; // Получите реальный ID пользователя
      
      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        fitnesscenterId: 'fitness-center-id', // Замените на реальный ID
        date: selectedDate,
        timeSlot: selectedTimeSlot,
        createdAt: DateTime.now(),
      );

      await bookingProvider.createBooking(booking);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Бронирование успешно создано')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при создании бронирования: $e')),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
