import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hospedaje_f1/src/cleaning/models/room.dart';
import 'package:hospedaje_f1/src/auth/services/auth_service.dart';
import 'package:hospedaje_f1/api.dart';

class RoomService {
  // Obtener todas las habitaciones sin filtros
  static Future<List<Room>> getAllRooms() async {
    final url = Uri.parse('${Api.baseUrl}/api/v1/rooms?page=0&size=100&sort=number');

    final token = await AuthService().getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', 
      'Accept-Charset': 'utf-8',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> content = data['content'];

      return content.map((roomJson) => Room.fromJson(roomJson)).toList();
    } else {
      throw Exception('Error al obtener las habitaciones (status ${response.statusCode})');
    }
  }

  // Mantener el método original para compatibilidad
  static Future<List<Room>> getRooms() async {
    final url = Uri.parse('${Api.baseUrl}/api/v1/rooms?statusCleaning=PARA_LIMPIAR');

    final token = await AuthService().getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', 
      'Accept-Charset': 'utf-8',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> content = data['content'];

      if (content.isEmpty) {
        throw Exception('No hay habitaciones para limpiar.');
      }

      return content.map((roomJson) => Room.fromJson(roomJson)).toList();
    } else {
      throw Exception('Error al obtener las habitaciones (status ${response.statusCode})');
    }
  }

  // Obtener habitación por ID
  static Future<Room?> getRoomById(int id) async {
    final url = Uri.parse('${Api.baseUrl}/api/v1/room/$id');

    final token = await AuthService().getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', 
      'Accept-Charset': 'utf-8',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      return Room.fromJson(data);
    } else {
      throw Exception('Error al obtener la habitación');
    }
  }

  // Iniciar limpieza de una habitación
  static Future<void> startCleaning(int roomId, int employeeId) async {
    final url = Uri.parse('${Api.baseUrl}/api/v1/cleaning');

    final token = await AuthService().getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept-Charset': 'utf-8',
    };

    final response = await http.post(url,
        headers: headers,
        body: json.encode({
          'employeeId': employeeId.toString(),
          'roomId': roomId.toString(),
        }));

    if (response.statusCode != 200) {
      throw Exception('Error al iniciar la limpieza');
    }
  }
}