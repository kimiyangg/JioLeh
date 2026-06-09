# Software Design Patterns — Summary

A quick reference for the three design patterns used in this app, one from each pattern family.

| Family | Pattern | Question it answers |
|---|---|---|
| Creational | Singleton | How do we create and share one instance? |
| Structural | Facade | How do we hide a messy subsystem behind a simple interface? |
| Behavioral | Observer | How do objects react to events without polling? |

## 1. Singleton (Creational)

**Ensure one shared instance, with a single point of access.**

Instead of every screen building its own `AuthService`, the `Services` composition root creates it once and injects it everywhere. This gives a single source of truth for the Supabase client and avoids duplicate, drifting state.

> In this app: `Services.auth` is built once and shared; `pins` and `account` receive it via dependency injection.

## 2. Facade (Structural)

**Wrap a complex subsystem in a small, intention-revealing interface.**

Each service is a facade: callers ask for *what* they want and never see the messy details (HTTP, JSON parsing, permission state machines, query building).

> In this app: `GeocodingService.fetchAreaName(lat, lng)` hides the Mapbox request, throttling, and a fallback chain. The UI just gets a string back.

## 3. Observer (Behavioral)

**Let objects subscribe to events and react, instead of constantly checking.**

A publisher emits events; subscribers respond. This replaces polling with push and keeps the publisher decoupled from its listeners.

> In this app: `authStateChanges()` returns a `Stream` that `AuthGate` listens to, re-routing the app on sign-in/out. Location updates use the callback flavor (`onLocationUpdate`).

---

## How they connect

| Pattern | One-line test |
|---|---|
| Singleton | "Is there exactly one shared instance?" |
| Facade | "Can I use it without knowing how it works inside?" |
| Observer | "Does it react to events instead of polling?" |

All three reduce **coupling**: Singleton centralizes a dependency, Facade hides a subsystem behind an interface, and Observer lets components talk through events without referencing each other directly.
