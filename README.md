# Google Maps & Location – Flutter Assignment

A Flutter app that shows a Google Map with favourite location markers and
reads the user's real position from the device with `geolocator`.

## Features

| # | Requirement | Where |
|---|-------------|-------|
| 1 | Google Map with zoom controls and 4 favourite markers | `lib/screens/map_screen.dart` |
| 2 | "My Location" → reads real GPS position → moves camera → shows the blue dot | `_goToMyLocation()` in `lib/screens/map_screen.dart` |
| 3 | Proper location permission handling (service off, denied, denied forever, timeout) | `_readPosition()` |
| 4 | Tap a favourite marker → bottom sheet with ID, Name, Latitude, Longitude | `lib/widgets/favorite_details_sheet.dart` |
| 5 | "Favorite Locations" button → list → tap an item to move the map there | `lib/widgets/favorites_list_sheet.dart` |
| 6 | Model class with `id`, `name`, `latitude`, `longitude` | `lib/models/favorite_location.dart` |

The current location is **never hard-coded** – it always comes from
`Geolocator.getCurrentPosition()`.

## Favourite locations

Defined once in `lib/data/favorite_locations.dart`:

| ID | Name | Latitude | Longitude |
|----|------|----------|-----------|
| 1 | Khulna University | 22.8026 | 89.3709 |
| 2 | Khulna Railway Station | 22.8103 | 89.5651 |
| 3 | Shibbari More | 22.8156 | 89.5630 |
| 4 | Khulna New Market | 22.8081 | 89.5672 |

Add more entries to that list and the markers + list update automatically.

## Project structure

```
lib/
├── main.dart                        # app entry point
├── models/favorite_location.dart    # the model class (id, name, lat, lng)
├── data/favorite_locations.dart     # the predefined favourites
├── screens/map_screen.dart          # map, markers, My Location, buttons
└── widgets/
    ├── favorite_details_sheet.dart  # marker tap → details bottom sheet
    └── favorites_list_sheet.dart    # favourite list bottom sheet
```

---

## Setup – Google Maps API key

The key is already set in `android/app/src/main/AndroidManifest.xml`, so the app
runs as-is. To use your own key instead, follow the steps below. Without a valid
key the app still compiles but the map area stays blank/black.

### 1. Create an API key

1. Open <https://console.cloud.google.com/> → create (or pick) a project.
2. **APIs & Services → Library** → enable **Maps SDK for Android**.
   (On a Mac, also enable **Maps SDK for iOS**.)
3. **APIs & Services → Credentials → Create credentials → API key**.
4. Copy the key. Restrict it to your app for safety (optional but recommended).

### 2. Android

The key lives in `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_ANDROID_API_KEY"/>
```

Replace the value with your real key. Permissions for location are already
added in the same file.

If the map stays black while the log shows
`Authorization failure` / `Error requesting API token`, the key is fine but
**Maps SDK for Android is not enabled in the project that owns the key** – the
API key and the enabled API must be in the same Google Cloud project.

### 3. iOS (only if you run on an iPhone / iOS simulator)

`ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_IOS_API_KEY")
```

The location usage description is already in `ios/Runner/Info.plist`.

### 4. Run

```bash
flutter pub get
flutter run
```

Use a **real Android device or the Android emulator with a location set**
(emulator: ⋮ → Location → set a position). A GPS position cannot be read in
a desktop/Chrome build, this project is configured for Android and iOS.

## How to use the app

1. The map opens showing the 4 favourite markers (red pins).
2. Press **My Location** → allow permission → the camera flies to your real
   position and the blue "you are here" dot appears. Your coordinates are
   shown in the card at the top.
3. Tap any marker → a bottom sheet shows **ID, Name, Latitude, Longitude**.
4. Press **Favorite Locations** → tap a place → the camera moves to it.

---

## Screenshots

Taken on an Android emulator and stored in `screenshots/`:

| File | Shows |
|------|-------|
| `screenshots/01-map.png` | Google Map at launch with all 4 favourite markers and the zoom controls |
| `screenshots/02-favorites-list.png` | "Favorite Locations" list with ⭐ and coordinates |
| `screenshots/03-marker-details.png` | Marker tap → bottom sheet: ID 1, Khulna University, 22.8026, 89.3709 |
| `screenshots/04-current-location.png` | After "My Location": camera on the device position, blue dot, live coordinates |

To take your own on an emulator, set a position first: Android Studio →
**Extended Controls → Location**, or
`adb emu geo fix <longitude> <latitude>` (e.g. `adb emu geo fix 89.5640 22.8095`).
Then press **My Location**, allow the permission dialog, and wait for the camera
move.

## Push to GitHub

```bash
git init
git add .
git commit -m "Flutter assignment: Google Maps with locations"
git branch -M main
git remote add origin https://github.com/<your-username>/<repo-name>.git
git push -u origin main
```

`build/`, `.dart_tool/` and IDE folders are already excluded by `.gitignore`.

> **Note about the API key in git:** the key lives in `AndroidManifest.xml`, so
> it will be committed. That is normal for a student project, but restrict the
> key to your package name + SHA-1 in Google Cloud so nobody else can abuse it.
> Never commit billing-enabled unrestricted keys.
