# PICNIKO V13 — Messages Backend Slice

## What changed
- Added a narrow Supabase-backed read path for `conversations`, `conversation_members`, and `messages`.
- Loads conversations for the currently authenticated user.
- Loads text/media message records visible under the existing RLS policies.
- Sends text messages to `public.messages` with the authenticated user's ID.
- Keeps the existing local demo fallback when authentication or Supabase data is unavailable.
- Keeps QR/reward logic and protected files unchanged.

## Important limits
- This is not a complete WhatsApp clone yet.
- Conversation creation, contact search, unread/read receipts, Storage uploads, realtime subscriptions, voice/video calls, and WebRTC are not included in this slice.
- The UI needs to be opened through Live Server, not by double-clicking the HTML file.
- A valid authenticated PICNIKO session is required for live data to appear.

## Test checklist
1. Open the project root using VS Code Live Server.
2. Sign in through the existing PICNIKO login flow.
3. Open Messages.
4. Confirm existing member conversations load.
5. Send a short text message.
6. Verify the new row appears in Supabase `public.messages`.
7. If a message fails, copy the visible error and send it for review.
