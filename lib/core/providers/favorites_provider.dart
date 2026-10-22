import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gère les prestataires favoris du client.
///
/// Les IDs (techniciens / prestataires) sont persistés localement dans
/// SharedPreferences. Il n'existe pas encore d'endpoint backend
/// `/favorites` : quand il sera disponible, remplacer [_persist] par un
/// appel `ApiService.post('/favorites', ...)` / `delete` et [load] par un
/// `ApiService.get('/favorites')`.
class FavoritesProvider with ChangeNotifier {
  static const String _storageKey = 'favorite_provider_ids';

  Set<String> _favoriteIds = {};
  bool _loaded = false;

  Set<String> get favoriteIds => _favoriteIds;
  int get count => _favoriteIds.length;

  bool isFavorite(dynamic id) => _favoriteIds.contains(id.toString());

  /// Charge les favoris depuis le stockage local (idempotent).
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds =
        (prefs.getStringList(_storageKey) ?? const <String>[]).toSet();
    _loaded = true;
    notifyListeners();
  }

  /// Ajoute ou retire un favori puis persiste localement.
  Future<void> toggle(dynamic id) async {
    await load();
    final key = id.toString();
    if (_favoriteIds.contains(key)) {
      _favoriteIds.remove(key);
    } else {
      _favoriteIds.add(key);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _favoriteIds.toList());
  }
}
