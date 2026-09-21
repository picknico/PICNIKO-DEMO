# PICNIKO V31 — Smart Campaign Studio

Premium UI foundation for one campaign workflow across PICNIKO, Google Ads and Meta Ads.

## Included
- Campaign creation flow
- Objective picker
- Audience builder
- Creative preview
- Channel connection UI
- Unified analytics UI
- PICNIKO campaign wallet UI
- Additive Supabase schema for campaigns/accounts/channels

## Safety / integration boundary
Google/Meta OAuth and campaign publishing are intentionally connection placeholders until provider credentials, redirect URIs, scopes, account IDs and approval are configured. Never put provider client secrets or access tokens in frontend code.

## SQL
Run `supabase/sql/PICNIKO_V31_DIGITAL_MARKETING_PROVISION.sql` only after reviewing the existing schema/RLS in the target Supabase project. It is additive and does not modify the existing messaging/home/explore tables.
