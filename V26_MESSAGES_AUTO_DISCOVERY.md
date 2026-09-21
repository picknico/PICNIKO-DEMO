# PICNIKO V26 — Messages Auto Discovery V2

- Replaces UUID/manual recipient discovery with registered Supabase Auth account discovery.
- Uses a security-definer RPC; browser receives only `user_id`, safe display name and role.
- Email addresses are not returned to the client.
- Direct conversation creation now verifies the recipient against `auth.users` and creates/reuses the two-member conversation.
- Existing Messages tables and existing data are preserved; no DROP/TRUNCATE/DELETE operations.
- Run `supabase/sql/PICNIKO_MESSAGES_AUTO_DISCOVERY_V2.sql` in the PICNIKO Supabase SQL Editor.
