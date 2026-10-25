import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A favourite place that is drawn as a marker on the map.
///
/// Every favourite location is described by four values:
/// * [id]        – unique number of the location
/// * [name]      – human readable name shown on the map and in the list
/// * [latitude]  – GPS latitude of the place
/// * [longitude] – GPS longitude of the place
class FavoriteLocation {
  const FavoriteLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;

  /// Converts the model into the coordinate type the map widget expects.
  LatLng get position => LatLng(latitude, longitude);

  String get formattedLatitude => latitude.toStringAsFixed(4);

  String get formattedLongitude => longitude.toStringAsFixed(4);
}
