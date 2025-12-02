import 'package:flutter/material.dart';
import 'dart:async';

class EcoEnergyGame extends StatefulWidget {
  const EcoEnergyGame({super.key});

  @override
  State<EcoEnergyGame> createState() => _EcoEnergyGameState();
}

class _EcoEnergyGameState extends State<EcoEnergyGame> {
  int score = 0;
  int lives = 3;
  int level = 1;
  int timer = 20;
  late Timer countdown;

  final int levelThreshold = 80;

  final List<_EnergyItem> items = [
    _EnergyItem("Ampoule LED", "assets/images/lampe_led.png", 10, true),
    _EnergyItem("Panneau solaire", "assets/images/energie_solaire.png", 15, true),
    _EnergyItem("Éolienne", "assets/images/eolienne.png", 20, true),

    _EnergyItem("Charbon", "assets/images/charbon.png", -10, false),
    _EnergyItem("Pollution", "assets/images/pollution.png", -15, false),
    _EnergyItem("Déchets toxiques", "assets/images/dechets_toxiques.png", -20, false),
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    countdown = Timer.periodic(const Duration(seconds: 1), (timerTick) {
      if (timer <= 0) {
        timerTick.cancel();
        loseLife();
      } else {
        setState(() => timer--);
      }
    });
  }

  void resetTimer() {
    timer = 20;
  }

  void addScore(int value) {
    setState(() {
      score += value;
    });

    if (value < 0 && score <= 0) {
      score = 0;
      loseLife();
    }

    checkCongratulations();
    resetTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value > 0 ? "Bravo ! +$value points 🌿" : "Mauvais choix ! $value points ❌",
        ),
        duration: const Duration(milliseconds: 600),
        backgroundColor: value > 0 ? const Color(0xFF2E7D32) : Colors.red,
      ),
    );
  }

  void loseLife() {
    setState(() => lives--);

    if (lives <= 0) {
      showGameOver();
    } else {
      resetTimer();
      startTimer();
    }
  }

  void checkCongratulations() {
    if (score >= levelThreshold) {
      countdown.cancel();
      showCongratulations();
    }
  }

  // 🎉 FÉLICITATIONS — CORRIGÉ
  void showCongratulations() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Félicitations 🎉"),
        content: Text("Tu as atteint $levelThreshold points !"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                level++;
                score = 0;
                resetTimer();
                startTimer();
              });
            },
            child: const Text("Niveau suivant"),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context); // ferme popup
              Navigator.pop(context); // retourne au menu
            },
            child: const Text("Quitter"),
          ),
        ],
      ),
    );
  }

  // 💀 GAME OVER — CORRIGÉ
  void showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Game Over 💀"),
        content: Text("Ton score final : $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ferme popup
              Navigator.pop(context); // retourne au menu
            },
            child: const Text("Quitter"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                score = 0;
                lives = 3;
                timer = 20;
                level = 1;
              });
              startTimer();
            },
            child: const Text("Rejouer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Énergie Verte"),
        backgroundColor: const Color(0xFF1B5E20),
      ),

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
            const SizedBox(height: 20),

            const Text(
              "Sélectionne les bonnes énergies",
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(children: [
                      const Icon(Icons.bolt, color: Color(0xFF2E7D32), size: 28),
                      const SizedBox(width: 6),
                      Text("$score", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ]),
                    Row(children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 28),
                      const SizedBox(width: 6),
                      Text("$lives", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ]),
                    Row(children: [
                      const Icon(Icons.timer, color: Colors.black, size: 28),
                      const SizedBox(width: 6),
                      Text("$timer s", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),

                      leading: Image.asset(item.image, width: 50, height: 50),

                      title: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => addScore(item.points),
                        child: const Text("Choisir"),
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

class _EnergyItem {
  final String label;
  final String image;
  final int points;
  final bool isGood;

  _EnergyItem(this.label, this.image, this.points, this.isGood);
}
