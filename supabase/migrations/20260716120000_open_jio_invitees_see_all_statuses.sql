-- Let any invitee of an event see every invitee's status for that event
-- (not just their own), so the app can show "who's going" on a jio card.
-- Superseded by is_invited_to_open_jio: if you're invited to the event at
-- all, you can see the full status list for it.

DROP POLICY "Invitees can see their statuses" ON open_jio_invite_statuses;

CREATE POLICY "Invitees can see all statuses for their events" ON open_jio_invite_statuses
  FOR SELECT USING (public.is_invited_to_open_jio(event_id, auth.uid()));
