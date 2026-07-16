-- The function creates relationships and sample content, so only signed-in
-- users may invoke it. Explicitly revoke from anon because project-level role
-- grants can otherwise leave the function reachable through the REST RPC API.
revoke execute on function public.join_demo_community() from anon;
grant execute on function public.join_demo_community() to authenticated;
