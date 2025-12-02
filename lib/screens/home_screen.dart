import 'package:flutter/material.dart';
import 'games_menu.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool showMenu = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  void toggleMenu() {
    setState(() {
      showMenu = !showMenu;
      if (showMenu) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double menuHeight = MediaQuery.of(context).size.height * 0.70;

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

          // 🌿 FILTRE DÉGRADÉ
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xAA66BB6A),
                  Color(0xAA388E3C),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🌟 CONTENU
          SafeArea(
            child: Stack(
              children: [
                // 🌟 BOUTONS CENTRAUX
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Chatbot
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1B5E20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 70, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 8,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatScreen()),
                          );
                        },
                        child: const Text(
                          "Chatbot 🤖",
                          style: TextStyle(fontSize: 22),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Menu des jeux
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1B5E20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 55, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 8,
                        ),
                        onPressed: toggleMenu,
                        child: const Text(
                          "Menu des Jeux 🎮",
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🎮 MENU ANIMÉ (sans Scaffold interne)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizeTransition(
                    sizeFactor: _animation,
                    axisAlignment: -1.0,
                    child: Container(
                      height: menuHeight,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.97),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: GamesMenuNoScaffold(), // 🔥 version adaptée
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔥 VERSION SANS SCAFFOLD POUR HOME SCREEN
class GamesMenuNoScaffold extends StatelessWidget {
  const GamesMenuNoScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return GamesMenu(); // appelle la version "contenu seul"
  }
}
