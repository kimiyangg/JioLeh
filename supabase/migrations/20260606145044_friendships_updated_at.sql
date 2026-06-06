create trigger friendships_updated_at
  before update on public.friendships
  for each row execute function public.update_updated_at();
