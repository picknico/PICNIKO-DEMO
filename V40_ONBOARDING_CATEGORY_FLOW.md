# PICNIKO V40 — Login → Category → Home

This is an additive UI/onboarding layer. Existing modules and Supabase schema are preserved.

Flow:
1. Root index → auth/login.html
2. Successful login / demo entry → onboarding/category.html
3. User chooses a primary category
4. Choice is stored locally as `picniko_category` for demo personalization
5. Continue → existing canonical modules/home/home.html

No database migration is included. Production persistence of the selected category should be added only after verifying the existing profiles schema.
