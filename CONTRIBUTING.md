# Contributing Guide

Thanks for contributing to JioLeh! This guide is the workflow hub for the
project. Detailed reference material lives in `docs/` so this file stays easy
to scan.

## Project Basics

GI-Jios is a Flutter app that uses Mapbox for maps and Supabase for backend
services.

Useful paths:

| Path | Purpose |
|---|---|
| `lib/` | App source code |
| `lib/config/` | Dart define based environment configuration |
| `lib/pages/` | App pages (auth, onboarding, map, profile) |
| `lib/pages/**/widgets/` | Page-specific reusable UI widgets |
| `lib/services/` | Auth, account, friends, location, geocoding, and pin services |
| `lib/models/` | App data models |
| `test/` | Flutter tests |
| `supabase/` | Supabase CLI config and versioned schema migrations |
| `.github/workflows/` | Continuous Integration, build validation, and release workflows |
| `docs/` | Detailed project references |

## Reference Docs

| Document | What it covers |
|---|---|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | App layers, the service contract/impl/fake pattern, frontend (Atomic Design + MVVM), and folder structure, with diagrams |
| [`docs/CODE_STYLE.md`](docs/CODE_STYLE.md) | Dart, Flutter, naming, structure, testing, and documentation style |
| [`docs/DATABASE.md`](docs/DATABASE.md) | Supabase schema, Row-Level Security, storage, and migration workflow |
| [`docs/RELEASE.md`](docs/RELEASE.md) | Version tags, Android release, iOS release, and release secrets |
| [`docs/SWE_principles_and_practices.md`](docs/SWE_principles_and_practices.md) | Software engineering study/reference notes |
| [`docs/UI_UX_PRINCIPLES.md`](docs/UI_UX_PRINCIPLES.md) | Usability, accessibility, and review principles for user interface changes |

## Local Setup

Install the stable Flutter Software Development Kit (SDK), then check your
environment:

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

The app also needs Mapbox and Supabase `--dart-define` values when running or
building. See [`README.md`](README.md) for the run command and environment keys.

## Development Checks

Before opening a pull request, run:

```bash
dart format lib test
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

Build commands may need the same `--dart-define` values used by `flutter run`.

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
| `db` | Database schema, migrations, or Row-Level Security policies |

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

Before opening a pull request:

- Rebase or merge the latest `main`.
- Run `dart format lib test`.
- Run `flutter analyze`.
- Run `flutter test`.
- Keep the pull request focused on one feature, fix, or cleanup.
- Add screenshots or screen recordings for visible user interface changes.
- Link related issues where applicable.

### Pull Request Title

Use the same Conventional Commit style as commits, so the squash-merge commit
stays consistent on `main`:

```text
<type>(<scope>): <short description>
```

- Use the types from the [Commit Style](#commit-style) table.
- Scope is the affected area, for example `map`, `auth`, `onboarding`,
  `profile`, `friendships`, `deps`, or `ci`.
- Write the description in the imperative, lowercase, with no trailing period.
- Keep the description under about 60 characters.

Examples:

```text
feat(map): add real-time pin clustering
fix(auth): handle Supabase session expiry on cold start
db(friendships): add updated_at trigger
```

### Pull Request Description

Opening a pull request pre-fills `.github/pull_request_template.md`. Fill in the
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

## Continuous Integration

Pull requests trigger `.github/workflows/pr-check.yml`, which runs:

- `flutter pub get`
- `flutter analyze`
- `flutter test`

Continuous Integration (CI) must pass before merging.

Pull request area labels are applied automatically by
`.github/workflows/pr-labeler.yml` from the changed paths in
`.github/labeler.yml`, for example `area:app-shell`, `area:auth`, `area:map`,
`area:services`, `area:android`, `area:ios`, `area:database`, `area:ci`, and
`area:docs`.

Build validation is defined in `.github/workflows/build-validation.yml`.

It runs Android and iOS debug builds when either:

- The workflow is triggered manually with `workflow_dispatch`.
- A pull request into `main` is merged and has the `run-build-validation` label.

Use the `run-build-validation` label for changes that may affect platform
builds, release configuration, native code, dependencies, or environment setup.

## Quick Reference

```text
1. Create branch:       git checkout -b feat/...
2. Install deps:        flutter pub get
3. Format:              dart format lib test
4. Run checks:          flutter analyze && flutter test
5. Push branch:         git push origin feat/...
6. Open PR:             target main
7. Merge PR:            after review and green CI
8. Release:             see docs/RELEASE.md
```
