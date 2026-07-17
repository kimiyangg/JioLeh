-- Auto-delete jios 24 hours after their event time. Runs hourly as the
-- postgres role (table owner, so RLS does not block it); ON DELETE CASCADE
-- clears invite statuses and chat messages with the event.

create extension if not exists pg_cron;

select cron.schedule(
  'delete-expired-open-jios',
  '0 * * * *',
  $$ delete from public.open_jio_events where date_time < now() - interval '24 hours' $$
);
