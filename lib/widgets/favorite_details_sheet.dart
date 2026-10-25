import 'package:flutter/material.dart';

import '../models/favorite_location.dart';

/// Bottom sheet that shows the full details of a favourite location.
///
/// Opened when the user taps one of the favourite markers on the map.
class FavoriteDetailsSheet extends StatelessWidget {
  const FavoriteDetailsSheet({super.key, required this.location});

  final FavoriteLocation location;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.star, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Favorite Location',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'ID', value: '${location.id}'),
            _DetailRow(label: 'Name', value: location.name),
            _DetailRow(label: 'Latitude', value: location.formattedLatitude),
            _DetailRow(label: 'Longitude', value: location.formattedLongitude),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
