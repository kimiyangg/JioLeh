alter table public.user_pins
add column ai_tags text[] not null default '{}';