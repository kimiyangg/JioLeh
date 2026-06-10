# Contributing Guide

## Project Basics

GI-Jios is a Flutter app that uses Mapbox for maps and Supabase for backend
services.

Useful paths:

| Path | Purpose |
|---|---|
| `lib/` | App source code |
| `lib/config/` | Dart define based environment configuration |
| `lib/pages/` | App pages (auth, onboarding, map, profile) |
| `lib/services/` | Auth, account, location, geocoding, and pin services |
| `lib/models/` | App data models |
| `lib/widgets/` | Reusable UI widgets |
| `test/` | Flutter tests |
| `supabase/` | Supabase CLI config and versioned schema migrations |
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

## Backend / Supabase Schema

The app talks to several tables in the Supabase project. Sign-in uses Supabase
Auth with Google OAuth, so each row is keyed to the authenticated user.

`profiles` holds onboarding data and is created the first time a user signs in:

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key, matches the Supabase Auth user id |
| `username` | text | Set during onboarding |
| `display_name` | text | Set during onboarding |
| `birthday` | date | Optional |
| `bio` | text | Optional |
| `avatar_url` | text | Optional profile image URL |
| `created_at` | timestamp | Row creation time |
| `updated_at` | timestamp | Last update time |

`pinned_locations` holds the pins each user drops on the map:

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key, generated on insert |
| `user_id` | uuid | Owning Supabase Auth user id |
| `name` | text | Pin label |
| `emoji` | text | Pin emoji |
| `latitude` | double | |
| `longitude` | double | |
| `created_at` | timestamp | Used to order pins newest first |

`friendships` holds friend relationships between users:

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key, generated on insert |
| `requester_id` | uuid | Profile that sent the request |
| `addressee_id` | uuid | Profile that received the request |
| `status` | text | `pending`, `accepted`, or `blocked` |
| `created_at` | timestamp | Row creation time |
| `updated_at` | timestamp | Last update time |

Enable row-level security so each user can only read and write their own rows.

### Schema migrations

The database schema is version-controlled with the Supabase CLI under
`supabase/migrations/`. Evolve it through migration files instead of editing the
dashboard directly, so the local files and the cloud database stay in sync.

```bash
supabase migration new <name>   # create a new migration file
supabase db push                # apply pending migrations to the linked project
supabase db pull                # import schema changes made elsewhere
```

`supabase db push` and `db pull` need Docker Desktop running. Never commit
secrets: `supabase/.temp/` and `.env*` files are git-ignored.

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
| `db` | Database schema, migrations, or RLS policies |

Examples:

```text
feat(map): add real-time pin clustering
fix(auth): handle Supabase session expiry on cold start
chore(deps): bump flutter dependencies
refactor(map): extract marker builder widget
docs(contributing): clarify release workflow
db(friendships): add updated_at trigger
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
db/<short-description>
```

## Pull Requests

Open pull requests into `main`.

Before opening a PR:

- Rebase or merge the latest `main`.
- Run `flutter analyze`.
- Run `flutter test`.
- Keep the PR focused on one feature, fix, or cleanup.
- Add screenshots or screen recordings for visible UI changes.

PRs trigger `.github/workflows/ci.yml`, which runs:
### PR title

Use the same Conventional Commit style as commits, so the squash-merge
commit stays consistent on `main`:

```text
<type>(<scope>): <short description>
```

- Use the types from the [Commit Style](#commit-style) table.
- Scope is the affected area, for example `map`, `auth`, `onboarding`,
  `profile`, `friendships`, `deps`, or `ci`.
- Write the description in the imperative, lowercase, with no trailing
  period, and keep it under about 60 characters.

```text
feat(map): add real-time pin clustering
fix(auth): handle Supabase session expiry on cold start
db(friendships): add updated_at trigger
```

### PR description

Opening a PR pre-fills `.github/pull_request_template.md`. Fill in the
sections that apply and delete the rest:

```markdown
## What
What this PR changes, in one or two sentences.

## Why
The reason or problem it solves. Optionally link an issue: Closes #123

## How
Notable implementation decisions, trade-offs, or what to review first.
Delete if the change is trivial.
```

PRs trigger `.github/workflows/pr-check.yml`, which runs:

- `flutter pub get`
- `flutter analyze`
- `flutter test`

CI must pass before merging.

PR area labels are applied automatically by `.github/workflows/pr-labeler.yml`
from the changed paths in `.github/labeler.yml`, for example
`area:app-shell`, `area:auth`, `area:map`, `area:services`,
`area:android`, `area:ios`, `area:database`, `area:ci`, and `area:docs`.

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
| PR check | Pull request into `main` | `ci.yml` | Analyze and test |
| PR labeling | Pull request into `main` | `pr-labeler.yml` | Apply area labels from changed paths |
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
