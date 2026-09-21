# PICNIKO V18 - Messages Save Diagnostic Fix

## What changed

- When a logged-in user has no `conversation_members` rows, the Messages module no longer silently falls back to demo conversations.
- Demo messages can no longer appear to be successfully sent as if they were saved in Supabase.
- Backend conversation load errors are surfaced in the UI.
- Text insertion still uses the existing `messages` table and current RLS policies.
- QR/reward and protected files were not changed.

## Important testing condition

For a real message insert test, the logged-in user must belong to an existing row in:

- `public.conversation_members`

The related conversation must exist in:

- `public.conversations`

Only then can the module insert into `public.messages` using the existing RLS policy.
