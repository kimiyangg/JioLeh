-- Enable RLS on the chat messages table
ALTER TABLE public.jio_chat_messages ENABLE ROW LEVEL SECURITY;

-- Helper function: is the current user an accepted member of this event?
-- "accepted member" = the creator OR an invitee who accepted.
-- We use security definer (like your existing is_invited_to_open_jio)
-- so the function can read the tables without triggering RLS on them.
CREATE OR REPLACE FUNCTION public.can_access_jio_chat(p_event_id uuid, p_user_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    -- The user created the event
    SELECT 1 FROM public.open_jio_events
    WHERE id = p_event_id AND user_id = p_user_id
  )
  OR EXISTS (
    -- The user accepted the invite
    SELECT 1 FROM public.open_jio_invite_statuses
    WHERE event_id = p_event_id
      AND invitee_id = p_user_id
      AND status = 'accepted'
  );
$$;

GRANT EXECUTE ON FUNCTION public.can_access_jio_chat(uuid, uuid) TO authenticated;

-- Policy 1: Who can READ messages?
-- Only people who pass the can_access_jio_chat check.
CREATE POLICY "Chat members can read messages"
  ON public.jio_chat_messages
  FOR SELECT
  USING (public.can_access_jio_chat(event_id, auth.uid()));

-- Policy 2: Who can SEND (INSERT) messages?
-- Must pass the access check AND the sender_id must be the current user
-- (prevents someone inserting a message pretending to be someone else).
CREATE POLICY "Chat members can send messages"
  ON public.jio_chat_messages
  FOR INSERT
  WITH CHECK (
    sender_id = auth.uid()
    AND public.can_access_jio_chat(event_id, auth.uid())
  );

-- Enable Realtime so the Flutter app receives new messages live.
ALTER PUBLICATION supabase_realtime ADD TABLE public.jio_chat_messages;
ALTER TABLE public.jio_chat_messages REPLICA IDENTITY FULL;
