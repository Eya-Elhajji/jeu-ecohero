import 'package:flutter/material.dart';
import '../services/ollama_service.dart';
import 'home_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  late OllamaService _ollamaService;
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _ollamaService = OllamaService(baseUrl: "http://localhost:11434");
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() => messages.add({"text": text, "isUser": "true"}));
    _controller.clear();

    try {
      String response = await _ollamaService.sendMessage(text);
      setState(() => messages.add({"text": response, "isUser": "false"}));
    } catch (e) {
      setState(() => messages.add({
        "text": "Erreur de connexion au serveur",
        "isUser": "false"
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌿 IMAGE DE FOND
          Positioned.fill(
            child: Image.asset(
              "assets/images/ecologie.png",
              fit: BoxFit.cover,
            ),
          ),

          // 🌱 DÉGRADÉ VERT PAR-DESSUS
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xAAA5D6A7),
                    Color(0xAA66BB6A),
                    Color(0xAA2E7D32),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 45),

              // 🌿 HEADER TRANSPARENT AVEC RETOUR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Bouton retour
                    Material(
                      color: Colors.green.shade900.withOpacity(0.8),
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => HomeScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    const Icon(Icons.eco, color: Colors.white, size: 28),

                    const SizedBox(width: 10),

                    const Text(
                      "EcoHero Chatbot",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                              offset: Offset(1, 1))
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 📝 LISTE DES MESSAGES
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg['isUser'] == "true";

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth:
                            MediaQuery.of(context).size.width * 0.75),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.white.withOpacity(0.85)
                              : Colors.green.shade50.withOpacity(0.9),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft:
                            Radius.circular(isUser ? 14 : 0),
                            bottomRight:
                            Radius.circular(isUser ? 0 : 14),
                          ),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 3,
                                offset: Offset(1, 1))
                          ],
                        ),
                        child: Text(
                          msg['text']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ✏️ BARRE DE SAISIE
              SafeArea(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Tape ton message...",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.green.shade900,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () => sendMessage(_controller.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
