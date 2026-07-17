-- Reusable content for usability tests and demos. The Flutter app can only
-- opt the signed-in user in; it cannot create or impersonate demo accounts.

create table public.demo_community_bots (
  profile_id uuid primary key references public.profiles(id) on delete cascade,
  display_order smallint not null unique check (display_order between 1 and 3)
);

create table public.demo_community_enrolments (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.demo_community_bots enable row level security;
alter table public.demo_community_enrolments enable row level security;

create policy "Users can see their demo enrolment"
  on public.demo_community_enrolments for select to authenticated
  using (user_id = auth.uid());

-- Before using this function, create three normal Auth users for the demo
-- personas, complete their profiles, then register their profile IDs:
-- insert into public.demo_community_bots (profile_id, display_order) values
--   ('<first-demo-profile-id>', 1),
--   ('<second-demo-profile-id>', 2),
--   ('<third-demo-profile-id>', 3);
--
-- The enrolment row makes this function idempotent: a tester can never receive
-- duplicate friendships, pins, events, or messages by tapping the option twice.
create or replace function public.join_demo_community()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  first_bot_id uuid;
  bot record;
  place_ids uuid[] := array[]::uuid[];
  new_place_id uuid;
  event_id uuid;
begin
  if current_user_id is null then
    raise exception 'You must be signed in to join the demo community.';
  end if;

  if not exists (select 1 from public.profiles where id = current_user_id) then
    raise exception 'Create your profile before joining the demo community.';
  end if;

  if (select count(*) from public.demo_community_bots) <> 3 then
    raise exception 'The demo community has not been configured yet.';
  end if;

  insert into public.demo_community_enrolments (user_id)
  values (current_user_id)
  on conflict (user_id) do nothing;

  if not found then
    return;
  end if;

  for bot in
    select profile_id, display_order
    from public.demo_community_bots
    order by display_order
  loop
    insert into public.friendships (requester_id, addressee_id, status)
    values (bot.profile_id, current_user_id, 'accepted')
    on conflict do nothing;

    insert into public.places (name, category, latitude, longitude, provider, created_by)
    values (
      case bot.display_order
        when 1 then 'Demo Coffee Corner'
        when 2 then 'Demo Study Spot'
        else 'Demo Sunset Walk'
      end,
      case bot.display_order
        when 1 then chr(9749)
        when 2 then chr(128218)
        else chr(127751)
      end,
      case bot.display_order when 1 then 1.2966 when 2 then 1.3002 else 1.2928 end,
      case bot.display_order when 1 then 103.7764 when 2 then 103.7721 else 103.7815 end,
      'demo',
      bot.profile_id
    ) returning id into new_place_id;

    place_ids := array_append(place_ids, new_place_id);

    insert into public.user_pins
      (user_id, place_id, custom_name, emoji, visibility, is_private, ratings, reviews)
    values (
      bot.profile_id,
      new_place_id,
      case bot.display_order
        when 1 then 'A cosy place for coffee and catching up'
        when 2 then 'Quiet tables and reliable Wi-Fi'
        else 'Best place for an evening stroll'
      end,
      case bot.display_order
        when 1 then chr(9749)
        when 2 then chr(128218)
        else chr(127751)
      end,
      'friends',
      false,
      case bot.display_order when 2 then 4 else 5 end,
      case bot.display_order
        when 1 then 'Try the iced latte after 3 pm.'
        when 2 then 'Great for a focused afternoon session.'
        else 'Go just before sunset for the best view.'
      end
    );

    if bot.display_order = 1 then
      first_bot_id := bot.profile_id;
    end if;
  end loop;

  insert into public.open_jio_events
    (user_id, date_time, caption, location_name, place_id)
  values (
    first_bot_id,
    now() + interval '2 days',
    'Demo coffee catch-up',
    'Demo Coffee Corner',
    place_ids[1]
  ) returning id into event_id;

  insert into public.open_jio_invite_statuses (event_id, invitee_id, status)
  values (event_id, current_user_id, 'pending');

  insert into public.jio_chat_messages (event_id, sender_id, sender_name, content)
  select event_id, p.id, p.display_name,
    case b.display_order
      when 1 then 'I found a nice place for us to catch up!'
      when 2 then 'I can make it after class.'
      else 'Looking forward to it!'
    end
  from public.demo_community_bots b
  join public.profiles p on p.id = b.profile_id;

  insert into public.open_jio_invite_statuses (event_id, invitee_id, status)
  select event_id, profile_id, 'accepted'
  from public.demo_community_bots
  where profile_id <> first_bot_id;
end;
$$;

revoke all on function public.join_demo_community() from public;
grant execute on function public.join_demo_community() to authenticated;
