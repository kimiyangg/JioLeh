# Database and Supabase

JioLeh! uses Supabase for authentication, PostgreSQL data, Row-Level Security,
and image storage.

## Current Tables

Sign-in uses Supabase Auth with Google OAuth, so app data is keyed to the
authenticated user.

### `profiles`

`profiles` holds onboarding and profile data. It is keyed to the Supabase Auth
user id and is created during onboarding by `AccountService.createProfile`.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key, matches the Supabase Auth user id |
| `username` | text | Set during onboarding, falling back to a generated code |
| `display_name` | text | Set during onboarding |
| `birthday` | date | Optional |
| `bio` | text | Optional |
| `avatar_url` | text | Optional profile image URL field in the schema |
| `created_at` | timestamp | Row creation time |
| `updated_at` | timestamp | Last update time |

### `places`

`places` holds shared place rows that can be pinned by users.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `name` | text | Shared place name |
| `category` | text | Optional category/provider classification |
| `latitude` | double | Required for map lookup |
| `longitude` | double | Required for map lookup |
| `provider` | text | Optional external provider name |
| `provider_place_id` | text | Optional external provider id |
| `status` | text | `pending`, `approved`, or `rejected` |
| `source` | text | `provider` or `user` |
| `pin_count` | integer | Number of distinct users who pinned the place |
| `created_by` | uuid | User who created a user-sourced place |
| `created_at` | timestamp | Row creation time |
| `refreshed_at` | timestamp | Provider cache refresh time |

### `user_pins`

`user_pins` holds each user's personal pin for a place.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `user_id` | uuid | Owning Supabase Auth user id |
| `place_id` | uuid | Linked row in `places` |
| `custom_name` | text | Optional user-specific place nickname |
| `emoji` | text | Pin emoji |
| `visibility` | text | Legacy/placeholder visibility field |
| `is_private` | boolean | Private pins are hidden from friends |
| `ratings` | smallint | Optional rating from 1 to 5 |
| `reviews` | text | Optional review, limited to 500 characters |
| `photo_paths` | text[] | Supabase Storage paths, maximum three photos |
| `created_at` | timestamp | Row creation time |

### `friendships`

`friendships` holds friend relationships between users.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key, generated on insert |
| `requester_id` | uuid | Profile that sent the request |
| `addressee_id` | uuid | Profile that received the request |
| `status` | text | `pending`, `accepted`, or `blocked` |
| `created_at` | timestamp | Row creation time |
| `updated_at` | timestamp | Last update time |

## Storage

Pin photos are stored in the Supabase Storage bucket `pin-photos`.

Current behavior:

- A pin can have at most three photos.
- Stored paths are saved in `user_pins.photo_paths`.
- The app creates signed URLs when loading photos.
- Upload cleanup should remove already-uploaded photos if saving the full pin
  fails.

## Row-Level Security

Row-Level Security (RLS) is enabled.

Current policy direction:

- Authenticated users can read profiles.
- Authenticated users can read places.
- Users can manage their own pins.
- Users can read non-private pins from accepted friends.
- Users can create and update places they created.

The helper function `public.are_friends(user_a uuid, user_b uuid)` checks
whether two users have an accepted friendship.

## Migrations

The database schema is version-controlled with the Supabase Command Line
Interface (CLI) under `supabase/migrations/`.

Evolve the schema through migration files instead of editing the dashboard
directly, so local files and the cloud database stay in sync.

```bash
supabase migration new <name>   # create a new migration file
supabase db push                # apply pending migrations to the linked project
supabase db pull                # import schema changes made elsewhere
```

`supabase db push` and `supabase db pull` need Docker Desktop running.

Never commit secrets. `supabase/.temp/` and `.env*` files are git-ignored.

## Notes

Some older migrations still mention `pinned_locations`. The current app flow
saves new map data through `places` and `user_pins`.

When changing the schema:

- Add a migration file.
- Update affected Dart models and services.
- Update tests for parsing, validation, or service behavior.
- Update this document when tables, policies, or storage behavior change.
