import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hospedaje_f1/src/auth/services/auth_service.dart';
import 'package:hospedaje_f1/src/cleaning/models/cleaning.dart';
import 'package:hospedaje_f1/api.dart';

class CleaningService {
  static Future<Cleaning?> getCleaningById(int cleaningId) async {
    final url = Uri.parse('${Api.baseUrl}/api/v1/cleaning/$cleaningId');

    final token = await AuthService().getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Cleaning.fromJson(data);
    } else {
      throw Exception('Error al obtener los detalles de la limpieza');
    }
  }

  static Future<Cleaning> startCleaning(int roomId, int employeeId) async {
    final url = Uri.parse('${Api.baseUrl}/api/v1/cleaning');

    final token = await AuthService().getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = json.encode({
      'employeeId': employeeId.toString(),
      'roomId': roomId.toString(),
    });

    print('Enviando solicitud a la API para iniciar limpieza:');
    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Cleaning.fromJson(data);
      } else {
        print('Error: La API respondió con un código de error.');
        throw Exception('Error al iniciar la limpieza: ${response.body}');
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
      throw Exception('Error al iniciar la limpieza');
    }
  }

  static Future<void> updateCleaningStatus(
    int cleaningId,
    String status,
  ) async {
    final url = Uri.parse('${Api.baseUrl}/api/v1/cleaning/status/$cleaningId');

    final token = await AuthService().getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el estado de la limpieza');
    }
  }

  static Future<Map<String, dynamic>> getCleaningsByEmployeeId(
    int employeeId, {
    int page = 0,
    int size = 10,
    String sort = 'id,desc',
    String? field,
    String? value,
  }) async {
    String url =
        '${Api.baseUrl}/api/v1/cleaning/employee/$employeeId?page=$page&size=$size&sort=$sort';

    if (field != null && value != null) {
      url += '&field=$field&value=$value';
    }

    final uri = Uri.parse(url);

    final token = await AuthService().getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener las limpiezas del empleado');
    }
  }

  static Future<List<Cleaning>> getCleaningsByFilter({
    required int employeeId,
    String status = 'EN_PROCESO',
    int page = 0,
    int size = 20,
    List<String> sort = const ['id,desc'],
  }) async {
    final uri = Uri.parse('${Api.baseUrl}/api/v1/cleaning').replace(
      queryParameters: {
        'employeeId': employeeId.toString(),
        'status': status,
        'page': page.toString(),
        'size': size.toString(),
        'sort': sort.join(','), // por ejemplo: "id,desc"
      },
    );

    final token = await AuthService().getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((e) => Cleaning.fromJson(e)).toList();
    } else {
      throw Exception(
        'Error al obtener limpiezas filtradas (status: ${response.statusCode})',
      );
    }
  }
}
