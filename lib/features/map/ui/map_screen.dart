import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../mock_location/provider/mock_location_provider.dart';
import '../provider/search_provider.dart';
import '../provider/favorites_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _moveToCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    final point = LatLng(position.latitude, position.longitude);
    
    _mapController.move(point, 15.0);
    ref.read(selectedLocationProvider.notifier).state = point;
  }

  void _showAddFavoriteDialog(BuildContext context, LatLng location) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Favorites'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Enter name (e.g. Home)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref.read(favoritesProvider.notifier).addFavorite(nameController.text, location);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocation = ref.watch(selectedLocationProvider);
    final isMocking = ref.watch(isMockingActiveProvider);
    final mockNotifier = ref.read(isMockingActiveProvider.notifier);
    final searchResults = ref.watch(searchResultsProvider);
    final favorites = ref.watch(favoritesProvider);
    final history = ref.watch(historyProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-6.2000, 106.8166), // Jakarta
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                if (!isMocking) {
                  ref.read(selectedLocationProvider.notifier).state = point;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.geomock',
              ),
              if (selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation,
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.location_on,
                        color: isMocking ? Colors.green : Colors.red,
                        size: 45,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          // Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {
                        _isSearchFocused = hasFocus;
                      });
                    },
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                        suffixIcon: _searchController.text.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state = "";
                              },
                            )
                          : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ),
                
                // Search Results / History / Favorites Dropdown
                if (_isSearchFocused && (searchResults.hasValue || searchQuery.isEmpty))
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    constraints: const BoxConstraints(maxHeight: 350),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (searchQuery.isEmpty) ...[
                            if (favorites.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                              ),
                              ...favorites.map((fav) => ListTile(
                                leading: const Icon(Icons.star, color: Colors.amber),
                                title: Text(fav.name),
                                subtitle: Text('${fav.latitude.toStringAsFixed(4)}, ${fav.longitude.toStringAsFixed(4)}'),
                                onTap: () {
                                  _mapController.move(fav.location, 15.0);
                                  ref.read(selectedLocationProvider.notifier).state = fav.location;
                                  FocusScope.of(context).unfocus();
                                },
                              )),
                            ],
                            if (history.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text('Recent', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              ),
                              ...history.map((h) => ListTile(
                                leading: const Icon(Icons.history),
                                title: Text(h.name),
                                subtitle: Text('${h.latitude.toStringAsFixed(4)}, ${h.longitude.toStringAsFixed(4)}'),
                                onTap: () {
                                  _mapController.move(h.location, 15.0);
                                  ref.read(selectedLocationProvider.notifier).state = h.location;
                                  FocusScope.of(context).unfocus();
                                },
                              )),
                            ],
                          ] else if (searchResults.hasValue && searchResults.value!.isNotEmpty)
                            ...searchResults.value!.map((result) => ListTile(
                              leading: const Icon(Icons.location_on_outlined),
                              title: Text(result.displayName, maxLines: 2, overflow: TextOverflow.ellipsis),
                              onTap: () {
                                _mapController.move(result.location, 15.0);
                                ref.read(selectedLocationProvider.notifier).state = result.location;
                                ref.read(historyProvider.notifier).addToHistory(result.displayName.split(',').first, result.location);
                                ref.read(searchQueryProvider.notifier).state = "";
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                              },
                            )),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // My Location Button
          Positioned(
            right: 15,
            bottom: selectedLocation != null ? 220 : 100,
            child: FloatingActionButton(
              onPressed: _moveToCurrentLocation,
              backgroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.my_location, color: Colors.blueAccent),
            ),
          ),

          // Control Panel
          if (selectedLocation != null)
            Positioned(
              bottom: 20,
              left: 15,
              right: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 5,
                      width: 40,
                      margin: const EdgeInsets.only(top: 10, bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.pin_drop, color: Colors.blueAccent),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Target Coordinate',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      '${selectedLocation.latitude.toStringAsFixed(6)}, ${selectedLocation.longitude.toStringAsFixed(6)}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  favorites.any((f) => (f.latitude - selectedLocation.latitude).abs() < 0.0001 && (f.longitude - selectedLocation.longitude).abs() < 0.0001)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  final isFav = favorites.any((f) => (f.latitude - selectedLocation.latitude).abs() < 0.0001 && (f.longitude - selectedLocation.longitude).abs() < 0.0001);
                                  if (isFav) {
                                    final favId = favorites.firstWhere((f) => (f.latitude - selectedLocation.latitude).abs() < 0.0001 && (f.longitude - selectedLocation.longitude).abs() < 0.0001).id;
                                    ref.read(favoritesProvider.notifier).removeFavorite(favId);
                                  } else {
                                    _showAddFavoriteDialog(context, selectedLocation);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                    text: '${selectedLocation.latitude}, ${selectedLocation.longitude}'
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Coordinates copied to clipboard')),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (isMocking) {
                                  await mockNotifier.stopMocking();
                                } else {
                                  final isEnabled = await mockNotifier.checkPermission();
                                  if (!isEnabled && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Enable GeoMock Pro in Mock Location settings'),
                                      ),
                                    );
                                  }
                                  await mockNotifier.startMocking();
                                  ref.read(historyProvider.notifier).addToHistory(
                                    'Mocked Location', 
                                    selectedLocation
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isMocking ? Colors.redAccent : Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                isMocking ? 'STOP MOCKING' : 'START MOCKING',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
