import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hospedaje_f1/src/auth/services/auth_service.dart';
import 'package:hospedaje_f1/src/auth/models/employee.dart';
import 'package:hospedaje_f1/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeService {
  // Obtener detalles del empleado
  static Future<Employee?> getEmployeeDetails(int id) async {
    final url = Uri.parse('${Api.baseUrl}/api/v1/employee/$id');

    final token = await AuthService().getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Employee.fromJson(data);
      } else {
        throw Exception('Error al obtener los detalles del empleado');
      }
    } catch (e) {
      throw Exception('Error en la conexión: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> createEmployee({
    required String documentType,
    required String documentNumber,
    required String name,
    required String lastName,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    final body = {
      "documentType": documentType,
      "documentNumber": documentNumber,
      "name": name,
      "lastName": lastName,
      "phone": phone,
      "empresa_id": 1,
      "usuario_id": userId,
    };

    final response = await http.post(
      Uri.parse('${Api.baseUrl}/api/v1/employee'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['id'] != null) {
        await prefs.setInt('employeeId', data['id']);
      }
      return {
        'status': response.statusCode,
        'data': data,
      };
    } else {
      return {
        'status': response.statusCode,
        'message': 'Error al crear empleado',
      };
    }
  }

}
