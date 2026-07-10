create table public.point_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  amount integer not null,
  reason text not null check (reason in ('pin_created', 'photo_uploaded', 'jio_created')),
  reference_id uuid,
  created_at timestamptz not null default now()
);

create index point_transactions_user_id_idx on public.point_transactions(user_id);

alter table public.point_transactions enable row level security;

create policy "point_transactions are readable by authenticated users"
  on public.point_transactions for select
  to authenticated
  using (true);

create policy "users can insert their own point transactions"
  on public.point_transactions for insert
  to authenticated
  with check (user_id = auth.uid());

create view public.user_points as
  select user_id, coalesce(sum(amount), 0) as points
  from public.point_transactions
  group by user_id;
