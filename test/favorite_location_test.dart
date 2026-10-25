import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_location_app/data/favorite_locations.dart';
import 'package:google_maps_location_app/models/favorite_location.dart';

void main() {
  group('favoriteLocations', () {
    test('contains at least three locations', () {
      expect(favoriteLocations.length, greaterThanOrEqualTo(3));
    });

    test('every location has a unique id and a name', () {
      final Set<int> ids = <int>{};

      for (final FavoriteLocation location in favoriteLocations) {
        expect(location.name, isNotEmpty);
        expect(ids.add(location.id), isTrue,
            reason: 'duplicate id ${location.id}');
      }
    });

    test('every location has valid coordinates', () {
      for (final FavoriteLocation location in favoriteLocations) {
        expect(location.latitude, inInclusiveRange(-90, 90));
        expect(location.longitude, inInclusiveRange(-180, 180));
      }
    });
  });

  group('FavoriteLocation', () {
    const FavoriteLocation location = FavoriteLocation(
      id: 1,
      name: 'Khulna University',
      latitude: 22.8026,
      longitude: 89.3709,
    );

    test('position returns a matching LatLng', () {
      expect(location.position, const LatLng(22.8026, 89.3709));
    });

    test('formats coordinates with four decimals', () {
      expect(location.formattedLatitude, '22.8026');
      expect(location.formattedLongitude, '89.3709');
    });
  });
}
