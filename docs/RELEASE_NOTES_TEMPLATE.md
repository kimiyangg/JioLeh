# Release Notes Template

Use this template when submitting a build to TestFlight, Google Play, or any
internal/external testing track. Copy the block below, fill it in, and delete
the guidance lines in parentheses.

---

## Release Name

(Release Name | Testing Version)

## Function Description

(One paragraph describing what the app does and what this build includes.
Write for a tester or reviewer who has never seen the app. Mention the headline
capabilities available in this build, e.g. sign-in, profile setup, the map,
location tracking, custom pins, etc.)

## Version Notes

(Bullet list of what changed in this build, in the imperative or past tense.
Group related changes together. Keep each bullet to one user- or
reviewer-meaningful change. Mirror the scopes from CONTRIBUTING.md where useful:
map, auth, onboarding, profile, friendships, deps, ci.)

- ...
- ...
- ...

## Publish Scope

(Internal Testing | Closed Beta | Open Beta | Production)

---

## Example (v-beta-1)

### Release Type
Testing Version

### Function Description
JioLeh! is a social map app for saving meaningful real-world places and building
a more personal way to discover locations with friends. This first public beta
includes Google sign-in, first-time profile setup, a Mapbox-powered map, current
location tracking, current-area lookup, profile viewing, sign-out, and persistent
custom emoji location pins stored through Supabase.

### Version Notes
- Refactored the map page into smaller, clearer modules for pin type selection,
  location name customization, and map pin rendering.
- Replaced the old private pin option class with a structured `PinType` enum for
  restaurant, gym, hotel, and toilet pins.
- Extracted Mapbox pin rendering into a dedicated `MapPins` renderer, including
  emoji image caching and nearby-pin overlap handling.
- Moved the location customization bottom sheet into its own reusable map widget.
- Moved the pin type picker bottom sheet into its own reusable map widget.
- Updated app-wide service usage so auth, account, pin, location, and geocoding
  services resolve from a shared `Services` composition root.
- Updated login, onboarding, profile, and map pages to use the shared service
  setup instead of creating duplicate service instances.
- Added centralized app theme color definitions.
- Updated onboarding helper text.
- Added SWE design principle and design pattern documentation.

### Publish Scope
Internal Testing
