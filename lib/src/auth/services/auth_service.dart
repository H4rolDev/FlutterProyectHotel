import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospedaje_f1/api.dart';

class AuthService {
  final String _baseUrl = '${Api.baseUrl}/api/v1/user';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/signin'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        await _saveUserData(responseBody);
        return {
          'status': 200,
          'message': 'Login exitoso',
          'data': responseBody,
        };
      } else {
        return {
          'status': response.statusCode,
          'message': responseBody['message'] ?? 'Error desconocido',
          'data': responseBody,
        };
      }
    } catch (e) {
      return {
        'status': 500,
        'message': 'Error en la conexión: ${e.toString()}',
      };
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', userData['token'] ?? '');
    await prefs.setInt('id', userData['id'] ?? 0);
    await prefs.setString('email', userData['email'] ?? '');

    if (userData['roles'] != null) {
      await prefs.setStringList('roles', List<String>.from(userData['roles']));
    }

    if (userData['employeeId'] != null) {
      await prefs.setInt('employeeId', userData['employeeId']);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
