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
| `username` | text | Set during onboarding; falls back to an app-generated code (`UsernameRule`) |
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

A row is unique per `(requester_id, addressee_id)` pair, and a user cannot
befriend themselves (`requester_id <> addressee_id`).

### `open_jio_events`

`open_jio_events` holds OpenJio gathering invitations created by a user.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `user_id` | uuid | Creator (Supabase Auth user id) |
| `date_time` | timestamp | When the gathering happens |
| `caption` | text | Short description |
| `location_name` | text | Free-text location name |
| `created_at` | timestamp | Row creation time |

The invitee list is not stored on this table. An earlier
`invited_friend_ids` array column was dropped; `open_jio_invite_statuses` is now
the single source of truth for who is invited.

### `open_jio_invite_statuses`

`open_jio_invite_statuses` holds one row per invitee per event, tracking their
response. It is enabled for Supabase Realtime so invite responses update live.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `event_id` | uuid | Linked row in `open_jio_events` (cascade delete) |
| `invitee_id` | uuid | Invited Supabase Auth user id |
| `status` | text | `pending`, `accepted`, or `declined` |
| `updated_at` | timestamp | Last response time |

A row is unique per `(event_id, invitee_id)` pair.

### `jio_chat_messages`

`jio_chat_messages` holds the JioChat group-chat messages for an OpenJio event.
It is enabled for Supabase Realtime so new messages appear live.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `event_id` | uuid | Linked row in `open_jio_events` (cascade delete) |
| `sender_id` | uuid | Sender's Supabase Auth user id |
| `sender_name` | text | Display name captured at send time |
| `content` | text | Message text; null for photo-only messages |
| `image_path` | text | `chat-photos` storage path; null for text-only messages |
| `created_at` | timestamp | Row creation time |

Each message must have either `content` or `image_path` (or both).

### `point_transactions`

`point_transactions` is a ledger of point awards. A user's total points is
the sum of their rows (exposed as the `user_points` view).

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `user_id` | uuid | Who earned the points (cascade delete) |
| `amount` | integer | Points earned |
| `reason` | text | `pin_created`, `photo_uploaded`, or `jio_created` |
| `reference_id` | uuid | Id of the pin/event that earned the points, optional |
| `created_at` | timestamp | Row creation time |

Point values: pinning a place +2, uploading a photo +1 (per photo), a friend accepting an OpenJio invite +5 — defined once in `PointReason` (`lib/models/point_transaction.dart`). each case's `dbValue` must match the `reason` check constraint below.

Pin and photo points are awarded client-side (Supabase insert)right after the underlying action succeeds; failures to award are swallowed so they never block the action itself. Jio points are awarded by the `award_jio_points_on_accept()` trigger on `open_jio_invite_statuses`, since crediting the event's sender needs to bypass the "insert only your own
point_transactions" RLS policy.

### `suggested_place_impressions`

`suggested_place_impressions` logs every "Suggested for You" place shown to a
user, snapshotting the ranking signals at that moment plus whether the user
engaged. It doubles as the training set for the offline logistic-regression
ranker described in `get_friend_recommended_places`.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `user_id` | uuid | Who the suggestion was shown to (cascade delete) |
| `place_id` | uuid | Linked row in `places` (cascade delete) |
| `avg_friend_rating` | numeric | Friends' average rating at the time shown |
| `friend_count` | integer | Distinct friends who'd pinned the place |
| `recency_days` | integer | Days since the most recent friend pin |
| `pin_count` | integer | Global pin count at the time shown |
| `category_match` | boolean | Whether it matched the user's top category |
| `rank_position` | integer | Position in the suggested list (1 = top) |
| `shown_at` | timestamp | When the suggestion was shown |
| `clicked_at` | timestamp | When the user opened it, if ever |
| `saved_at` | timestamp | When the user pinned it, if ever |

`get_friend_recommended_places(p_user_id)` is the Postgres function that
computes these signals per candidate place: friends' average rating, how many
friends pinned it, days since the most recent friend visit, and whether the
place matches the user's most-pinned category. It excludes places the user
already pinned themselves.


## Storage

| Bucket | Visibility | Used by |
|---|---|---|
| `pin-photos` | Private | Pin photos, paths saved in `user_pins.photo_paths` |
| `profile-photos` | Public | Profile avatars, path saved in `profiles.avatar_url` |
| `chat-photos` | Public | JioChat photo messages, path saved in `jio_chat_messages.image_path` |

`pin-photos` behavior:

- A pin can have at most three photos.
- Stored paths are saved in `user_pins.photo_paths`.
- The app creates signed URLs when loading photos (private bucket).
- Friends can read non-private pins' photos through a storage policy.
- Upload cleanup should remove already-uploaded photos if saving the full pin
  fails.

`profile-photos` and `chat-photos` are public buckets, so their files are served
directly by public URL.

> The `pin-photos` and `profile-photos` buckets are created in migration files.
> The `chat-photos` bucket is **not** created by a migration (only its upload
> policy is version-controlled); it currently must exist in the project already.

## Row-Level Security

Row-Level Security (RLS) is enabled on all application tables.

Current policy direction:

- Authenticated users can read all profiles, and update only their own.
- Authenticated users can read all places, and create or update only places they
  created.
- Users can manage their own pins.
- Users can read non-private pins from accepted friends.
- Friendship rows are visible to the requester and addressee; only the addressee
  can accept or block.
- OpenJio events are visible to their creator and to invited users; only the
  creator can insert or delete them.
- Invite statuses are visible to the invitee and the event creator; the creator
  inserts them, and the invitee can update only their own status.
- JioChat messages are readable and writable only by the event creator and
  accepted invitees.

Helper functions used by these policies:

- `public.are_friends(user_a uuid, user_b uuid)` checks whether two users have an
  accepted friendship.
- `public.is_invited_to_open_jio(p_event_id uuid, p_user_id uuid)` checks whether
  a user has an invite status row for an event.
- `public.can_access_jio_chat(p_event_id uuid, p_user_id uuid)` checks whether a
  user is the event creator or an accepted invitee.

Other database automation:

- `update_updated_at()` keeps `updated_at` current on `profiles` and
  `friendships`.
- `sync_place_pin_stats()` maintains `places.pin_count` and auto-approves
  user-created places once enough distinct users have pinned them.
- `award_jio_points_on_accept()` credits an OpenJio event's sender with points when an invitee accepts.

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

`supabase db push` applies migrations straight to the linked project and does
**not** need Docker. Commands that diff against a local shadow database, such as
`supabase db pull` and the local stack (`supabase start`), do need Docker Desktop
running.

Never commit secrets. `supabase/.temp/` and `.env*` files are git-ignored.

## Notes

Some older migrations still mention `pinned_locations`. The current app flow
saves new map data through `places` and `user_pins`.

When changing the schema:

- Add a migration file.
- Update affected Dart models and services.
- Update tests for parsing, validation, or service behavior.
- Update this document when tables, policies, or storage behavior change.
