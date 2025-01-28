// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/';
  
  Future<String> getAuthToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
  }

  Future<Map<String, dynamic>> _makeRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
  }) async {
    final token = await getAuthToken();
    final headers = {
      'Authorization': token,
      'Content-Type': 'application/json',
    };

    late http.Response response;

    switch (method) {
      case 'GET':
        response = await http.get(
          Uri.parse('$baseUrl/$endpoint'),
          headers: headers,
        );
        break;
      case 'POST':
        response = await http.post(
          Uri.parse('$baseUrl/$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        );
        break;
      // Добавьте другие методы при необходимости
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.body}');
    }
  }

  // Методы для работы с фитнес-центрами
  Future<List<Map<String, dynamic>>> getFitnessCenters() async {
    final response = await _makeRequest('fitness-centers/', 'GET');
    return List<Map<String, dynamic>>.from(response['results']);
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    return await _makeRequest('bookings/', 'POST', body: bookingData);
  }

  Future<List<Map<String, dynamic>>> getUserBookings() async {
    final response = await _makeRequest('bookings/', 'GET');
    return List<Map<String, dynamic>>.from(response['results']);
  }
}
