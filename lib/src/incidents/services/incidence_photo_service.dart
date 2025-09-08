import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hospedaje_f1/src/auth/services/auth_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';
import 'package:hospedaje_f1/api.dart'; 

class IncidentPhotoService {
  static const String _baseUrl = '${Api.baseUrl}/api/v1/incident-photo';

  static Future<bool> uploadIncidentPhoto({
    required int incidentId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) {
        print('Error: Token no disponible o vacío.');
        return false;
      }

      final mimeType = mime(fileName);
      if (mimeType == null) {
        print('Error: Tipo de archivo no reconocido');
        return false;
      }

      final mimeData = mimeType.split('/');
      final fileType = mimeData[0];
      final fileSubtype = mimeData[1];

      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['incidentId'] = incidentId.toString();

      var multipartFile = http.MultipartFile.fromBytes(
        'imageUrl',
        imageBytes,
        filename: fileName,
        contentType: MediaType(fileType, fileSubtype),
      );
      request.files.add(multipartFile);

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Foto de incidencia subida con éxito');
        return true;
      } else {
        print('Error al subir foto de incidencia: ${response.statusCode}');
        print('Error Response body: $responseBody');
        return false;
      }
    } catch (e) {
      print('Error al hacer la solicitud: $e');
      return false;
    }
  }
  // Eliminar foto de incidencia
  static Future<bool> deleteIncidentPhoto(int photoId) async {
    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) {
        print('Error: Token no disponible o vacío.');
        return false;
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/$photoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete Response status: ${response.statusCode}');
      print('Delete Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Foto eliminada con éxito');
        return true;
      } else {
        print('Error al eliminar foto: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error al eliminar foto: $e');
      return false;
    }
  }

  // Obtener foto por ID
  static Future<Map<String, dynamic>?> getIncidentPhoto(int photoId) async {
    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) {
        print('Error: Token no disponible o vacío.');
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/$photoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get Photo Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error al obtener foto: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al obtener foto: $e');
      return null;
    }
  }

  // Actualizar foto de incidencia
  static Future<Map<String, dynamic>?> updateIncidentPhoto({
    required int photoId,
    required int incidentId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) {
        print('Error: Token no disponible o vacío.');
        return null;
      }

      final mimeType = mime(fileName);
      if (mimeType == null) {
        print('Error: Tipo de archivo no reconocido');
        return null;
      }

      final mimeData = mimeType.split('/');
      final fileType = mimeData[0];
      final fileSubtype = mimeData[1];

      var request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/$photoId'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['incidentId'] = incidentId.toString();

      var multipartFile = http.MultipartFile.fromBytes(
        'imageUrl',
        imageBytes,
        filename: fileName,
        contentType: MediaType(fileType, fileSubtype),
      );
      request.files.add(multipartFile);

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Update Response status: ${response.statusCode}');
      print('Update Response body: $responseBody');

      if (response.statusCode == 200) {
        print('Foto actualizada con éxito');
        return json.decode(responseBody);
      } else {
        print('Error al actualizar foto: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al actualizar foto: $e');
      return null;
    }
  }
}