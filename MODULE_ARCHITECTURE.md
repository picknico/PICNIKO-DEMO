# PICNIKO Modular V2

Every major module has its own HTML entry point under `modules/<module>/<module>.html`.

Home has no shortcut grid. Primary navigation is the bottom tab bar.
Home starts with a Reels-style feed card.

Reels uses a vertical full-screen social-video presentation.

Supabase is provisioned through `js/supabase.js` and `js/config.example.js`.
Actual project URL/anon key must be supplied only after confirming the target Supabase project.
Never place a service-role key in browser code.

Protected Mulshi Fresh QR/reward production logic remains in the original baseline and is not duplicated.


## PICNIKO AI Service
- UI: `modules/ai/ai.html`
- Client adapter: `js/ai-agent.js`
- Public endpoint configuration only: `js/config.js`
- AI secrets must remain server-side (Supabase Edge Function or equivalent).
- The AI agent must use an allow-list of tools/actions for database access.
- Never expose service-role keys, model API keys, database passwords, OTPs or payment credentials in browser code.
- AI should route users to existing modules rather than duplicating module business logic.
