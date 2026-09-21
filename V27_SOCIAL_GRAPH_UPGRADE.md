# PICNIKO V27 — Social Graph / Communication Foundation

## Purpose
Upgrade the basic Social module into a production-oriented relationship and communication foundation without replacing the existing PICNIKO foundation.

## Included
- People discovery by name/city/role.
- Friend request state machine: Connect, Pending, Incoming, Accept, Decline, Friends.
- Secure server-side RPCs for relationship changes.
- Relationship list and request inbox.
- Direct-message entry point for accepted connections.
- Content item + event foundation for personalized ranking.
- Ranked feed RPC using relationship signal, local signal, personal engagement and freshness.
- Existing Messages, QR/reward and other modules preserved.

## Database
Run `supabase/sql/PICNIKO_SOCIAL_GRAPH_V1.sql` once in Supabase SQL Editor.
The migration is additive and does not modify or delete existing QR/reward/messaging tables.

## Important
The package is code-ready but live Supabase execution must be performed in the user's project. After SQL installation, test with two real accounts: A sends request -> B accepts -> A/B open Messages.
