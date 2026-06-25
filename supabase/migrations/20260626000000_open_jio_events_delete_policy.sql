-- Let owners delete their own events so saveEvent's compensating rollback works
-- (previously denied by RLS, leaving orphaned events when the status insert failed).
CREATE POLICY "Users can delete own events" ON open_jio_events
  FOR DELETE USING (auth.uid() = user_id);
