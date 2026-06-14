-- Treat an unrated pin as null instead of 0.
update public.user_pins
set ratings = null
where ratings = 0;

alter table public.user_pins
drop constraint if exists user_pins_ratings_check;

alter table public.user_pins
add constraint user_pins_ratings_check
check (ratings is null or ratings between 1 and 5);
