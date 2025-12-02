import 'dart:async';
import 'package:flutter/material.dart';
import 'games_menu.dart'; // 👈 RETOUR AU MENU

class EcoQuizScreen extends StatefulWidget {
  const EcoQuizScreen({super.key});

  @override
  _EcoQuizScreenState createState() => _EcoQuizScreenState();
}

class _EcoQuizScreenState extends State<EcoQuizScreen> {
  int questionIndex = 0;
  int score = 0;
  bool answered = false;
  String selectedAnswer = "";
  int timer = 10;
  Timer? countdown;
  bool isGameOver = false;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Dans quelle poubelle doit-on mettre une bouteille en plastique ?",
      "answers": ["Poubelle verte", "Poubelle bleue", "Poubelle jaune", "Poubelle marron"],
      "correct": "Poubelle jaune",
      "image": "assets/images/bouteille.png"
    },
    {
      "question": "Où doit-on jeter une canette en aluminium ?",
      "answers": ["Poubelle jaune", "Poubelle marron", "Poubelle rouge", "Poubelle verte"],
      "correct": "Poubelle rouge",
      "image": "assets/images/canette.png"
    },
    {
      "question": "Comment doit-on éliminer les déchets toxiques ?",
      "answers": ["Dans la nature", "Dans la poubelle jaune", "Dans la poubelle marron", "Dans un centre spécialisé"],
      "correct": "Dans un centre spécialisé",
      "image": "assets/images/dechets_toxiques.png"
    },
    {
      "question": "Pourquoi les forêts sont-elles importantes ?",
      "answers": ["Elles consomment de l’oxygène", "Elles produisent de l’oxygène", "Elles stockent du plastique", "Elles créent du pétrole"],
      "correct": "Elles produisent de l’oxygène",
      "image": "assets/images/foret.png"
    },
    {
      "question": "Quelle est une cause majeure de pollution de l’air ?",
      "answers": ["L’énergie solaire", "Les vélos", "Les usines", "La forêt"],
      "correct": "Les usines",
      "image": "assets/images/pollution.png"
    },
    {
      "question": "Quel type d’énergie est représenté sur cette image ?",
      "answers": ["Charbon", "Gaz", "Nucléaire", "Solaire"],
      "correct": "Solaire",
      "image": "assets/images/energie_solaire.png"
    },
    {
      "question": "Quel geste rend une maison plus écologique ?",
      "answers": ["Allumer toutes les lumières", "Garder l'eau ouverte", "Éteindre les appareils inutilisés", "Utiliser plus de plastique"],
      "correct": "Éteindre les appareils inutilisés",
      "image": "assets/images/maison.png"
    },
    {
      "question": "Pourquoi utiliser le vélo est-il écologique ?",
      "answers": ["Il consomme du pétrole", "Il ne pollue pas", "Il produit du CO₂", "Il augmente la pollution sonore"],
      "correct": "Il ne pollue pas",
      "image": "assets/images/velo.png"
    },
    {
      "question": "Le tri des déchets sert principalement à :",
      "answers": ["Jeter plus vite", "Recycler correctement", "Garder la poubelle propre", "Faire joli"],
      "correct": "Recycler correctement",
      "image": "assets/images/tri_express.png"
    },
    {
      "question": "Que signifie ce pictogramme ⚠️ ?",
      "answers": ["Danger d'explosion", "Attention / Prudence", "Rien de spécial", "Zone de tri"],
      "correct": "Attention / Prudence",
      "image": "assets/images/icone_warning.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    questions.shuffle();
    startTimer();
  }

  // ---------------- TIMER ----------------

  void startTimer() {
    timer = 10;
    isGameOver = false;
    countdown?.cancel();

    countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (timer > 0) {
          timer--;
        } else {
          t.cancel();
          onTimeOut();
        }
      });
    });
  }

  // --- TIMER FINI → GAME OVER ---
  void onTimeOut() {
    setState(() {
      isGameOver = true;
      answered = true;
    });

    showLoseDialog();
  }

  // ---------------- ANSWER LOGIC ----------------

  void checkAnswer(String answer) {
    if (answered || isGameOver) return;

    setState(() {
      answered = true;
      selectedAnswer = answer;
      countdown?.cancel();

      if (answer == questions[questionIndex]["correct"]) {
        score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (isGameOver) return;

      if (questionIndex < questions.length - 1) {
        setState(() {
          questionIndex++;
          answered = false;
          selectedAnswer = "";
          startTimer();
        });
      } else {
        showResultDialog();
      }
    });
  }

  // ---------------- DIALOG : PERDU ----------------

  void showLoseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("❌ Temps écoulé !", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Tu as perdu.\nScore : $score", style: const TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            child: const Text("Rejouer"),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                score = 0;
                questionIndex = 0;
                selectedAnswer = "";
                answered = false;
                isGameOver = false;
                questions.shuffle();
                startTimer();
              });
            },
          ),
          TextButton(
            child: const Text("Quitter"),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const GamesMenu()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- RESULT ----------------

  void showResultDialog() {
    countdown?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Résultat", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Ton score : $score / ${questions.length}", style: const TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            child: const Text("Rejouer"),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                score = 0;
                questionIndex = 0;
                answered = false;
                selectedAnswer = "";
                questions.shuffle();
                startTimer();
              });
            },
          ),
          TextButton(
            child: const Text("Quitter"),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const GamesMenu()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final question = questions[questionIndex];
    final answers = question["answers"] as List<String>;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        title: const Text("Eco Quiz", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Score + Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Score : $score",
                    style: const TextStyle(fontSize: 22, color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
                Text("⏳ $timer s",
                    style: TextStyle(
                        fontSize: 22,
                        color: timer <= 3 ? Colors.red : Colors.black,
                        fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 20),

            Image.asset(question["image"], height: 150),
            const SizedBox(height: 25),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 3))],
              ),
              child: Text(question["question"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            ),

            const SizedBox(height: 40),

            Expanded(
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (_, i) {
                  final answer = answers[i];
                  final bool isCorrect = answer == question["correct"];
                  final bool isSelected = answer == selectedAnswer;

                  Color tileColor = Colors.white;

                  if (answered || isGameOver) {
                    if (isCorrect) tileColor = Colors.green.withOpacity(0.7);
                    else if (isSelected) tileColor = Colors.red.withOpacity(0.7);
                  }

                  return GestureDetector(
                    onTap: () => checkAnswer(answer),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(1, 3))],
                      ),
                      child: Text(answer,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
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
