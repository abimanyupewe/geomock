import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

class FavoriteLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  FavoriteLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
      };

  factory FavoriteLocation.fromJson(Map<String, dynamic> json) => FavoriteLocation(
        id: json['id'],
        name: json['name'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        timestamp: DateTime.parse(json['timestamp']),
      );
      
  LatLng get location => LatLng(latitude, longitude);
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<FavoriteLocation>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<FavoriteLocation>> {
  FavoritesNotifier() : super([]) {
    loadFavorites();
  }

  static const _key = 'favorites_locations';

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    state = data
        .map((e) => FavoriteLocation.fromJson(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addFavorite(String name, LatLng location) async {
    final newItem = FavoriteLocation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      latitude: location.latitude,
      longitude: location.longitude,
      timestamp: DateTime.now(),
    );

    state = [newItem, ...state];
    await _save();
  }

  Future<void> removeFavorite(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, data);
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<FavoriteLocation>>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<List<FavoriteLocation>> {
  HistoryNotifier() : super([]) {
    loadHistory();
  }

  static const _key = 'history_locations';
  static const _maxItems = 10;

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    state = data
        .map((e) => FavoriteLocation.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> addToHistory(String name, LatLng location) async {
    final newItem = FavoriteLocation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      latitude: location.latitude,
      longitude: location.longitude,
      timestamp: DateTime.now(),
    );

    // Remove duplicates of same lat/lng (roughly)
    final filtered = state.where((item) => 
      (item.latitude - location.latitude).abs() > 0.0001 || 
      (item.longitude - location.longitude).abs() > 0.0001
    ).toList();

    state = [newItem, ...filtered].take(_maxItems).toList();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, data);
  }
}
