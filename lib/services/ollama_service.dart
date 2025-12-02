import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  final String baseUrl;

  OllamaService({required this.baseUrl});

  Future<String> sendMessage(String message) async {
    final url = Uri.parse("$baseUrl/api/generate");
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "model": "gemma2:2b",
      "prompt": message,
      "stream": false,
    });


    try {
    final response = await http.post(url, headers: headers, body: body);

    // Debug : voir la réponse complète
    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data is Map && data.containsKey('response')) {
    return data['response'] as String;
    } else {
    return "Réponse inattendue du serveur.";
    }
    } else {
    return "Erreur serveur : ${response.statusCode}";
    }
    } catch (e) {
    print("Erreur: $e");
    return "Erreur de connexion au serveur Ollama";
    }


  }
}
