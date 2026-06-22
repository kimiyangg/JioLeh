# Code Style

This document describes the practical code style for JioLeh!. It complements
the formatter and analyzer; it does not replace them.

## Formatter and Analyzer

Run the Dart formatter before committing Dart changes:

```bash
dart format lib test
```

Run static checks:

```bash
flutter analyze
```

Follow the lint rules in `analysis_options.yaml`. Treat analyzer warnings as
issues to fix rather than noise to ignore.

## Naming

- Prefer clear, descriptive names over abbreviations.
- If an abbreviation is necessary in documentation, write the full form first.
  Example: `Quality Assurance (QA)`.
- Use nouns for classes and data objects.
- Use verbs or verb phrases for methods that perform actions.
- Use boolean names that read naturally, such as `isPrivate`, `hasProfile`, or
  `canEdit`.
- Keep naming consistent across models, services, pages, tests, and database
  fields.

## File Organization

- Put app entry and bootstrapping code in `lib/main.dart`.
- Put top-level app wiring and the app shell in `lib/app/`, and centralized
  route definitions in `lib/routing/`.
- Put page-level screens under `lib/pages/`.
- Put page-specific reusable widgets under that page's `widgets/` folder.
- Put shared integration logic in `lib/services/`.
- Put environment parsing and validation in `lib/config/`.
- Put data shape, parsing, and serialization in `lib/models/`.
- Put tests under `test/`, following the shape of the code being tested where
  practical.

## Widgets and Pages

- Pages should focus on layout, user interaction, and screen-level state.
- Extract widgets when a page becomes difficult to scan or a user interface
  section has its own clear purpose.
- Give each public widget its own file, named after it in `snake_case`
  (`SignInPanel` → `sign_in_panel.dart`). Keep private (`_`-prefixed)
  sub-widgets in the file of the public widget that uses them.
- Keep long asynchronous workflows out of `build` methods.
- Avoid putting raw Supabase queries directly inside widgets.
- Prefer passing callbacks and values into widgets instead of making widgets
  reach into unrelated services.

## Services

- Services own external integration and application operations.
- Keep Supabase, Mapbox, authentication, location, storage, and friend logic in
  services rather than pages.
- Services should expose intention-revealing methods, such as
  `loadPlacesNearLocation`, `sendFriendRequest`, or `createPhotoUrls`.
- Prefer dependency injection through constructors over creating hidden service
  instances inside methods.
- Keep cleanup behavior explicit when a multi-step operation can partially
  succeed, such as saving a pin and uploading photos.

## Models

- Models should represent data shape and parsing rules.
- Keep `fromMap`, `toMap`, and related conversion logic close to the model.
- Normalize user-entered strings before saving where the model owns that save
  shape.
- Use nullable fields intentionally for optional data.
- Prefer meaningful defaults only when the application can safely display or use
  them.

## Comments

- Use comments to explain intent, caller contracts, business rules, non-obvious
  constraints, and risky implementation decisions.
- Use documentation comments (`///`) for public classes, public methods,
  exceptions, and models when callers need to understand behavior, return
  values, side effects, nullability, or thrown errors.
- Use implementation comments (`//`) inside methods to explain why a branch,
  retry, cleanup step, workaround, or business rule exists.
- Do not add comments for common language syntax, simple assignments, or
  obvious control flow.
- Do not repeat what the code already says.
- Keep public comments accurate when behavior changes.
- Remove stale comments when refactoring.

Good documentation comment:

```dart
/// Returns the current user's ID.
///
/// Throws [NotSignedInException] when no user is signed in.
String getCurrentUserId()
```

Good implementation comment:

```dart
// A generated username can randomly collide with an existing one, so keep
// generating a fresh code and retrying until the insert succeeds.
```

Avoid comments that only translate syntax:

```dart
// Assigns the client to _supabase.
_supabase = client;
```

## Error Handling

- Handle expected failure paths with clear messages or domain-specific
  exceptions.
- Avoid empty `catch` blocks unless preserving an original error, and leave a
  short explanation when doing so.
- Do not swallow Supabase or platform errors that callers need to surface to the
  user.
- Prefer validating invalid input near the boundary where it enters the system.

## Testing Style

- Add tests for parsing, validation, and service behavior when a change touches
  shared logic.
- Use widget tests for user interface behavior that can regress visually or
  interactively.
- Prefer small focused tests over large tests that fail for many unrelated
  reasons.
- Name tests by behavior, not implementation details.
- Keep test data explicit enough that the expected behavior is easy to see.

## Review Checklist

Before asking for review, check:

- Dart files are formatted.
- `flutter analyze` passes.
- `flutter test` passes.
- The change is scoped to one feature, fix, or cleanup.
- New or risky behavior has tests.
- Database changes are migrations, not dashboard-only edits.
- User-facing changes have screenshots or screen recordings in the pull request.
