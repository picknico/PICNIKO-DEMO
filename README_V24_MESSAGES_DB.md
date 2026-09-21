# PICNIKO V24 — Messages database connection

## What changed
Only the Messages module was extended from V23.

- Real `conversation_members` → `conversations` → `messages` loading remains intact.
- Added a controlled `create_direct_conversation(uuid)` RPC SQL file.
- New Chat can call that RPC with a verified recipient user UUID.
- Existing direct conversation is reused when the same two-member direct chat already exists.
- No existing table is altered or dropped.
- No QR/reward logic is touched.

## Required database step
The SQL file `supabase/sql/PICNIKO_MESSAGES_PROVISION_V1.sql` must be reviewed against the live Supabase schema and then executed in the Supabase SQL editor. This package does not claim that the live database was changed.

After execution:
1. Login to PICNIKO.
2. Open Messages.
3. Press `+`.
4. Enter another PICNIKO user's UUID.
5. `Create / Open Chat` calls the RPC.
6. The new/reused conversation appears in the real conversation list.
7. Send a text message; it is inserted into `public.messages` and appears through Realtime when enabled.

The existing RLS model remains the data-access boundary: conversation membership controls conversation/message reads, and a sender can insert only as `auth.uid()` for a conversation they belong to.
