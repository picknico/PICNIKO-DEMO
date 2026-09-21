# PICNIKO V44 — Mobile First Stable UI

This version is a UI/CSS-only mobile compatibility pass over the existing PICNIKO source.

## Rules preserved
- Existing Supabase tables, RPCs, RLS, Auth contracts and backend JavaScript are not changed.
- Existing canonical modules are preserved; no duplicate Reels/Messages module is created.
- Existing module URLs and relative paths are preserved.

## Mobile behavior
- Phone-first 0–480px shell.
- No desktop dashboard layout on mobile.
- Full-width, no horizontal page overflow.
- Single-column cards/forms where appropriate.
- Bottom navigation stays inside safe area.
- Tables scroll horizontally rather than overlap.
- Modals/sheets fit the phone width.

## Messages
- WhatsApp-style mobile conversation list and full-screen chat.
- Conversation list collapses when a chat is opened.
- Chat header, scrollable message area and composer are separated into fixed vertical regions.
- Composer is kept above the safe-area inset.
- Existing Supabase message loading, send, realtime and location/attachment logic is preserved.
