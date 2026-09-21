# PICNIKO V27 — Social Graph + Communication Foundation

## Purpose
Move PICNIKO from isolated/basic module UI toward one shared identity + relationship + content-ranking layer.

## Included
- Advanced people discovery: name/city/role search.
- Friend/connection request lifecycle: pending, accept, decline, accepted.
- Role-aware discovery for Student/Teacher/Professional/Employee/Creator/Business/Civic/Public users where role data exists in profiles.
- Ranked feed foundation using relationship, locality, role relevance, freshness and engagement.
- Content impression/like/comment/share/save event foundation.
- Reels module reads ranked database content instead of only hardcoded cards.
- Existing Messages module and protected QR/Reward foundation preserved.

## Database
Run `supabase/sql/PICNIKO_SOCIAL_GRAPH_V1.sql` in Supabase SQL Editor after review.
It is additive and does not alter existing QR/reward/messaging tables.

## Important
This package is code-wired; it is not a claim that the live Supabase database has been changed or live-tested. Run the SQL, then test with authenticated accounts.
