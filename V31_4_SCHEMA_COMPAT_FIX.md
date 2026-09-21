# V31.4 Schema Compatibility Fix

Fixes Campaign Wizard save against the existing `ad_campaigns` schema.

Existing columns preserved: `campaign_name`, `campaign_type`, `budget`, `daily_budget`, `created_by`, `owner_user_id`.
Additive columns: `audience`, `creative`, `currency`.

Frontend now writes `campaign_name` / `campaign_type` instead of non-existent `name` / `objective`.
