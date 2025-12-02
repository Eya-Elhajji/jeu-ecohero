import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class EcoPuzzle extends StatefulWidget {
  const EcoPuzzle({super.key});

  @override
  State<EcoPuzzle> createState() => _EcoPuzzleState();
}

class _EcoPuzzleState extends State<EcoPuzzle> {
  int level = 1;
  int gridSize = 3;
  List<int> tiles = []; // tiles[pos] = pieceIndex placed at position pos
  ui.Image? fullImage;

  Timer? timer;
  int timeLeft = 45;

  int moves = 0;
  int? firstSelectedPos; // position index of the first tapped tile (for swapping)

  final Map<int, String> levelImages = {
    1: "assets/images/poubelle_bleue.png",
    2: "assets/images/maison.png",
    3: "assets/images/terre.png",
  };

  @override
  void initState() {
    super.initState();
    startLevel();
  }

  @override
  void dispose() {
    timer?.cancel();
    fullImage?.dispose();
    super.dispose();
  }

  // -------------------------
  // Initialise / démarre niveau
  // -------------------------
  Future<void> startLevel() async {
    if (level == 1) {
      gridSize = 3;
      timeLeft = 45;
    } else if (level == 2) {
      gridSize = 4;
      timeLeft = 60;
    } else {
      gridSize = 5;
      timeLeft = 90;
    }

    moves = 0;
    firstSelectedPos = null;

    // génère l'état résolu puis mélange
    tiles = List.generate(gridSize * gridSize, (i) => i);
    tiles.shuffle();

    // charge l'image du niveau (async)
    final imgPath = levelImages[level];
    if (imgPath != null) {
      await _loadImage(imgPath);
    } else {
      fullImage = null;
    }

    startTimer();

    setState(() {});
  }

  // -------------------------
  // Charger image depuis assets et décoder en ui.Image
  // -------------------------
  Future<void> _loadImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo fi = await codec.getNextFrame();
      // dispose ancienne image si existante
      fullImage?.dispose();
      fullImage = fi.image;
    } catch (e) {
      // en cas d'erreur de chargement on met fullImage à null
      fullImage = null;
      debugPrint("Erreur chargement image $assetPath : $e");
    }
  }

  // -------------------------
  // Timer (optionnel)
  // -------------------------
  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        timer?.cancel();
        showLoseDialog();
      }
    });
  }

  // -------------------------
  // Interaction : tap pour sélectionner/échanger deux tuiles
  // -------------------------
  void onTileTap(int pos) {
    if (fullImage == null) return; // si image pas prête, on ignore

    setState(() {
      if (firstSelectedPos == null) {
        firstSelectedPos = pos;
      } else if (firstSelectedPos == pos) {
        // désélection si re-tap sur la même
        firstSelectedPos = null;
      } else {
        // swap entre firstSelectedPos et pos
        final int a = firstSelectedPos!;
        final int b = pos;
        final temp = tiles[a];
        tiles[a] = tiles[b];
        tiles[b] = temp;
        moves++;
        firstSelectedPos = null;

        // vérifier si résolu
        if (isSolved()) {
          timer?.cancel();
          Future.microtask(() => showWinDialog());
        }
      }
    });
  }

  // -------------------------
  // Détection victoire
  // -------------------------
  bool isSolved() {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] != i) return false;
    }
    return true;
  }

  // -------------------------
  // Dialogs
  // -------------------------
  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Bravo ! 🌿", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        content: Text("Tu as complété le niveau $level en $moves mouvements et ${ ( ( (level==1)?45: (level==2)?60:90) - timeLeft) } secondes."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startLevel();
            },
            child: const Text("Rejouer"),
          ),
          if (level < 3)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => level++);
                startLevel();
              },
              child: const Text("Niveau suivant"),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text("Quitter"),
          ),
        ],
      ),
    );
  }

  void showLoseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Temps écoulé ⏳", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        content: const Text("Le temps est écoulé. Veux-tu réessayer ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startLevel();
            },
            child: const Text("Rejouer"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text("Quitter"),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // UI Build
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double gridDisplaySize = (screenWidth * 0.9).clamp(200.0, 600.0);
    final double tileSize = gridDisplaySize / gridSize;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Text("Eco Puzzle - Niveau $level"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text("⏱ $timeLeft s", style: const TextStyle(fontSize: 18))),
          )
        ],
      ),
      body: Center(
        child: fullImage == null
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text("Chargement de l'image...", style: TextStyle(fontSize: 16)),
          ],
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Affichage des infos (mouvements)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Mouvements : $moves",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),

            // Grid puzzle
            SizedBox(
              width: gridDisplaySize,
              height: gridDisplaySize,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tiles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  childAspectRatio: 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, pos) {
                  final pieceIndex = tiles[pos];
                  final pieceRow = pieceIndex ~/ gridSize;
                  final pieceCol = pieceIndex % gridSize;
                  final isSelected = (firstSelectedPos == pos);

                  return GestureDetector(
                    onTap: () => onTileTap(pos),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: Colors.orangeAccent, width: 3)
                            : Border.all(color: Colors.green.shade50, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomPaint(
                          size: Size(tileSize, tileSize),
                          painter: PuzzlePiecePainter(
                            fullImage: fullImage!,
                            row: pieceRow,
                            col: pieceCol,
                            gridSize: gridSize,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    startLevel();
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text("Rejouer"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
                ),
                const SizedBox(width: 12),
                if (level < 3)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => level++);
                      startLevel();
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Suivant"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700),
                  ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text("Quitter"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------
// Painter : dessine la portion correcte de l'image
// -------------------------
class PuzzlePiecePainter extends CustomPainter {
  final ui.Image fullImage;
  final int row;
  final int col;
  final int gridSize;

  PuzzlePiecePainter({
    required this.fullImage,
    required this.row,
    required this.col,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double pieceWidth = fullImage.width / gridSize;
    final double pieceHeight = fullImage.height / gridSize;

    final src = Rect.fromLTWH(
      col * pieceWidth,
      row * pieceHeight,
      pieceWidth,
      pieceHeight,
    );

    final dst = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint();
    canvas.drawImageRect(fullImage, src, dst, paint);
  }

  @override
  bool shouldRepaint(covariant PuzzlePiecePainter oldDelegate) {
    return oldDelegate.fullImage != fullImage ||
        oldDelegate.row != row ||
        oldDelegate.col != col ||
        oldDelegate.gridSize != gridSize;
  }
}
