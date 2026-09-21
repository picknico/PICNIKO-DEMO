# PICNIKO V12 — Functional Integration Preparation

## Scope
This package prepares the project for controlled backend integration without changing the protected QR/reward foundation.

## Completed in this preparation
- Preserved the existing V10 modular source.
- Preserved Supabase configuration files.
- Preserved Reels and Messages UI foundations.
- Added an integration checklist and data-contract requirements.
- No destructive SQL was executed.
- No Git commit or push was performed.

## Required implementation order
1. Confirm the exact Supabase tables and columns for direct messages.
2. Create reviewed RLS migration for conversations, participants, messages, reactions, attachments, blocks and favorites.
3. Add a browser-safe messaging adapter using the publishable key only.
4. Connect text-message send/load and unread/seen state.
5. Add Storage upload policies for photo/video/document/voice files.
6. Connect Reels comments to the existing social schema.
7. Test mobile keyboard, scroll, permissions and error states.
8. Only after review, add calling infrastructure using WebRTC/signaling.

## Important boundary
The current UI must not be described as production-live until the corresponding Supabase tables, RLS policies, Storage policies and end-to-end tests are completed.
