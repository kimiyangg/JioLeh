# Contributing Guide

## Project Basics

GI-Jios is a Flutter app that uses Mapbox for maps and Supabase for backend
services.

Useful paths:

| Path | Purpose |
|---|---|
| `lib/` | App source code |
| `lib/config/` | Dart define based environment configuration |
| `lib/services/` | Auth, location, geocoding, and pin services |
| `lib/widgets/` | Reusable UI widgets |
| `test/` | Flutter tests |
| `.github/workflows/` | CI, build validation, and release workflows |

## Local Setup

Install the stable Flutter SDK, then check your environment:

```bash
flutter doctor
flutter pub get
```

This project currently requires the Dart SDK version declared in
`pubspec.yaml`:

```yaml
environment:
  sdk: ^3.11.5
```

## Environment Values

The app reads required values through `--dart-define`:

| Key | Required for |
|---|---|
| `MAPBOX_ACCESS_TOKEN` | Mapbox maps and geocoding |
| `MAPBOX_STYLE_URI` | Mapbox map style |
| `SUPABASE_URL` | Supabase connection |
| `SUPABASE_ANON_KEY` | Supabase client auth |

Run the app with all required values:

```bash
flutter run \
  --dart-define=MAPBOX_ACCESS_TOKEN="your-mapbox-token" \
  --dart-define=MAPBOX_STYLE_URI="your-mapbox-style-uri" \
  --dart-define=SUPABASE_URL="your-supabase-url" \
  --dart-define=SUPABASE_ANON_KEY="your-supabase-anon-key"
```

PowerShell example:

```powershell
flutter run `
  --dart-define=MAPBOX_ACCESS_TOKEN="your-mapbox-token" `
  --dart-define=MAPBOX_STYLE_URI="your-mapbox-style-uri" `
  --dart-define=SUPABASE_URL="your-supabase-url" `
  --dart-define=SUPABASE_ANON_KEY="your-supabase-anon-key"
```

Do not commit real secrets. Use local shell variables, your IDE run
configuration, or CI secrets.

## Development Checks

Before opening a pull request, run:

```bash
flutter analyze
flutter test
```

When you change dependencies, update and commit `pubspec.lock` if it changes:

```bash
flutter pub get
```

For platform-specific changes, also run the relevant local build when possible:

```bash
flutter build apk --debug
flutter build ios --debug --no-codesign
```

Include the same `--dart-define` values as needed for builds that initialize the
app configuration.

## Commit Style

Use Conventional Commits:

```text
<type>(<scope>): <short description>
```

Common types:

| Type | When to use |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `chore` | Dependencies, config, tooling, or maintenance |
| `refactor` | Code restructure with no behavior change |
| `style` | Formatting or whitespace only |
| `test` | Adding or fixing tests |
| `docs` | Documentation only |

Examples:

```text
feat(map): add real-time pin clustering
fix(auth): handle Supabase session expiry on cold start
chore(deps): bump flutter dependencies
refactor(map): extract marker builder widget
docs(contributing): clarify release workflow
```

## Branching

Branch from `main`:

```bash
git checkout main
git pull origin main
git checkout -b feat/your-feature-name
```

Branch names should match the kind of work:

```text
feat/<short-description>
fix/<short-description>
chore/<short-description>
refactor/<short-description>
docs/<short-description>
```

## Pull Requests

Open pull requests into `main`.

Before opening a PR:

- Rebase or merge the latest `main`.
- Run `flutter analyze`.
- Run `flutter test`.
- Keep the PR focused on one feature, fix, or cleanup.
- Use a Conventional Commit style PR title, for example
  `feat(map): add offline cache`.
- Explain what changed and why it changed.
- Add screenshots or screen recordings for visible UI changes.

PRs trigger `.github/workflows/pr-check.yml`, which runs:

- `flutter pub get`
- `flutter analyze`
- `flutter test`

CI must pass before merging.

## Build Validation

Build validation is defined in `.github/workflows/build-validation.yml`.

It runs Android and iOS debug builds when either:

- The workflow is triggered manually with `workflow_dispatch`.
- A PR into `main` is merged and has the `run-build-validation` label.

The workflow builds:

- Android APK with `flutter build apk --debug`
- iOS app with `flutter build ios --debug --no-codesign`

Use the `run-build-validation` label for changes that may affect platform
builds, release configuration, native code, dependencies, or environment setup.

## Releases

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

Tag pushes trigger:

| Workflow | Output |
|---|---|
| `android-ci.yml` | Android AAB/APK, Google Play internal track, GitHub Release files |
| `ios-ci.yml` | iOS IPA, TestFlight upload, GitHub Release file |

Release workflows depend on GitHub Actions secrets for Mapbox, Supabase, Android
signing, Google Play, Apple signing, and App Store Connect. Do not hard-code
these values in the repository.

## CI Summary

| Stage | Trigger | Workflow | What runs |
|---|---|---|---|
| PR check | Pull request into `main` | `pr-check.yml` | Analyze and test |
| Build validation | Manual, or merged labeled PR | `build-validation.yml` | Android and iOS debug builds |
| Release | Tag push `v*.*.*` | `android-ci.yml`, `ios-ci.yml` | Signed release builds and deployment |

## Quick Reference

```text
1. Create branch:       git checkout -b feat/...
2. Install deps:        flutter pub get
3. Run checks:          flutter analyze && flutter test
4. Push branch:         git push origin feat/...
5. Open PR:             target main
6. Merge PR:            after review and green CI
7. Release:             git tag v1.2.0 && git push origin v1.2.0
```
