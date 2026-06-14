# Release Guide

Release builds and store uploads are driven by GitHub Actions.

## Version Tags

Releases are triggered by version tags that match:

```text
v*.*.*
```

Create and push a release tag from `main`:

```bash
git checkout main
git pull origin main
git tag v1.2.0
git push origin v1.2.0
```

Use semantic versioning:

```text
v<MAJOR>.<MINOR>.<PATCH>
```

Examples:

```text
v1.0.0  first public release
v1.1.0  new backwards-compatible feature
v1.1.1  bug fix or small tweak
v2.0.0  breaking change or major milestone
```

Unlike a manual setup, do not edit version files by hand. The workflows derive:

- Version name from the tag, for example `v1.2.0` becomes `1.2.0`.
- Build number from the GitHub Actions run number.

## Android: Google Play

[![Build (& Deploy to Google Play) Android APP](https://github.com/KimiYang951116/JioLeh/actions/workflows/android-ci.yml/badge.svg)](https://github.com/KimiYang951116/JioLeh/actions/workflows/android-ci.yml)

Pushing a `v*.*.*` tag triggers `.github/workflows/android-ci.yml`.

The workflow:

- Builds a signed Android App Bundle (AAB).
- Builds a signed Android Package (APK).
- Uploads the Android App Bundle to the Google Play internal track.
- Attaches build files to the GitHub Release.

## iOS: TestFlight

[![Build (& Deploy to TestFlight) iOS APP](https://github.com/KimiYang951116/JioLeh/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/KimiYang951116/JioLeh/actions/workflows/ios-ci.yml)

Pushing a `v*.*.*` tag also triggers `.github/workflows/ios-ci.yml`.

The workflow:

- Builds a signed iOS App Store Package (IPA).
- Uploads the IPA to TestFlight.
- Attaches the IPA to the GitHub Release.

## Required Secrets

Release workflows depend on GitHub Actions secrets for:

- Mapbox.
- Supabase.
- Android signing.
- Google Play.
- Apple signing.
- App Store Connect.

Do not hard-code these values in the repository.

## Pre-Release Checklist

Before tagging a release:

- Merge the release-ready changes into `main`.
- Confirm pull request checks are green.
- Run build validation for changes that affect native code, dependencies,
  release configuration, or environment setup.
- Confirm required release secrets are configured.
- Confirm user-facing changes are reflected in release notes or the GitHub
  Release description.
