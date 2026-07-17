-- One row per grid cell a user has physically visited. The cell is a fixed
-- fraction of a degree wide (computed app-side), stored as integer tile
-- coordinates. Visiting a cell is a permanent fact: rows are inserted, never
-- updated or deleted, so there is no update/delete policy.
create table public.explored_tiles (
  user_id     uuid        not null references public.profiles(id) on delete cascade,
  tile_x      integer     not null,
  tile_y      integer     not null,
  explored_at timestamptz not null default now(),

  primary key (user_id, tile_x, tile_y)
);

alter table public.explored_tiles enable row level security;

create policy "users can insert their own explored tiles"
on public.explored_tiles for insert
to authenticated
with check (user_id = auth.uid());

create policy "users can read their own explored tiles"
on public.explored_tiles for select
to authenticated
using (user_id = auth.uid());
