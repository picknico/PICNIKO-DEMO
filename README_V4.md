# PICNIKO Modular V3 — Home/Reels Foundation

This package keeps the separate-HTML module architecture and the protected baseline files.

## Current UI foundation
- Mobile-first app shell
- Primary bottom navigation: Home | Nearby | + | Shop | Profile
- Home has no shortcut grid
- Home opens with an Instagram-style reel card
- Dedicated Reels / Shorts module
- Create sheet from the center `+`
- Shared CSS/JS

## Supabase provision
- `js/supabase.js` is the shared client boundary.
- `js/config.js` contains placeholders for the public Supabase URL and anon key.
- Supabase JS v2 is loaded from CDN in the Home module.
- No service-role key or database password belongs in browser code.
- Real project connection is intentionally not claimed until the correct project URL + anon key are supplied.

## Protected files
Do not modify the protected baseline or QR definition without explicit approval:
- `PICNIKO_10U2_SUPER_HOME_ROLLBACK.html`
- `PICNIKO_SCAN_BOTTLE_DEFINITION.txt`

## No Blockchain runtime
Blockchain is not part of this current architecture.


## V4 AI Agent
A user-facing PICNIKO AI service module and server-side Edge Function provision are included. No AI provider secret is embedded or activated.
