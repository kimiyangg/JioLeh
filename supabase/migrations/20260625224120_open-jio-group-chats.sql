create table public.jio_chat_messages (
  id          uuid primary key default gen_random_uuid(),
  event_id    uuid not null references public.open_jio_events(id) on delete cascade,
  sender_id   uuid not null references auth.users(id) on delete cascade,
  sender_name text not null,
  content     text,
  image_path  text,
  created_at  timestamptz not null default now(),

  constraint must_have_content_or_image
    check (content is not null or image_path is not null)
);
