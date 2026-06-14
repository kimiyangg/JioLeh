--When the place was first added
alter table public.places
add column created_at timestamp with time zone not null default now();

--When the provider data was last refreshed (for the cache)
alter table public.places
add column refreshed_at timestamp with time zone;

--Two strangers pinning the same provider place should share one row
create unique index places_provider_uniq
on public.places (provider, provider_place_id)
where provider_place_id is not null;

--Speed up nearby and map lookups
create index places_lat_lng_idx
on public.places (latitude, longitude);
