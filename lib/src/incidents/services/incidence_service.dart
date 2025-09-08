import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hospedaje_f1/src/auth/services/auth_service.dart';
import 'package:hospedaje_f1/api.dart';

class IncidenceService {
  static const String _baseUrl = '${Api.baseUrl}/api/v1/incident';

  // Función para crear una incidencia
  static Future<bool> createIncidence(String description, int cleaningId) async {
    try {
      final token = await AuthService().getToken();

      if (token == null || token.isEmpty) {
        print('Error: Token no disponible o vacío.');
        return false;
      }

      final body = json.encode({
        'description': description,
        'cleaningId': cleaningId,
      });

      print('Cuerpo de la solicitud que se envía: $body');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Incidencia creada con éxito');
        return true;
      } else {
        print('Error al crear incidencia: ${response.statusCode}');
        print('Error Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al hacer la solicitud: $e');
      return false;
    }
  }
}
