create or replace function public.is_invited_to_open_jio(p_event_id uuid, p_user_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from open_jio_invite_statuses s
    where s.event_id = p_event_id and s.invitee_id = p_user_id
  );
$$;

grant execute on function public.is_invited_to_open_jio(uuid, uuid) to authenticated;

drop policy "Invited users can see events" on open_jio_events;

create policy "Invited users can see events" on open_jio_events
  for select using (public.is_invited_to_open_jio(id, auth.uid()));
