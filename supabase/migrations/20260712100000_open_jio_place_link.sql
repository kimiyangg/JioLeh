-- Link an Open Jio event to a registered place. Nullable so free-text locations stay name-only; if the place is ever deleted the event falls back to its stored location_name.
alter table public.open_jio_events
add column place_id uuid references public.places(id) on delete set null;
