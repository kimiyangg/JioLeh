-- Aggregates each candidate place's friend signals for the current user:
-- how many friends pinned it, their average rating, how long ago the most
-- recent friend visited, and whether it matches the categories the user
-- pins most. Excludes places the user already pinned themselves.
create or replace function public.get_friend_recommended_places(p_user_id uuid)
returns table (
  place_id uuid,
  name text,
  category text,
  latitude double precision,
  longitude double precision,
  avg_friend_rating numeric,
  friend_count integer,
  recency_days integer,
  pin_count integer,
  category_match boolean
)
language sql
security definer
set search_path = public
stable
as $$
  with my_top_category as (
    select pl.category
    from public.user_pins pin
    join public.places pl on pl.id = pin.place_id
    where pin.user_id = p_user_id and pl.category is not null
    group by pl.category
    order by count(*) desc
    limit 1
  ),
  friend_signals as (
    select
      pl.id as place_id,
      pl.name,
      pl.category,
      pl.latitude,
      pl.longitude,
      pl.pin_count,
      avg(pin.ratings)::numeric as avg_friend_rating,
      count(distinct pin.user_id) as friend_count,
      extract(day from now() - max(pin.created_at))::integer as recency_days
    from public.user_pins pin
    join public.places pl on pl.id = pin.place_id
    where public.are_friends(p_user_id, pin.user_id)
      and pin.is_private is not true
      and pin.ratings is not null
      and not exists (
        select 1 from public.user_pins mine
        where mine.user_id = p_user_id and mine.place_id = pl.id
      )
    group by pl.id, pl.name, pl.category, pl.latitude, pl.longitude, pl.pin_count
  )
  select
    fs.place_id,
    fs.name,
    fs.category,
    fs.latitude,
    fs.longitude,
    fs.avg_friend_rating,
    fs.friend_count,
    fs.recency_days,
    fs.pin_count,
    (fs.category = (select category from my_top_category)) as category_match
  from friend_signals fs;
$$;

grant execute on function public.get_friend_recommended_places(uuid) to authenticated;

-- Snapshots the feature values shown to a user at suggestion time, plus
-- whether they engaged. This table is the training set for the offline
-- model — no joins needed at export time.
create table public.suggested_place_impressions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  place_id uuid not null references public.places(id) on delete cascade,
  avg_friend_rating numeric,
  friend_count integer not null default 0,
  recency_days integer,
  pin_count integer not null default 0,
  category_match boolean not null default false,
  rank_position integer not null,
  shown_at timestamptz not null default now(),
  clicked_at timestamptz,
  saved_at timestamptz
);

create index suggested_place_impressions_user_id_idx
on public.suggested_place_impressions (user_id);

alter table public.suggested_place_impressions enable row level security;

create policy "users can insert their own impressions"
on public.suggested_place_impressions for insert
to authenticated
with check (user_id = auth.uid());

create policy "users can update their own impressions"
on public.suggested_place_impressions for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users can read their own impressions"
on public.suggested_place_impressions for select
to authenticated
using (user_id = auth.uid());
