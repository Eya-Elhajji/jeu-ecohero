import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class EcoMemoryGame extends StatefulWidget {
  const EcoMemoryGame({super.key});

  @override
  State<EcoMemoryGame> createState() => _EcoMemoryGameState();
}

class _EcoMemoryGameState extends State<EcoMemoryGame> {
  // --- LISTE ICONES ECO ---
  final List<String> ecoIcons = [
    "♻️", "🌿", "🌍", "🌳", "☀️", "💧",
    "🐝", "🍃", "🌱", "🔥", "🌾", "🦋",
    "🍀", "🪵", "🌡️", "🪴"
  ];

  // --- LEVEL SYSTEM ---
  int level = 1;
  int score = 0;

  // --- CHRONOMÈTRE ---
  int seconds = 0;
  Timer? timer;

  // --- JEU ---
  bool waiting = false;
  _CardModel? firstCard;
  List<_CardModel> cards = [];

  @override
  void initState() {
    super.initState();
    loadLevel(level);
  }

  // --- CHARGER UN NIVEAU ---
  void loadLevel(int newLevel) {
    timer?.cancel();
    level = newLevel;
    firstCard = null;
    waiting = false;
    score = 0;
    seconds = 0;

    int pairs = 4 * level; // Niveau 1=4, 2=8, 3=12, 4=16
    List<String> selected = ecoIcons.take(pairs).toList();

    List<String> allCards = [...selected, ...selected];
    allCards.shuffle(Random());

    cards = allCards.map((icon) => _CardModel(icon: icon)).toList();

    startTimer();
    setState(() {});
  }

  // --- MODE CHRONOMÈTRE ---
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
  }

  String formatTime(int s) {
    int m = s ~/ 60;
    int sec = s % 60;
    return "${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  // --- TAP SUR CARTE ---
  void onCardTap(_CardModel card) {
    if (waiting || card.revealed || card.matched) return;

    setState(() => card.revealed = true);

    if (firstCard == null) {
      firstCard = card;
      return;
    }

    if (firstCard!.icon == card.icon) {
      setState(() {
        firstCard!.matched = true;
        card.matched = true;
        score++;
      });
      firstCard = null;

      if (score == cards.length ~/ 2) {
        timer?.cancel();
        Future.delayed(const Duration(milliseconds: 400), showWinDialog);
      }
    } else {
      waiting = true;
      Timer(const Duration(milliseconds: 700), () {
        setState(() {
          firstCard!.revealed = false;
          card.revealed = false;
          firstCard = null;
          waiting = false;
        });
      });
    }
  }

  // --- CALCUL ÉTOILES SELON LE TEMPS ---
  int getStars() {
    int maxPairs = cards.length ~/ 2;

    int perfect = maxPairs * 4;   // ⭐⭐⭐
    int good = maxPairs * 6;      // ⭐⭐
    int okay = maxPairs * 8;      // ⭐

    if (seconds <= perfect) return 3;
    if (seconds <= good) return 2;
    if (seconds <= okay) return 1;
    return 0;
  }

  // --- POPUP DE VICTOIRE ---
  void showWinDialog() {
    int stars = getStars();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Niveau terminé 🎉",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Temps : ${formatTime(seconds)}",
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 12),

            const Text("Étoiles obtenues :", style: TextStyle(fontSize: 18)),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (i) => Icon(
                  Icons.star,
                  size: 32,
                  color: (i < stars) ? Colors.amber : Colors.grey,
                ),
              ),
            )
          ],
        ),

        actions: [
          if (level < 4)
            TextButton(
              child: Text("Niveau ${level + 1} →"),
              onPressed: () {
                Navigator.pop(context);
                loadLevel(level + 1);
              },
            ),

          TextButton(
            child: const Text("Rejouer"),
            onPressed: () {
              Navigator.pop(context);
              loadLevel(level);
            },
          ),

          // --- BOUTON QUITTER CORRIGÉ ---
          TextButton(
            child: const Text("Quitter"),
            onPressed: () {
              Navigator.pop(context);      // ferme la popup
              Navigator.of(context).pop(); // revient au menu de jeux
            },
          ),
        ],
      ),
    );
  }

  // --- UI ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    int crossAxisCount =
    (level == 1) ? 3 :
    (level == 2) ? 4 :
    (level == 3) ? 4 :
    4;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Text("Eco Memory — Niveau $level"),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                formatTime(seconds),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Paires trouvées : $score / ${cards.length ~/ 2}",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20)),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: GridView.builder(
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemBuilder: (context, index) {
                  final card = cards[index];

                  return GestureDetector(
                    onTap: () => onCardTap(card),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: card.revealed || card.matched
                            ? Colors.white
                            : const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(1, 2))
                        ],
                      ),
                      child: Center(
                        child: Text(
                          card.revealed || card.matched ? card.icon : "",
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- CARD MODEL ---
class _CardModel {
  String icon;
  bool revealed;
  bool matched;

  _CardModel({
    required this.icon,
    this.revealed = false,
    this.matched = false,
  });
}
