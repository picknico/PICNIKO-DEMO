# PICNIKO AI Agent — server provision

This Edge Function is a safe server-side boundary for the user-facing PICNIKO AI service.

Before activation:
- Choose/approve the AI model/provider.
- Store the provider API key as a server-side secret (`AI_PROVIDER_API_KEY`).
- Implement an allow-listed tool layer for PICNIKO modules.
- Enforce authenticated user/RLS permissions.
- Add rate limits and usage logging.
- Never expose provider keys or Supabase service-role keys to the browser.

No external AI provider is activated by this package.
