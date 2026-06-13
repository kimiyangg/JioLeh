--Store photo storage paths on each pin (mirrors the old pinned_locations.photo_paths)
alter table public.user_pins
add column photo_paths text[] not null default '{}';

--Keep the 3-photos-per-pin limit consistent with the app
alter table public.user_pins
add constraint user_pins_max_three_photos
check (cardinality(photo_paths) <= 3);

--Match the application's 500-character review limit
alter table public.user_pins
add constraint user_pins_review_length_check
check (char_length(reviews) <= 500);
