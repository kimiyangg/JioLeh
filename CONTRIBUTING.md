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

## Pull Request Workflow

PRs into `main` trigger both `android-ci.yml` and `ios-ci.yml`:
- `flutter analyze`
- `flutter test`
- iOS build (no codesign)
- Android APK build (debug)

**Branch naming:**
```
feat/<short-description>       # e.g. feat/offline-map-cache
fix/<short-description>        # e.g. fix/pin-drag-gesture
chore/<short-description>
refactor/<short-description>
```

**PR checklist before opening:**
1. Branch is up to date with `main`
2. `flutter analyze` passes locally
3. `flutter test` passes locally
4. PR title follows commit convention: `feat(map): add offline cache`
5. Description explains **what** and **why**, not just what changed

CI must be green before merging. Do not merge with failing checks.

---

## Deploying — Version Tag Push

After merging to `main`, cut a version tag to trigger the release build:

```bash
# 1. Make sure you're on main and up to date
git checkout main
git pull origin main

# 2. Tag using semantic versioning
git tag v1.2.0

# 3. Push the tag — this triggers android-ci + ios-ci
git push origin v1.2.0
```

**Semantic versioning rules:**

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

**What the tag push triggers:**
- Android: builds debug APK → uploads as artifact `android-debug-apk`
- iOS: builds debug (no codesign) — full TestFlight upload is available in the workflow once signing is configured

---

## Quick Reference

```
everyday work   →  commit to feature branch
open PR         →  triggers analyze + test + build (both platforms)
merge to main   →  no CI trigger (safe landing zone)
git tag v*.*.*  →  triggers full build + artifact upload
```
