import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/favorite_locations.dart';
import '../models/favorite_location.dart';
import '../widgets/favorite_details_sheet.dart';
import '../widgets/favorites_list_sheet.dart';

/// Main screen of the app.
///
/// Shows a Google Map with the predefined favourite markers and provides two
/// actions:
/// * **My Location** – asks for permission, reads the real GPS position with
///   geolocator and moves the camera to the user.
/// * **Favorite Locations** – opens the list of favourites and moves the
///   camera to the selected one.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// Camera position used before the user's real position is known.
  /// (Khulna city centre – only a starting view of the map. Zoomed out far
  /// enough to include every favourite marker, e.g. Khulna University.)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(22.8095, 89.4700),
    zoom: 11,
  );

  /// Zoom level used when the camera jumps to a single place.
  static const double _focusedZoom = 16;

  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLocating = false;

  /// Whether the blue "you are here" dot should be drawn by the map.
  /// Only enabled after location permission has been granted.
  bool _showUserLocation = false;

  @override
  void initState() {
    super.initState();
    _createFavoriteMarkers();
    // If permission was already granted earlier, centre the map on the user
    // without bothering them with a prompt.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _centreOnUserIfPermissionGranted(),
    );
  }

  // ---------------------------------------------------------------------------
  // Markers
  // ---------------------------------------------------------------------------

  void _createFavoriteMarkers() {
    for (final FavoriteLocation location in favoriteLocations) {
      final MarkerId markerId = MarkerId('favorite_${location.id}');

      _markers[markerId] = Marker(
        markerId: markerId,
        position: location.position,
        infoWindow: InfoWindow(
          title: location.name,
          snippet: 'ID: ${location.id}',
        ),
        onTap: () => _showFavoriteDetails(location),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Map callbacks
  // ---------------------------------------------------------------------------

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _moveCameraTo(LatLng target, double zoom) async {
    final GoogleMapController? controller = _mapController;
    if (controller == null) {
      return;
    }
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(target, zoom),
    );
  }

  // ---------------------------------------------------------------------------
  // Favourite locations
  // ---------------------------------------------------------------------------

  void _showFavoriteDetails(FavoriteLocation location) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) =>
          FavoriteDetailsSheet(location: location),
    );
  }

  Future<void> _openFavoritesList() async {
    final FavoriteLocation? selected =
        await showModalBottomSheet<FavoriteLocation>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => const FavoritesListSheet(),
    );

    if (!mounted || selected == null) {
      return;
    }

    await _moveCameraTo(selected.position, _focusedZoom);

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Moved to ${selected.name}')),
      );
  }

  // ---------------------------------------------------------------------------
  // Current location
  // ---------------------------------------------------------------------------

  /// Called once when the screen opens. Never prompts: it only centres the map
  /// when the user has already allowed location access.
  Future<void> _centreOnUserIfPermissionGranted() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return;
      }

      final LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final Position? position = await _readPosition(showErrors: false);
      if (position == null || !mounted) {
        return;
      }
      _applyCurrentPosition(position);
    } on Exception {
      // Silently ignore: the user can always press "My Location".
    }
  }

  /// Handler for the "My Location" button.
  ///
  /// Get current location → get latitude & longitude → move the camera →
  /// show the user's location.
  Future<void> _goToMyLocation() async {
    if (_isLocating) {
      return;
    }

    setState(() => _isLocating = true);

    try {
      final Position? position = await _readPosition();
      if (position == null || !mounted) {
        return;
      }

      _applyCurrentPosition(position);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Current location: ${position.latitude.toStringAsFixed(5)}, '
              '${position.longitude.toStringAsFixed(5)}',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  /// Checks permissions, then reads the device position with geolocator.
  ///
  /// Returns `null` when the position cannot be read (service off, permission
  /// denied, timeout…), in which case the reason is explained to the user.
  Future<Position?> _readPosition({bool showErrors = true}) async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (showErrors) {
        await _showMessageDialog(
          title: 'Location services are off',
          message: 'Turn on GPS / location services on your device, '
              'then press "My Location" again.',
        );
      }
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (showErrors) {
        await _showMessageDialog(
          title: 'Permission denied',
          message: 'Location permission is needed to show your current '
              'position on the map.',
        );
      }
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      if (showErrors) {
        await _showMessageDialog(
          title: 'Permission permanently denied',
          message: 'Location permission was permanently denied. Allow it in '
              'the app settings to use "My Location".',
          openSettings: true,
        );
      }
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      final Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }
      if (showErrors) {
        await _showMessageDialog(
          title: 'Could not get location',
          message: 'Reading the GPS position timed out. Move to an open area '
              'and try again.',
        );
      }
      return null;
    } on LocationServiceDisabledException {
      if (showErrors) {
        await _showMessageDialog(
          title: 'Location services are off',
          message: 'Turn on GPS / location services and try again.',
        );
      }
      return null;
    } on PermissionDeniedException {
      if (showErrors) {
        await _showMessageDialog(
          title: 'Permission denied',
          message: 'Location permission was denied.',
        );
      }
      return null;
    }
  }

  /// Stores the position, reveals the blue location dot and moves the camera.
  void _applyCurrentPosition(Position position) {
    if (!mounted) {
      return;
    }

    setState(() {
      _currentPosition = position;
      _showUserLocation = true;
    });

    _moveCameraTo(
      LatLng(position.latitude, position.longitude),
      _focusedZoom,
    );
  }

  Future<void> _showMessageDialog({
    required String title,
    required String message,
    bool openSettings = false,
  }) {
    if (!mounted) {
      return Future<void>.value();
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          if (openSettings)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Geolocator.openAppSettings();
              },
              child: const Text('Open settings'),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps & Location'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: _onMapCreated,
            markers: _markers.values.toSet(),
            // Google Maps zoom buttons (Android).
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: false,
            // Built-in blue "you are here" dot, enabled after permission.
            myLocationEnabled: _showUserLocation,
            // Replaced by our own "My Location" button.
            myLocationButtonEnabled: false,
            // Keep the markers clear of the buttons at the bottom.
            padding: const EdgeInsets.only(bottom: 120),
          ),
          // Small card that shows the coordinates read from the device.
          if (_currentPosition != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.my_location,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Your location\n'
                            '${_currentPosition!.latitude.toStringAsFixed(5)}, '
                            '${_currentPosition!.longitude.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FloatingActionButton.extended(
                      heroTag: 'my_location_button',
                      onPressed: _isLocating ? null : _goToMyLocation,
                      icon: _isLocating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(_isLocating ? 'Locating…' : 'My Location'),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton.extended(
                      heroTag: 'favorites_button',
                      onPressed: _openFavoritesList,
                      icon: const Icon(Icons.star),
                      label: const Text('Favorite Locations'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
