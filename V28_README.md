# PICNIKO V28 Complete Messenger

This package upgrades the existing V27 Messages UI without rebuilding the existing foundation.

## Included
- Premium responsive Messages UI
- File / image / video / audio attachment picker and Supabase Storage upload
- Attachment preview/rendering
- Current location sharing
- Live location sharing (15 min / 1 hour / 8 hours)
- Delivered / seen cursor support via conversation read state
- Unread badges and chat-list previews
- Realtime-compatible location tables
- Travel-first quick actions

## Database
Run `supabase/sql/PICNIKO_V28_MESSENGER_COMPLETE.sql` once in Supabase SQL Editor.

The migration is additive and does not drop/rename the existing `messages`, `conversations`, `conversation_members`, or `friend_requests` tables.
