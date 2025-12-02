import 'package:flutter/material.dart';

// ANCIENS JEUX

import 'eco_quiz_screen.dart';
import 'tri_express_screen.dart';
import 'eco_energy_game.dart';


// NOUVEAUX JEUX
import 'eco_memory.dart';
import 'eco_puzzle.dart';

class GamesMenu extends StatelessWidget {
  const GamesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_GameItem> games = [
      _GameItem("Eco Quiz", Icons.quiz, const EcoQuizScreen()),

      _GameItem("Tri Express", Icons.recycling, const TriExpressScreen()),
      _GameItem("Énergie Verte", Icons.bolt, EcoEnergyGame()),


      // 🌱 NOUVEAUX JEUX
      _GameItem("Eco Memory", Icons.grid_view, const EcoMemoryGame()),
      _GameItem("Eco Puzzle", Icons.extension, const EcoPuzzle()),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA5D6A7), Color(0xFF66BB6A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          children: [
            // 🌳 HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
              decoration: const BoxDecoration(
                color: Color(0xFF1B5E20),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.sports_esports,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  const Text(
                    "Menu des Jeux",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🎮 LISTE ANIMÉE DES JEUX
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 400 + (index * 120)),
                    curve: Curves.easeOutBack,

                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value.clamp(0.0, 1.0), // ✅ FIX
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 40),
                          child: child,
                        ),
                      );
                    },

                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(20),
                        leading: Icon(
                          game.icon,
                          color: const Color(0xFF1B5E20),
                          size: 34,
                        ),
                        title: Text(
                          game.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.grey),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => game.page),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameItem {
  final String title;
  final IconData icon;
  final Widget page;

  _GameItem(this.title, this.icon, this.page);
}
