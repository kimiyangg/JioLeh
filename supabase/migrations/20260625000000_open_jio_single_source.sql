-- Make open_jio_invite_statuses the single source of truth for "who is invited".
-- Drops the redundant open_jio_events.invited_friend_ids array (fixes H2: two
-- sources of truth that could drift out of sync).

-- 1. Backfill: guarantee every id in the array already has a status row, so
--    dropping the array cannot lose an invitee that drifted out of sync.
INSERT INTO open_jio_invite_statuses (event_id, invitee_id, status)
SELECT e.id, uid::uuid, 'pending'
FROM open_jio_events e, unnest(e.invited_friend_ids) AS uid
ON CONFLICT (event_id, invitee_id) DO NOTHING;

-- 2. Repoint the "invited users can see events" policy off the array and onto
--    the status table. Must happen before the column is dropped (it depends on it).
DROP POLICY "Invited users can see events" ON open_jio_events;

CREATE POLICY "Invited users can see events" ON open_jio_events
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM open_jio_invite_statuses s
      WHERE s.event_id = open_jio_events.id AND s.invitee_id = auth.uid()
    )
  );

-- 3. Indexes to keep the new EXISTS policy and the sent/received reads fast.
CREATE INDEX IF NOT EXISTS open_jio_invite_statuses_invitee_event_idx
  ON open_jio_invite_statuses (invitee_id, event_id);
CREATE INDEX IF NOT EXISTS open_jio_events_user_created_idx
  ON open_jio_events (user_id, created_at DESC);

-- 4. Drop the now-redundant array.
ALTER TABLE open_jio_events DROP COLUMN invited_friend_ids;
