import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hospedaje_f1/src/auth/services/auth_service.dart';
import 'package:hospedaje_f1/api.dart';

class ChatbotService {
  static Future<String> sendMessage(String message) async {
    final url = Uri.parse('${Api.baseUrl}/api/chatbot');

    final token = await AuthService().getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept-Charset': 'utf-8',
    };

    final body = json.encode({
      'message': message,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      return data['message'] as String;
    } else {
      throw Exception('Error al comunicarse con el chatbot (status ${response.statusCode})');
    }
  }
}
