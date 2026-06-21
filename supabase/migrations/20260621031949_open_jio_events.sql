CREATE TABLE open_jio_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  invited_friend_ids TEXT[] NOT NULL,
  date_time TIMESTAMP NOT NULL,
  caption TEXT NOT NULL,
  location_name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT now()
);

ALTER TABLE open_jio_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can see own events" ON open_jio_events
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own events" ON open_jio_events
  FOR INSERT WITH CHECK (auth.uid() = user_id);