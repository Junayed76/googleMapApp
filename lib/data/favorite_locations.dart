import '../models/favorite_location.dart';

/// The predefined favourite locations shown on the map.
///
/// Add, remove or edit entries here – the map markers and the favourite list
/// are both generated from this single list.
const List<FavoriteLocation> favoriteLocations = <FavoriteLocation>[
  FavoriteLocation(
    id: 1,
    name: 'Khulna University',
    latitude: 22.8026,
    longitude: 89.3709,
  ),
  FavoriteLocation(
    id: 2,
    name: 'Khulna Railway Station',
    latitude: 22.8103,
    longitude: 89.5651,
  ),
  FavoriteLocation(
    id: 3,
    name: 'Shibbari More',
    latitude: 22.8156,
    longitude: 89.5630,
  ),
  FavoriteLocation(
    id: 4,
    name: 'Khulna New Market',
    latitude: 22.8081,
    longitude: 89.5672,
  ),
];
