# PICNIKO V25 — Messages Automatic User Discovery

## What changed
- Replaced manual recipient UUID entry with automatic PICNIKO user discovery.
- New Chat opens a searchable list of registered users.
- Selecting a user passes the hidden UUID to the existing `create_direct_conversation(uuid)` RPC.
- Existing conversations continue to use the current `conversation_members`, `conversations`, `messages` and Realtime flow.
- No existing table is altered by the package UI change.

## Database step
Run `supabase/sql/PICNIKO_MESSAGES_USER_DISCOVERY_V1.sql` in the reviewed Supabase SQL Editor.

The RPC returns only `user_id`, `full_name`, and `role`, excludes the current user, limits results to 30, and is executable only by authenticated users.

## Test
1. Login with PICNIKO account A.
2. Messages → `+`.
3. Registered PICNIKO users should appear automatically.
4. Search/select account B.
5. The existing direct-conversation RPC creates or reuses the chat.
6. Send a message and verify it is saved in `public.messages`.
7. Login as B and confirm the conversation/message appears.
