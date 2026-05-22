import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../provider/favorites_provider.dart';
import '../../mock_location/provider/mock_location_provider.dart';
import '../../home/ui/main_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final history = ref.watch(historyProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved Locations'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.star), text: 'Favorites'),
              Tab(icon: Icon(Icons.history), text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LocationList(
              items: favorites,
              onDelete: (id) => ref.read(favoritesProvider.notifier).removeFavorite(id),
              onSelect: (location) {
                ref.read(selectedLocationProvider.notifier).state = location;
                ref.read(navigationIndexProvider.notifier).state = 0;
              },
              emptyMessage: 'No favorite locations yet.',
            ),
            _LocationList(
              items: history,
              onSelect: (location) {
                ref.read(selectedLocationProvider.notifier).state = location;
                ref.read(navigationIndexProvider.notifier).state = 0;
              },
              emptyMessage: 'No recent history.',
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationList extends StatelessWidget {
  final List<FavoriteLocation> items;
  final Function(String)? onDelete;
  final Function(LatLng) onSelect;
  final String emptyMessage;

  const _LocationList({
    required this.items,
    this.onDelete,
    required this.onSelect,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Icon(
            onDelete != null ? Icons.star : Icons.history,
            color: onDelete != null ? Colors.amber : Colors.grey,
          ),
          title: Text(item.name),
          subtitle: Text(
            '${item.latitude.toStringAsFixed(6)}, ${item.longitude.toStringAsFixed(6)}',
          ),
          trailing: onDelete != null
              ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => onDelete!(item.id),
                )
              : const Icon(Icons.chevron_right),
          onTap: () => onSelect(item.location),
        );
      },
    );
  }
}
