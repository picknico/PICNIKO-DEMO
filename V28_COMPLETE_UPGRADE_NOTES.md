# PICNIKO V28 Complete Messenger Upgrade

## Scope
This build keeps the existing V27 Friends/Connect/Conversation/Messages architecture and adds an additive messenger experience.

### Included
- Premium responsive Messages UI
- Text messaging with realtime INSERT handling
- Delivered / Seen UI based on conversation read cursors
- Unread counts based on `conversation_members.last_read_at`
- Search/filter for chats
- Image, video, audio and document attachments
- Private Supabase Storage bucket: `message-media`
- Signed URLs for private media playback
- Upload progress and 50 MB per-file validation
- Real voice-message recording with MediaRecorder where supported
- One-time current location sharing
- Live location sharing: 15 min / 1 hour / 8 hours
- Live location stop control
- Realtime live-location coordinate updates
- Open-map action
- Travel-first quick actions
- Mobile responsive layout

## Database
The existing V28 SQL remains additive. A V28.1 section adds `live_locations.message_id` and an index so live location updates can follow the exact chat message.

## Safety / preservation
No existing protected tables are dropped or renamed. Existing `friend_requests`, `conversations`, `conversation_members`, and `messages` are preserved.

## Browser requirements
- HTTPS (or localhost) for geolocation and microphone permissions.
- A modern browser for MediaRecorder, Geolocation and Supabase JS v2.
- User must grant the relevant browser permission.

## Test checklist
1. Login with two PICNIKO users.
2. Connect -> Accept -> Friends -> Message.
3. Send text from User A; verify User B receives it realtime.
4. Open chat on User B; verify User A changes from Delivered to Seen after refresh/reload.
5. Verify unread count appears when the recipient is not viewing the chat.
6. Attach image/video/audio/PDF and verify upload, persistence and playback/download UI.
7. Record a voice message and verify it appears as an audio player.
8. Send current location and open the map.
9. Start live location, verify the live card updates, then stop sharing.
10. Test mobile layout and attachment/location sheets.
