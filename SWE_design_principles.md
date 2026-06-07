# Software Design Principles — Summary

A quick reference for the six core design principles and what each one means, plus one complementary principle (DRY).

## 1. Increase Abstraction
**Hide complexity, show what matters.** When you use something, you care about *what* it does, not *how*. Each layer (functions → classes → modules → systems) hides the messy details of the layer below.

> Example: calling `loadPinnedLocations()` and getting a list back — without seeing the database queries underneath.

## 2. Reduce Coupling
**Minimise how much components depend on each other.** X is coupled to Y if changing Y forces you to change X. Low coupling = components stand on their own. High coupling makes maintenance, testing, and reuse harder.

> Good design: components depend downward on a shared layer, not sideways on each other.

## 3. Separation of Concerns (SoC)
**Split code into distinct sections, each handling one concern.** This reduces overlap between sections and limits the "ripple effect" — a change in one part doesn't cascade everywhere.

> Example: keeping UI, business logic, and database access in separate files.

## 4. Increase Cohesion
**Keep strongly-related things together, unrelated things out.** A cohesive component is focused — everything in it serves one purpose. Low cohesion makes code harder to understand, maintain, and reuse.

> Forms: code about one concept together, code used at the same time together, code touching the same data together.

## 5. Single Responsibility Principle (SRP)
**A class should have one, and only one, reason to change.** If a class changes for two unrelated reasons (e.g. UI formatting *and* parsing logic), it's doing too much and violates SRP.

## 6. Open-Closed Principle (OCP)
**Open for extension, closed for modification.** You should be able to add new behaviour *without* editing existing, working code.

> Example: adding a new pin type by appending to a list, instead of rewriting the picker logic.

## 7. Don't Repeat Yourself (DRY)
**Every piece of knowledge should have a single, authoritative home.** Not "avoid code that looks the same" — avoid duplicating the same *fact* or *rule*. If one rule changes, you should only edit one place.

> Caveat: only deduplicate genuinely identical knowledge. Two snippets that merely *look* alike but encode different rules should stay separate — merging them creates a false dependency.

> Example: `UserFriend.fromMap` being the only place that knows how a DB row maps to a `UserFriend`, instead of repeating that mapping at every call site.

---

## How they connect

They're really six lenses on the same goal — **manageable, changeable code**:

| Principle | One-line test |
|---|---|
| Abstraction | "Do I see *what*, not *how*?" |
| Coupling | "If I change Y, does X break?" |
| SoC | "Is each concern in its own place?" |
| Cohesion | "Does everything here belong together?" |
| SRP | "Does this class have just one reason to change?" |
| OCP | "Can I extend it without editing it?" |
| DRY | "If this rule changed, is there only one place to edit?" |

**SoC is the root** — applying it well naturally produces *higher cohesion* and *lower coupling*, which in turn make *abstraction*, *SRP*, and *OCP* easier to achieve.
