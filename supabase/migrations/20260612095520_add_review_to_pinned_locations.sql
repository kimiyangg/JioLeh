-- Add reviews to pinned locations.
alter table public.pinned_locations
add column review text not null default '';

-- Keep reviews consistent with the application's 500-character limit.
alter table public.pinned_locations
add constraint pinned_locations_review_length_check
check (char_length(review) <= 500);