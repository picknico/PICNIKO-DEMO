# PICNIKO V42 — Mobile App Compatibility

- UI-only mobile compatibility layer added through `css/mobile-app.css`.
- Existing Supabase client, RPC calls, tables, RLS and backend JS contracts were not changed.
- Existing modules remain canonical; no duplicate module was created.
- Home remains the V41 social-first shell.
- Login was redesigned as a mobile-first app screen with Email/Auth and Facebook OAuth entry.
- Username-only authentication is intentionally not faked: current verified Auth contract supports email/password and phone OTP; a true username/PICNIKO-ID login requires a secure identifier-to-email/auth mapping backend change, which is not included because backend connectivity was explicitly protected.
- All module HTML pages receive the compatibility stylesheet for narrow/mobile screens.
