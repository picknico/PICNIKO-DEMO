# PICNIKO V19 — Messages real-backend-only behavior

- Demo conversations are no longer shown after a logged-in user is detected.
- The module checks `conversation_members` for the logged-in user.
- If no membership exists, the UI clearly reports that no backend conversation is assigned.
- Text insertion is attempted only for a real backend conversation.
- No SQL migration was added.
- QR/reward protected files were not modified.

## Next required backend step

Create/assign a real conversation and add the logged-in user to `conversation_members` using an approved, reviewed database operation.
