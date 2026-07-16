-- Policies needed for hosts to edit their jios:
-- 1. Owners can update their own event rows (no UPDATE policy existed at all).
-- 2. Senders can remove invitees' status rows when un-inviting during an edit.

CREATE POLICY "Users can update own events" ON open_jio_events
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Senders can delete statuses for their events" ON open_jio_invite_statuses
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM open_jio_events
      WHERE id = event_id AND user_id = auth.uid()
    )
  );
