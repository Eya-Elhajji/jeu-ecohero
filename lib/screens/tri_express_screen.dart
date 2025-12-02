import 'dart:async';
import 'package:flutter/material.dart';

class TriExpressScreen extends StatefulWidget {
  const TriExpressScreen({super.key});

  @override
  _TriExpressScreenState createState() => _TriExpressScreenState();
}

class _TriExpressScreenState extends State<TriExpressScreen> {
  int score = 0;
  int timeLeft = 30;
  Timer? timer;
  bool isGameOver = false;

  Color feedbackColor = Colors.white;
  bool showFeedback = false;

  late String currentItem;
  final List<String> itemsOrder = [];

  final Map<String, String> correctBins = {
    "bouteille": "plastique",
    "canette": "metal",
    "journal": "papier",
    "nourriture": "nourriture",
    "bocal": "verre",
    "sac_plastique": "plastique",
    "piles": "dechets_dangereux",
    "carton": "papier",
    "charbon": "dechets_dangereux",
    "sac_tissu": "plastique",
    "ampoule": "dechets_dangereux",
  };

  final Map<String, String> itemImages = {
    "bouteille": "assets/images/bouteille.png",
    "canette": "assets/images/canette.png",
    "journal": "assets/images/journal.png",
    "nourriture": "assets/images/nourriture.png",
    "bocal": "assets/images/bocal.png",
    "sac_plastique": "assets/images/sac_plastique.png",
    "piles": "assets/images/piles.png",
    "carton": "assets/images/carton.png",
    "charbon": "assets/images/charbon.png",
    "sac_tissu": "assets/images/sac_tissu.png",
    "ampoule": "assets/images/ampoule.png",
  };

  final Map<String, String> binImages = {
    "plastique": "assets/images/poubelle_jaune.png",
    "metal": "assets/images/poubelle_rouge.png",
    "papier": "assets/images/poubelle_bleue.png",
    "verre": "assets/images/poubelle_verte.png",
    "nourriture": "assets/images/poubelle_marron.png",
    "dechets_dangereux": "assets/images/dechets_toxiques.png",
  };

  final List<String> binOrder = [
    "plastique",
    "metal",
    "papier",
    "verre",
    "nourriture",
    "dechets_dangereux",
  ];

  @override
  void initState() {
    super.initState();
    _prepareItems();
    _startNewGame();
  }

  void _prepareItems() {
    itemsOrder.clear();
    for (final key in itemImages.keys) {
      if (correctBins.containsKey(key)) {
        itemsOrder.add(key);
      }
    }
  }

  void _startNewGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      isGameOver = false;
      showFeedback = false;
      feedbackColor = Colors.white;
      itemsOrder.shuffle();
      currentItem = itemsOrder.first;
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      setState(() {
        if (timeLeft > 0) timeLeft--;

        if (timeLeft <= 0) {
          timeLeft = 0;
          isGameOver = true;
          timer?.cancel();
          return;
        }
      });
    });
  }

  void _onSelectBin(String selectedBin) {
    if (isGameOver || timeLeft <= 0) return;

    final bool isCorrect = (correctBins[currentItem] == selectedBin);

    setState(() {
      showFeedback = true;
      feedbackColor = isCorrect ? Colors.green : Colors.red;
      if (isCorrect) score++;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || isGameOver || timeLeft <= 0) return;

      setState(() {
        showFeedback = false;
        itemsOrder.shuffle();
        currentItem = itemsOrder.first;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Score : $score",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.timer, color: Color(0xFF1B5E20)),
              const SizedBox(width: 6),
              Text(
                "$timeLeft s",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: timeLeft <= 5 ? Colors.red : const Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemDisplay(double size) {
    final imgPath = itemImages[currentItem];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        showFeedback ? feedbackColor.withOpacity(0.25) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black26, offset: Offset(2, 4)),
        ],
      ),
      child: imgPath != null
          ? Image.asset(imgPath, fit: BoxFit.contain)
          : Center(child: Text(currentItem.toUpperCase())),
    );
  }

  Widget _buildBinButton(String binName) {
    final disabled = isGameOver || timeLeft <= 0;

    return Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: disabled ? null : () => _onSelectBin(binName),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(blurRadius: 6, color: Colors.black26, offset: Offset(2, 3))
            ],
          ),
          child: Row(
            children: [
              if (binImages[binName] != null)
                Image.asset(binImages[binName]!, width: 44, height: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _prettyBinName(binName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _prettyBinName(String key) {
    switch (key) {
      case "plastique":
        return "PLASTIQUE";
      case "metal":
        return "MÉTAL";
      case "papier":
        return "PAPIER";
      case "verre":
        return "VERRE";
      case "nourriture":
        return "NOURRITURE";
      case "dechets_dangereux":
        return "DANGEREUX";
      default:
        return key.toUpperCase();
    }
  }

  Widget _buildEndGameOverlay(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isGameOver ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !isGameOver,
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "PERDU !",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Le temps est écoulé...",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Score final : $score",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _startNewGame,
                          icon: const Icon(Icons.replay),
                          label: const Text("Rejouer"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Quitter"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double imageSize = MediaQuery.of(context).size.width * 0.6;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: const Text(
          "Tri Express",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 8),
                _buildTopBar(),
                const SizedBox(height: 8),

                Expanded(
                  child: Center(
                    child: _buildItemDisplay(imageSize),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3.6,
                        physics: const NeverScrollableScrollPhysics(),
                        children: binOrder
                            .map((b) => _buildBinButton(b))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Objet : ${currentItem.toUpperCase()}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),

            if (isGameOver) _buildEndGameOverlay(context),
          ],
        ),
      ),
    );
  }
}
