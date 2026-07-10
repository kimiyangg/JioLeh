-- The Friends page subscribes to these tables for live updates (incoming
-- friend requests and leaderboard point changes). Postgres only broadcasts
-- realtime changes for tables in the supabase_realtime publication.
alter publication supabase_realtime add table public.friendships;
alter publication supabase_realtime add table public.point_transactions;
