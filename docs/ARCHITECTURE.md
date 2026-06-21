# Architecture

This document describes how the JioLeh app is structured: its layers, the rules
that keep them decoupled, and the patterns each feature should follow. It is the
concrete, app-specific companion to two sibling docs:

- `SWE_principles_and_practices.md` — the underlying theory (SOLID, layered
  architecture, test doubles, MVC/MVVM).
- `CODE_STYLE.md` — the practical file-organization and naming rules.

Use this document when adding a feature, reviewing structure, or deciding where a
new class or widget belongs.

> **Reference implementation:** the **auth** feature (`lib/pages/auth/` +
> `lib/services/auth_service.dart`) is the closest thing to "the ideal." When in
> doubt, make your feature look like auth. The **account** feature is the next
> most modernized.

---

## The layered architecture

Everything lives in one of five layers, and **dependencies only ever point
downward** — UI knows about contracts, never about the backend; the backend
never knows about the UI.

```text
        DEPENDENCIES POINT DOWN  ↓   (never up)

  ┌──────────────────────────────────────────────────────────────┐
  │ 1. UI            pages/ · widgets/ · theme.dart                │  screens, atoms, tokens
  └───────────────────────────┬──────────────────────────────────┘
                              │ uses
  ┌───────────────────────────▼──────────────────────────────────┐
  │ 2. PAGE LOGIC    *_model  (plain Dart, ChangeNotifier)         │  AuthGateModel, ProfilePageModel
  └───────────────────────────┬──────────────────────────────────┘
                              │ calls
  ┌───────────────────────────▼──────────────────────────────────┐
  │ 3. SERVICE       abstract *Service   (the contract)           │  AuthService, AccountService
  │    CONTRACT                                                   │
  └───────────────────────────┬──────────────────────────────────┘
                              │ implemented by
  ┌───────────────────────────▼──────────────────────────────────┐
  │ 4. SERVICE IMPL  Supabase*Service                             │  SupabaseAccountService
  └───────────────────────────┬──────────────────────────────────┘
                              │ talks to
  ┌───────────────────────────▼──────────────────────────────────┐
  │ 5. BACKEND       Supabase: tables · RLS · storage             │  supabase/migrations/
  └───────────────────────────────────────────────────────────────┘

  SHARED SPINE  (any layer may use; these depend on nothing above them):
     models/ (data)   util/ (pure rules)   config/ (env)   routing/   theme.dart
```

### The Dependency Rule

```text
  ALLOWED  (down / inward)              FORBIDDEN (up / sideways into UI)
  UI ───────▶ page logic                service ──╳──▶ pages/ or widgets/
  page logic ─▶ service CONTRACT        page logic ──╳──▶ SupabaseClient directly
  impl ──────▶ Supabase                 UI ──╳──▶ PostgrestException / XFile
  anyone ────▶ models · util · theme
```

This is **Dependency Inversion** (the *D* in SOLID) and the spirit of **Ports &
Adapters** (Hexagonal architecture): the contract is the port, `Supabase*Service`
is the adapter.

---

## The service pattern (per feature)

Every data feature is the same triangle: one abstract contract the app depends
on, one production implementation, one in-memory fake for tests.

```text
                  ┌────────────────────────────┐
    app code ────▶│  AccountService (abstract)  │ ◀── the ONLY type the app names
                  └──────────────┬─────────────┘
            implements           │           implemented by
        ┌──────────────────┐     │     ┌─────────────────────┐
        │ SupabaseAccount  │◀────┴────▶│ FakeAccountService   │
        │ Service  (prod)  │           │ (tests · in-memory)  │
        └────────┬─────────┘           └─────────────────────┘
                 ▼
             Supabase
```

A service should be **just CRUD** (create / read / update / delete). Anything
else — file upload, ID generation, error-decision logic — belongs in its own
helper or pure function so it can be tested without the database. Example: the
profile-insert collision decision is a pure `decideInsertAction(...)` function,
and username generation lives in `UsernameRule.generate()`, not in the service.

### Composition root

Implementations are chosen in exactly **one** place — `lib/services/services.dart`
— and injected through `ServiceProvider` (an `InheritedWidget`). Everywhere else
sees only the abstract type.

```text
  main.dart
     │ runApp( ServiceProvider( child: App ) )
     ▼
  ServiceProvider (InheritedWidget)         Services (singleton) ── the ONE place:
     │  exposes auth/account/… to the tree    AccountService account =
     │  (override with Fakes in tests)            SupabaseAccountService(...)
     ▼
  any widget:  ServiceProvider.of(context).account
```

### Which services have a contract today

| Feature | Pattern | Notes |
|---------|---------|-------|
| auth | abstract + impl + fake | reference implementation |
| account | abstract + impl + fake | modernized |
| friends, pin | concrete only | extract a contract **when a test needs a fake**, not before |
| location, geocoding | concrete only | thin wrappers — a contract is not justified yet |

> An abstraction must **earn its keep**: a real second implementation or a test
> fake justifies an interface; speculative flexibility does not.

---

## The frontend

The frontend combines two established patterns:

- **Atomic Design** (Brad Frost) — for the *component hierarchy*.
- **MVVM** — for the *logic split* (dumb View widgets over a testable ViewModel).
  This is Flutter's officially recommended app architecture
  (`docs.flutter.dev/app-architecture`).

The organizing principle is **dumb widgets, smart models**: push logic down out
of widgets. The further down a piece lives, the dumber, more reusable, and more
testable it is.

```text
  ┌────────────────────────────────────────────────────────────────┐
  │  SCREEN   (StatefulWidget)   login_page · profile_page           │ holds UI state,
  │     · reads services via ServiceProvider · wires callbacks        │ wires callbacks
  └───────────────┬───────────────────────────────┬─────────────────┘
        composes  │                                │ delegates its brain to
  ┌───────────────▼───────────────┐   ┌────────────▼──────────────────┐
  │ FEATURE WIDGETS                │   │ PAGE LOGIC  (the brain)        │
  │ pages/<f>/widgets/             │   │ <page>_model (ChangeNotifier)  │  ◀─ testable
  │ SignInPanel · ProfileCard      │   │  + pure helpers:               │     with NO UI
  │ (dumb, stateless)              │   │  resolver · parser · holder    │
  └───────────────┬───────────────┘   └────────────┬──────────────────┘
        built from│                                 │ calls
  ┌───────────────▼───────────────┐                 ▼
  │ ATOMS   lib/widgets/           │          SERVICE CONTRACTS
  │ AppPrimaryButton · AppTextField│          (see the service pattern above)
  │ context.showAppSnackBar  (dumb)│
  └───────────────┬───────────────┘
        styled by │
  ┌───────────────▼───────────────┐
  │ TOKENS   theme.dart            │  AppColors · AppTextSizes · AppRadii · scaledFont()
  └────────────────────────────────┘
```

### Component levels (Atomic Design) and where they live

| Level | Meaning | Lives in | Examples |
|-------|---------|----------|----------|
| *(tokens)* | sub-atomic values | `theme.dart` | `AppColors`, `AppTextSizes`, `AppRadii` |
| **Atom** | can't break down further | `lib/widgets/` | `AppPrimaryButton`, `AppTextField`, `AppSectionLabel` |
| **Molecule** | a few atoms as one unit | shared → `lib/widgets/`; feature → `pages/<f>/widgets/` | `BirthdayRow`, `BrandLockup` |
| **Organism** | a whole composed section | `pages/<f>/widgets/` | `SignInPanel`, `ProfileCard` |
| ~~Template~~ | layout skeleton | — | folded into the Page in Flutter; not a separate layer |
| **Page** | screen with real data + state | `pages/<f>/` | `AuthPage`, `ProfilePage` |

**Classification rubric** — when you make a UI widget, ask "how big is it?":

- Can't be broken down (button, field, label) → **Atom** → `lib/widgets/`
- A few atoms acting as one reusable unit → **Molecule** → `lib/widgets/`
- A whole feature section / form / card → **Organism** → `pages/<feature>/widgets/`
- A full screen → **Page** → `pages/<feature>/<page>.dart`
- Tokens (colours, sizes, radii) always live in `theme.dart` — never inline.

A one-line `/// Organism — …` doc comment on the class is enough to label a
widget's level; do **not** create `atoms/` `molecules/` `organisms/` subfolders
inside a feature (over-engineering at this scale, and the molecule/organism line
shifts as widgets grow).

### MVVM split

```text
  View       = the widget tree (screen + feature widgets + atoms) — dumb
  ViewModel  = <page>_model (ChangeNotifier) — presentation state + logic
  Model      = data (UserProfile) + the service contracts
```

The View renders the ViewModel's state and forwards events; it never holds
business rules. Because the ViewModel is plain Dart, it is unit-tested with no
widget rendering — see `auth_gate_model_test`, plus the pure helpers
`resolveAuthGateState`, `profileIdFromDeepLink`, and `ProfileLinkHolder`.

> Composition (which widget contains which) is expressed by **imports**, not
> folders. Read a widget file's imports top-down to see the atom→organism
> hierarchy. Folders express *reuse scope* (shared vs feature), not composition.

---

## Folder structure

Feature-first. See `CODE_STYLE.md` for the authoritative file-organization rules;
the shape is:

```text
lib/
  main.dart                    entry + mounts the composition root
  app/                         DI wiring (service_provider.dart) + app shell
  pages/<feature>/             UI for one feature:
      <page>.dart                  the Page (thin)
      <page>_model.dart            the ViewModel (when the page has real logic)
      widgets/                     this feature's organisms + molecules (one file each)
  widgets/                     shared, dumb, cross-feature atoms/molecules
  theme.dart                   design tokens
  services/                    *_service (contract) + supabase_*_service (impl)
                               + services.dart (composition root)
  models/                      plain data classes (fromMap / toMap)
  util/                        pure logic/rules (UsernameRule, birthday)
  config/                      env parsing + validation
  routing/                     AppRoutes
test/                          mirrors lib/, with services/fakes/
supabase/migrations/           schema · RLS · storage · triggers
```

---

## Testing strategy per layer

| Layer | How it is tested | Example |
|-------|------------------|---------|
| pure logic / util | plain unit test | `decideInsertAction`, `UsernameRule` |
| page logic (ViewModel) | unit test + a `Fake*Service` | `auth_gate_model_test` |
| service contract | a `Fake*Service` for consumers; pure helpers for logic | `FakeAccountService` |
| widgets | widget / golden test | `onboarding_widgets_test` |
| backend | migrations + RLS (integration / manual) | `supabase/migrations/` |

---

## Reference patterns (for the README and reviews)

| In this codebase | Established name | Reference |
|------------------|------------------|-----------|
| layers, deps point down | Layered architecture; Hexagonal / Ports & Adapters | Cockburn; R.C. Martin |
| `*_model` + thin widget | **MVVM** | Flutter App Architecture guide; Fowler, *Presentation Model* |
| abstract `*Service` + impl | **Dependency Inversion** (SOLID); Repository/Service | R.C. Martin; Fowler, *PoEAA* |
| `Fake*Service` | **Test Double → Fake** | Meszaros, *xUnit Test Patterns* |
| `services.dart` picks impls once | **Composition Root** + DI | Seemann, *Dependency Injection* |
| `theme.dart` tokens | **Design Tokens** | W3C Design Tokens Community Group |
| `lib/widgets/` atoms → composed widgets | **Atomic Design** | Brad Frost, *Atomic Design* |
| splitting a god-service | **Single Responsibility** (SOLID) | R.C. Martin |
| single-sourced rules/constants | **DRY / Single Source of Truth** | Hunt & Thomas, *The Pragmatic Programmer* |

> This is **pragmatic MVVM + a repository/service layer with dependency
> inversion** — the same family as Clean / Hexagonal architecture, intentionally
> kept lightweight. It is *not* full Clean Architecture (no separate
> entities/use-case layers), and should not be described as such.
