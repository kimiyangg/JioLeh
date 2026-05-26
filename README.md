# Jio Leh

A Flutter-based location social media & gaming application.

## Overview

Jio Leh is a cross-platform mobile application that allows users to:

* View their live location on an interactive Mapbox map
* Pin locations directly onto the map
* Save pinned locations to a Supabase backend
* Retrieve previously saved pins
* Reverse geocode coordinates into readable place names
* Use anonymous authentication for lightweight onboarding

The project is structured using a clean service-oriented architecture, separating:

* UI/pages
* Models
* Backend services
* Environment configuration
* Location and geocoding logic

---

## Tech Stack

### Frontend

* Flutter
* Dart
* Material UI

### Mapping & Location

* Mapbox Maps Flutter SDK
* Geolocator

### Backend & Database

* Supabase
* Supabase Anonymous Authentication

### Networking

* HTTP package

---

## Project Structure

```text
lib/
├── app.dart
├── main.dart
├── config/
│   ├── map_env.dart
│   ├── supabase_env.dart
│   └── validate_env.dart
├── models/
│   └── pinned_location.dart
├── pages/
│   └── map_page.dart
├── services/
│   ├── auth_services.dart
│   ├── geocoding_services.dart
│   ├── location_services.dart
│   └── pin_services.dart
```

### Directory Breakdown

#### `config/`

Contains environment configuration and validation logic.

* `map_env.dart` → Mapbox access token configuration
* `supabase_env.dart` → Supabase URL and anon key
* `validate_env.dart` → Runtime validation for required environment variables

#### `models/`

Contains data models used throughout the application.

* `pinned_location.dart` → Represents a saved map pin

#### `pages/`

Contains application screens.

* `map_page.dart` → Main interactive map screen

#### `services/`

Encapsulates business logic and external integrations.

* `auth_services.dart` → Handles Supabase authentication
* `location_services.dart` → Manages device location tracking
* `geocoding_services.dart` → Converts coordinates into readable locations
* `pin_services.dart` → Handles CRUD operations for saved pins

---

## Features

### Interactive Map

* Live map rendering with Mapbox
* Smooth camera movement
* Real-time location updates
* User location puck and accuracy ring

### Location Tracking

* GPS-based location tracking
* Continuous position updates
* Device permission handling

### Pin Management

* Create location pins
* Save pins to Supabase
* Load user-specific saved pins
* Display pins as map annotations

### Reverse Geocoding

* Converts latitude/longitude into readable area names
* Enhances user experience with contextual location labels

### Authentication

* Anonymous sign-in using Supabase
* Automatic session reuse
* Lightweight onboarding flow

---

## License

This project is currently private and not licensed for public distribution.

---

## Acknowledgements

Built using:

* Flutter
* Mapbox
* Supabase
* Geolocator
