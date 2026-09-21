# PICNIKO V27 — Live Database Alignment

## Current live Social Graph contract
The live Supabase project was provisioned with the additive `friend_requests` relationship layer and these RPCs:

- `discover_message_users(text)`
- `send_friend_request(uuid)`
- `respond_friend_request(uuid,text)`
- `cancel_friend_request(uuid)`
- `get_friend_status(uuid)`
- `get_or_create_direct_conversation(uuid)`

The V27 Messages UI is aligned to these live contracts. It does **not** assume `picniko_connections` or `create_direct_conversation`.

## Preserved existing messaging foundation
- `profiles`
- `conversations`
- `conversation_members`
- `messages`
- existing RLS and Realtime message flow

## End-to-end flow
Discover → Connect → Request Sent → Accept → Friends → Message → Direct Conversation → Messages → Realtime

No existing QR/reward/authentication foundation is changed by the UI patch.
