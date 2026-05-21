import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class SearchResult {
  final String displayName;
  final LatLng location;

  SearchResult({required this.displayName, required this.location});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      displayName: json['display_name'],
      location: LatLng(
        double.parse(json['lat']),
        double.parse(json['lon']),
      ),
    );
  }
}

final searchQueryProvider = StateProvider<String>((ref) => "");

final searchResultsProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty || query.length < 3) return [];

  final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5');
  
  try {
    final response = await http.get(url, headers: {
      'User-Agent': 'GeoMockPro/1.0',
    });

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => SearchResult.fromJson(item)).toList();
    }
  } catch (e) {
    // Silent fail for MVP
  }
  return [];
});
