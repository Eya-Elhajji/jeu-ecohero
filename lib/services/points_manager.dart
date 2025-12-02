import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PointsManager : singleton pour gérer les points et niveaux persistés.
///
/// Exemple d'utilisation :
/// await PointsManager.instance.init();
/// PointsManager.instance.addPoints(10);
/// PointsManager.instance.pointsNotifier.addListener(() {
///   print("Points: ${PointsManager.instance.points}");
/// });
class PointsManager {
  static const String _kPrefsKey = 'ecohero_points';
  static PointsManager? _instance;

  /// Seuils de niveaux : index 0 -> niveau 1 (0..thresholds[0]-1), etc.
  /// Tu peux ajuster ces seuils pour équilibrer la progression.
  final List<int> levelThresholds;

  SharedPreferences? _prefs;
  int _points = 0;

  /// Notifier pour mettre à jour l'UI quand les points changent.
  final ValueNotifier<int> pointsNotifier = ValueNotifier<int>(0);

  PointsManager._(this.levelThresholds);

  /// Instance singleton (configurable thresholds si première création)
  static PointsManager get instance {
    _instance ??= PointsManager._(
      // Par défaut : Niveau 1:0, Niveau 2:50, Niveau 3:120, Niveau 4:220, Niveau 5:360
      [50, 120, 220, 360, 520],
    );
    return _instance!;
  }

  /// Appeler au démarrage de l'app (ex: main) pour initialiser SharedPreferences.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _points = _prefs!.getInt(_kPrefsKey) ?? 0;
    pointsNotifier.value = _points;
  }

  /// Valeur actuelle des points (disponible après init)
  int get points => _points;

  /// Calcul du niveau basé sur levelThresholds.
  /// Le niveau commence à 1.
  int getLevel() {
    for (int i = 0; i < levelThresholds.length; i++) {
      if (_points < levelThresholds[i]) {
        return i + 1;
      }
    }
    // Si au-dessus de tous les seuils -> niveau suivant
    return levelThresholds.length + 1;
  }

  /// Retourne la progression dans le niveau courant (0.0 - 1.0)
  double getProgressInLevel() {
    int level = getLevel();

    if (level == 1) {
      final int upper = levelThresholds[0];
      return _points / upper;
    } else if (level - 2 < levelThresholds.length) {
      final int lower = levelThresholds[level - 2];
      final int upper = (level - 1 < levelThresholds.length)
          ? levelThresholds[level - 1]
          : levelThresholds.last;

      final int range = (upper - lower).clamp(1, upper);
      return (_points - lower) / range;
    } else {
      // Au-delà du dernier niveau
      return 1.0;
    }
  }

  /// Ajoute des points (positif ou négatif), sauvegarde et notifie.
  Future<void> addPoints(int amount) async {
    _points += amount;
    if (_points < 0) _points = 0;

    await _save();
    pointsNotifier.value = _points;
  }

  /// Définit directement les points.
  Future<void> setPoints(int newPoints) async {
    _points = newPoints.clamp(0, 9999999);
    await _save();
    pointsNotifier.value = _points;
  }

  /// Réinitialise les points à zéro.
  Future<void> reset() async {
    _points = 0;
    await _save();
    pointsNotifier.value = _points;
  }

  Future<void> _save() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(_kPrefsKey, _points);
  }

  /// Pour libérer le notifier (rarement nécessaire)
  void dispose() {
    pointsNotifier.dispose();
  }
}
