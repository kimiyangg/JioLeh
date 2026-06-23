-- Allow invited users to read events they were invited to
CREATE POLICY "Invited users can see events" ON open_jio_events
  FOR SELECT USING (auth.uid()::text = ANY(invited_friend_ids));

-- Tracks per-invitee accept/decline status for each event
CREATE TABLE open_jio_invite_statuses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES open_jio_events(id) ON DELETE CASCADE,
  invitee_id UUID NOT NULL REFERENCES auth.users(id),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
  updated_at TIMESTAMP DEFAULT now(),
  UNIQUE(event_id, invitee_id)
);

ALTER TABLE open_jio_invite_statuses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Invitees can see their statuses" ON open_jio_invite_statuses
  FOR SELECT USING (auth.uid() = invitee_id);

CREATE POLICY "Senders can see statuses for their events" ON open_jio_invite_statuses
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM open_jio_events
      WHERE id = event_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "Senders can insert statuses" ON open_jio_invite_statuses
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM open_jio_events
      WHERE id = event_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "Invitees can update their status" ON open_jio_invite_statuses
  FOR UPDATE USING (auth.uid() = invitee_id)
  WITH CHECK (status IN ('accepted', 'declined'));

-- Enable realtime so invited users get live notifications
ALTER PUBLICATION supabase_realtime ADD TABLE open_jio_invite_statuses;
ALTER TABLE open_jio_invite_statuses REPLICA IDENTITY FULL;
