# Contributing Guide

## Commit Style

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <short description>
```

**Types:**

| Type | When to use |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `chore` | Deps, config, tooling (no production code) |
| `refactor` | Code restructure, no behavior change |
| `style` | Formatting, whitespace |
| `test` | Adding or fixing tests |
| `docs` | Documentation only |

**Examples:**
```
feat(map): add real-time pin clustering
fix(auth): handle Supabase session expiry on cold start
chore(deps): bump flutter to 3.22.0
refactor(map): extract marker builder to separate widget
```

**Rules:**
- Keep the subject line under 72 characters
- Use imperative mood: "add feature" not "added feature"
- No period at the end of the subject line
- Reference issues in the body if relevant: `Closes #42`

---

## Full Workflow — Branch → PR → Deploy

### Step 1 — Create a branch

Branch off `main` using the naming convention:

```bash
git checkout main
git pull origin main
git checkout -b feat/your-feature-name
```

**Branch naming:**
```
feat/<short-description>       # e.g. feat/offline-map-cache
fix/<short-description>        # e.g. fix/pin-drag-gesture
chore/<short-description>
refactor/<short-description>
```

---

### Step 2 — Commit your changes

Commit frequently with clear messages following the commit style above:

```bash
git add .
git commit -m "feat(map): add real-time pin clustering"
```

Push your branch to remote:

```bash
git push origin feat/your-feature-name
```

---

### Step 3 — Open a Pull Request into `main` → Stage 1 CI

Opening a PR triggers **`pr-check.yml`** (fast validation only, target: <10 min):
- `flutter analyze`
- `flutter test`

No builds are run at this stage. CI must be green before merging.

**PR checklist before opening:**
1. Branch is up to date with `main`
2. `flutter analyze` passes locally
3. `flutter test` passes locally
4. PR title follows commit convention: `feat(map): add offline cache`
5. Description explains **what** and **why**, not just what changed

---

### Step 4 — Merge into `main` → Stage 2 CI

Squash and merge (preferred) or merge commit. Delete the branch after merging.

Merging to `main` triggers **`build-validation.yml`** (full build check):
- Android APK build (debug, no upload)
- iOS build (no codesign, no upload)

This confirms the app builds cleanly on both platforms before a release is cut. Can also be triggered manually via `workflow_dispatch`.

---

### Step 5 — Tag a version to deploy → Stage 3 CI

After the build validation passes, cut a version tag to trigger the release:

```bash
git checkout main
git pull origin main

git tag v1.2.0
git push origin v1.2.0
```

This triggers **`android-ci.yml`** and **`ios-ci.yml`** (release builds):
- Android: builds APK → uploads as artifact `android-debug-apk-v1.2.0`
- iOS: builds (no codesign) — TestFlight upload available once signing is configured

No tests are re-run at this stage — code was already validated in Stage 1.

**Semantic versioning:**

```
v<MAJOR>.<MINOR>.<PATCH>

MAJOR → breaking change or major milestone
MINOR → new feature, backwards-compatible
PATCH → bug fix or small tweak
```

**Examples:**
```
v1.0.0   — first public release
v1.1.0   — added offline map support
v1.1.1   — fixed crash on pin tap
v2.0.0   — rewrote auth flow
```

---

## CI/CD Stage Summary

| Stage | Trigger | Workflow | What runs |
|---|---|---|---|
| 1 — PR Check | PR opened/updated → `main` | `pr-check.yml` | analyze + test only |
| 2 — Build Validation | Merge to `main` or manual | `build-validation.yml` | Android + iOS builds, no upload |
| 3 — Release | Tag push `v*.*.*` | `android-ci.yml` + `ios-ci.yml` | Build + upload artifacts |

Each stage is isolated. No stage duplicates another's responsibility.

---

## Quick Reference

```
1. git checkout -b feat/...          →  create branch
2. git commit + git push             →  commit work
3. open PR into main                 →  Stage 1: analyze + test
4. merge PR                          →  Stage 2: full build validation
5. git tag v*.*.* + push tag         →  Stage 3: release build + artifact upload
```
