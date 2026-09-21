# PICNIKO V32 Backend Integration

This increment preserves the existing V31.5 codebase and adds backend-connected workflows for:

- Reels: upload video to `reel-media`, publish, feed, like, save, comments.
- Groups: create group, auto-owner membership, join, read posts, create posts.
- Connect: uses the existing production `friend_requests` table and existing RPCs `send_friend_request`, `respond_friend_request`, `get_friend_status`; no `picniko_connections` table is introduced.
- News: read published news and bookmark/unbookmark.
- Marketplace: browse, search, create listing, favourite and seller inquiry.

## Database migration

Run exactly:

`supabase/sql/PICNIKO_V32_REELS_GROUP_CONNECT_NEWS_MARKETPLACE.sql`

It is additive and does not drop or alter the existing protected QR/reward/messenger foundation.

## Important production boundary

The browser continues to use only the Supabase publishable/anon key. No service-role key is placed in frontend code.

The external Google/Meta advertising APIs are not faked by this migration. Their secure OAuth/API publishing remains a separate server-side integration step.

## Verification checklist

1. Run the V32 SQL migration in the Supabase SQL Editor.
2. Login with a real PICNIKO account.
3. Reels: upload -> publish -> refresh -> like/save/comment.
4. Groups: create -> join from another account -> post.
5. Connect: search -> request -> accept from recipient -> open Messages.
6. News: published rows appear -> bookmark.
7. Marketplace: create listing -> browse/search from another account -> favourite -> inquiry.
8. Check RLS with two different accounts before production deployment.
