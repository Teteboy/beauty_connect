import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

/// Gère les prestataires favoris du client.
///
/// Les IDs sont synchronisés avec `GET /favorites/ids` et
/// `POST /favorites/:id` (bascule). Un cache SharedPreferences sert de
/// repli hors-ligne ou si l'API échoue.
class FavoritesProvider with ChangeNotifier {
  static const String _storageKey = 'favorite_provider_ids';

  Set<String> _favoriteIds = {};
  bool _loaded = false;

  Set<String> get favoriteIds => _favoriteIds;
  int get count => _favoriteIds.length;

  bool isFavorite(dynamic id) => _favoriteIds.contains(id.toString());

  /// Charge les favoris (backend puis repli local).
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds =
        (prefs.getStringList(_storageKey) ?? const <String>[]).toSet();
    _loaded = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/favorites/ids');
      final ids = (response['ids'] as List? ?? [])
          .map((e) => e.toString())
          .toSet();
      _favoriteIds = ids;
      await _persist();
      notifyListeners();
    } catch (_) {
      // Repli sur le cache local si l'API est injoignable.
    }
  }

  /// Réinitialise le chargement (à appeler après connexion).
  void reset() => _loaded = false;

  /// Ajoute ou retire un favori (optimiste + synchro backend).
  Future<void> toggle(dynamic id) async {
    await load();
    final key = id.toString();
    final wasFavorite = _favoriteIds.contains(key);
    if (wasFavorite) {
      _favoriteIds.remove(key);
    } else {
      _favoriteIds.add(key);
    }
    notifyListeners();
    await _persist();
    try {
      final response = await ApiService.post('/favorites/$key', {});
      final favorited = response['favorited'] == true;
      if (favorited != !wasFavorite) {
        if (favorited) {
          _favoriteIds.add(key);
        } else {
          _favoriteIds.remove(key);
        }
        notifyListeners();
        await _persist();
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _favoriteIds.toList());
  }
}
