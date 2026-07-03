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

- A Mapbox-powered map interface with a bottom navigation shell of four tabs
  (Map, Jios, Friends, You) and a center button to add a location.
- Current location detection and live location updates.
- Reverse geocoding to show the user's current area.
- Google sign-in through Supabase Auth.
- An auth gate that routes users between sign-in, onboarding, and the home shell.
- First-time onboarding to set up a user profile (username, display name,
  birthday, and an optional profile photo).
- Profile viewing, profile editing, avatar photos, and share-code access via QR
  code and deep links.
- Friend search by username, friend requests, accept/reject flows, and friend
  removal.
- OpenJio gathering invitations: create an invite to selected friends with a
  date and time, caption, and location, and recipients can accept, decline, or
  leave.
- JioChat real-time group chat for each OpenJio gathering, with text and photo
  messages.
- Persistent places, user pins, user profiles, friendships, OpenJio events,
  invite statuses, and chat messages stored in Supabase.
- Map pins with custom names, emoji, ratings, reviews, privacy, and up to three
  photos per pin.
- Nearby place loading around the current map area.
- A map toolbar for recentering and adding pins, plus a current-area bar.

## Product Direction

The aims of our project include but are not limited to:

- Sharing real-world recommendations such as restaurants, entertainment venues,
  hotels, toilets, and memorable places.
- Letting friends view trusted ratings, reviews, photos, and comments.
- Supporting private friend-based discovery instead of public-only reviews.
- Making exploration more engaging through points, leaderboards, map
  progression, virtual buildings, and other game-like features.
- Helping users plan outings through shared friend recommendations and
  OpenJio-style gathering flows.

## Roadmap

Planned features from the proposal include:

- Location categories beyond emoji-based custom pins.
- Comments and place-specific discussion.
- Social points and friend leaderboards.
- Fog-of-map exploration.
- Group location filters.
- Profile search and close-friends filtering.
- AI-assisted content classification and recommendation ideas.

## Tech Stack

| Area | Technology |
|---|---|
| App | Flutter, Dart |
| Maps | Mapbox Maps SDK for Flutter |
| Location | Geolocator |
| Backend | Supabase |
| Auth | Supabase Auth with Google OAuth (`google_sign_in`) |
| Database | Supabase PostgreSQL |
| Real-time | Supabase Realtime (OpenJio invites and JioChat messages) |
| Photos | `image_picker`, Supabase Storage |
| Fonts | `google_fonts` (Gabarito) |
| Sharing | `qr_flutter`, `app_links` deep links, `share_plus`, `url_launcher` |
| HTTP | Dart `http` package |
| CI/CD | GitHub Actions |

## Getting Started

Install Flutter, clone the repo, then fetch dependencies:

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
| `GOOGLE_PLACES_API_KEY` | Google Places API (nearby place suggestions) |

Run the app:

```bash
flutter run \
  --dart-define=MAPBOX_ACCESS_TOKEN="your-mapbox-token" \
  --dart-define=MAPBOX_STYLE_URI="your-mapbox-style-uri" \
  --dart-define=SUPABASE_URL="your-supabase-url" \
  --dart-define=SUPABASE_ANON_KEY="your-supabase-anon-key" \
  --dart-define=GOOGLE_PLACES_API_KEY="your-google-places-api-key"
```

PowerShell:

```powershell
flutter run `
  --dart-define=MAPBOX_ACCESS_TOKEN="your-mapbox-token" `
  --dart-define=MAPBOX_STYLE_URI="your-mapbox-style-uri" `
  --dart-define=SUPABASE_URL="your-supabase-url" `
  --dart-define=SUPABASE_ANON_KEY="your-supabase-anon-key" `
  --dart-define=GOOGLE_PLACES_API_KEY="your-google-places-api-key"
```

Do not commit real secrets.

## Backend at a Glance

JioLeh! uses Supabase for authentication, storage, and data persistence. The
current app flow is centered around:

- `profiles`: user onboarding and profile data.
- `places`: shared map places with coordinates and provider/user source data.
- `user_pins`: a user's personal pin for a place, including custom name, emoji,
  rating, review, privacy, and photo paths.
- `friendships`: friend request and accepted-friend relationships.
- `open_jio_events`: OpenJio gathering invitations created by a user.
- `open_jio_invite_statuses`: per-invitee pending/accepted/declined status for an
  event (the source of truth for who is invited).
- `jio_chat_messages`: real-time group-chat messages for an OpenJio event.
- Supabase Storage buckets `pin-photos` (private), `profile-photos` (public),
  and `chat-photos` (public).

The database schema is version-controlled under `supabase/migrations/`. See
[CONTRIBUTING.md](CONTRIBUTING.md) for schema, migration, build, continuous
integration, and release workflows.

## Project Structure

| Path | Purpose |
|---|---|
| `lib/main.dart` | App bootstrap and service initialization |
| `lib/app/` | Root app shell, auth gate, and service-provider wiring |
| `lib/routing/` | Centralized route definitions (`AppRoutes`) |
| `lib/pages/` | App pages (auth, onboarding, home, map, profile, friends, invitations) |
| `lib/pages/**/widgets/` | Page-specific reusable UI widgets |
| `lib/services/` | Auth, account, friends, location, geocoding, pin, OpenJio, and JioChat services |
| `lib/services/supabase/` | Supabase implementations of the service contracts |
| `lib/config/` | Mapbox and Supabase environment config |
| `lib/models/` | App data models |
| `test/` | Flutter tests, including in-memory service fakes |
| `supabase/migrations/` | Versioned database schema (Supabase CLI) |
| `.github/workflows/` | CI and release workflows |
| `docs/` | Code style, database, release, and software engineering references |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for local checks, branch naming, pull
request workflow, and Continuous Integration behavior. Detailed references live
under `docs/`.
