import 'package:flutter/material.dart';

import '../data/favorite_locations.dart';
import '../models/favorite_location.dart';

/// Bottom sheet that lists every favourite location.
///
/// Pops the selected [FavoriteLocation] so the map screen can move the camera
/// to it, or `null` when the sheet is dismissed.
class FavoritesListSheet extends StatelessWidget {
  const FavoritesListSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Row(
              children: <Widget>[
                const Icon(Icons.place, color: Colors.redAccent, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Favorite Locations',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: favoriteLocations.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final FavoriteLocation location = favoriteLocations[index];

                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(location.name),
                  subtitle: Text(
                    'ID: ${location.id} • '
                    '${location.formattedLatitude}, ${location.formattedLongitude}',
                  ),
                  trailing: const Icon(Icons.center_focus_strong, size: 20),
                  onTap: () => Navigator.of(context).pop(location),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
