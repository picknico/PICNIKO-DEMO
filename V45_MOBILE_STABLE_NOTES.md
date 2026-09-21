# PICNIKO V45 — Mobile Stable UI

UI-only stabilization pass based on V44.

- Strict 480px phone shell for module pages even in desktop browser previews.
- No desktop 3-column Messages canvas.
- Messages uses one-screen chat/list states with a fixed bottom mobile navigation.
- Canonical bottom navigation: Home, Discover, Reels, Messages, Profile.
- Reels remains the existing canonical Reels module and existing create/list backend calls are preserved.
- Existing Supabase tables, RPCs, RLS and auth contracts were not modified.
