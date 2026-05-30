# GI-Jios & JioLeh!

GI-Jios is the team behind **JioLeh!**, an Orbital 26 project that explores a
more personal way to discover places with friends.

Instead of treating maps as anonymous search results, JioLeh! aims to turn the
real places people visit into a shared social map. Users can pin meaningful
locations, revisit their own discoveries, and eventually share reviews, photos,
comments, and recommendations with trusted friends.

This README is based on the GI-Jios Proposal for Orbital 26 and the current
Flutter implementation in this repository.

## Current App

The app currently includes:

- A Mapbox-powered map interface.
- Current location detection and live location updates.
- Reverse geocoding to show the user's current area.
- Google sign-in through Supabase Auth.
- An auth gate that routes users between sign-in, onboarding, and the map.
- First-time onboarding to set up a user profile (username, display name,
  birthday).
- A profile page showing the signed-in user's details.
- Persistent pinned locations and user profiles stored in Supabase.
- A simple map toolbar for recentering and adding pins.

## Product Direction

The aims of our project includes but are not limited to:

- Sharing real-world recommendations such as restaurants, entertainment venues,
  hotels, toilets, and memorable places.
- Letting friends view trusted ratings, reviews, photos, and comments.
- Supporting private friend-based discovery instead of public-only reviews.
- Making exploration more engaging through points, leaderboards, map
  progression, virtual buildings, and other game-like features.
- Helping users plan outings through shared friend recommendations and future
  OpenJio-style gathering flows.

## Roadmap

Planned features from the proposal include:

- Location categories and custom emoji pins.
- User-renamed pinned places.
- Ratings, reviews, comments, and photos.
- Friend invitations and private sharing.
- Place-specific discussion or chat.
- Social points and friend leaderboards.
- Fog-of-map exploration.
- Group chats, gatherings, and group location filters.
- Profile search and close-friends filtering.
- AI-assisted content classification and recommendation ideas.

## Tech Stack

| Area | Technology |
|---|---|
| App | Flutter, Dart |
| Maps | Mapbox Maps SDK for Flutter |
| Location | Geolocator |
| Backend | Supabase |
| Auth | Supabase Auth with Google OAuth |
| Database | Supabase PostgreSQL |
| HTTP | Dart `http` package |
| CI/CD | GitHub Actions |

## Getting Started

Install Flutter, then fetch dependencies:

```bash
flutter doctor
flutter pub get
```

The required Dart SDK version is declared in `pubspec.yaml`:

```yaml
environment:
  sdk: ^3.11.5
```

## Environment Values

The app requires these `--dart-define` values:

| Key | Purpose |
|---|---|
| `MAPBOX_ACCESS_TOKEN` | Mapbox SDK and reverse geocoding |
| `MAPBOX_STYLE_URI` | Mapbox map style |
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase client anon key |

Run the app:

```bash
flutter run \
  --dart-define=MAPBOX_ACCESS_TOKEN="your-mapbox-token" \
  --dart-define=MAPBOX_STYLE_URI="your-mapbox-style-uri" \
  --dart-define=SUPABASE_URL="your-supabase-url" \
  --dart-define=SUPABASE_ANON_KEY="your-supabase-anon-key"
```

PowerShell:

```powershell
flutter run `
  --dart-define=MAPBOX_ACCESS_TOKEN="your-mapbox-token" `
  --dart-define=MAPBOX_STYLE_URI="your-mapbox-style-uri" `
  --dart-define=SUPABASE_URL="your-supabase-url" `
  --dart-define=SUPABASE_ANON_KEY="your-supabase-anon-key"
```

Do not commit real secrets.

## Development

Run local checks before opening a pull request:

```bash
flutter analyze
flutter test
```

For platform build checks:

```bash
flutter build apk --debug
flutter build ios --debug --no-codesign
```

Build commands may also need the same `--dart-define` values used by
`flutter run`.

## Store Deployment

Release builds and store uploads are driven by GitHub Actions and triggered by a
version tag matching `v*.*.*`. Unlike a manual setup, you do not edit version
files by hand: the workflow derives the version name from the tag
(`v1.2.0` -> `1.2.0`) and the build number from the CI run number.

### Google Play (Android)

[![Build (& Deploy to Google Play) Android APP](https://github.com/KimiYang951116/JioLeh/actions/workflows/android-ci.yml/badge.svg)](https://github.com/KimiYang951116/JioLeh/actions/workflows/android-ci.yml)

1. From `main`, create and push a release tag, for example:

   ```bash
   git checkout main
   git pull origin main
   git tag v1.2.0
   git push origin v1.2.0
   ```

2. The `android-ci.yml` workflow builds a signed AAB and APK, uploads the AAB to
   the Google Play **internal** track, and attaches the build files to the
   GitHub Release.

### TestFlight (iOS)

[![Build (& Deploy to TestFlight) iOS APP](https://github.com/KimiYang951116/JioLeh/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/KimiYang951116/JioLeh/actions/workflows/ios-ci.yml)

1. Pushing the same `v*.*.*` tag also triggers the `ios-ci.yml` workflow.
2. It builds a signed IPA, uploads it to **TestFlight**, and attaches the IPA to
   the GitHub Release.

Release workflows depend on GitHub Actions secrets for Mapbox, Supabase, Android
signing, Google Play, Apple signing, and App Store Connect. See
[CONTRIBUTING.md](CONTRIBUTING.md) for the full release and CI details.

## Project Structure

| Path | Purpose |
|---|---|
| `lib/main.dart` | App bootstrap and service initialization |
| `lib/app.dart` | Root Flutter app and auth gate routing |
| `lib/pages/` | App pages (auth, onboarding, map, profile) |
| `lib/widgets/` | Reusable UI widgets |
| `lib/services/` | Auth, account, location, geocoding, and pin services |
| `lib/config/` | Mapbox and Supabase environment config |
| `lib/models/` | App data models |
| `test/` | Flutter tests |
| `.github/workflows/` | CI and release workflows |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for branch naming, PR workflow,
environment setup, CI behavior, and release notes.
