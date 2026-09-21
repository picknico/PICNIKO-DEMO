# PICNIKO V27 — Advanced Messages UI Upgrade

## Purpose
Upgrade the existing V27 Messages module to a premium, multi-panel social communication UI inspired by the approved PICNIKO visual direction.

## Existing functionality preserved
- Existing Supabase conversation loading
- Existing message insert flow
- Existing realtime message subscription
- Existing attachment/demo controls
- Existing user discovery flow
- Existing Social Graph SQL and RPC contracts
- Existing QR, reward, authentication and other modules

## UI upgrade
- Dark blue / cyan premium PICNIKO visual system
- 3-panel desktop layout: conversations / active chat / People & Connect
- Persistent People & Connect rail
- Discover / Friends / Requests filters
- Relationship-aware Connect / Request Sent / Accept / Friend states
- Direct Message action for accepted friends
- Responsive mobile fallback

## Database changes
NONE.

The UI is aligned to the live additive `friend_requests` contract: `discover_message_users`, `send_friend_request`, `respond_friend_request`, and `get_or_create_direct_conversation`. The existing messaging tables and their RLS are preserved. The UI does not silently create or alter database objects.
