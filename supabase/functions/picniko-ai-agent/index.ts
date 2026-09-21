import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  try {
    const body = await req.json();
    const message = String(body?.message || "").trim();
    if (!message) {
      return new Response(JSON.stringify({ error: "message_required" }), {
        status: 400, headers: { ...cors, "Content-Type": "application/json" }
      });
    }

    // Production rule:
    // 1) Authenticate the Supabase user.
    // 2) Apply PICNIKO tool allow-list/RLS checks.
    // 3) Call the chosen AI model using a SERVER-SIDE secret.
    // 4) Return only the minimum safe response.
    //
    // Do NOT put an AI provider key in browser code.
    const configured = Boolean(Deno.env.get("AI_PROVIDER_API_KEY"));
    if (!configured) {
      return new Response(JSON.stringify({
        reply: "PICNIKO AI server is provisioned but not activated yet. Add the approved AI provider secret on the server, then connect the allow-listed PICNIKO tools."
      }), {
        headers: { ...cors, "Content-Type": "application/json" }
      });
    }

    // Provider call intentionally left as an adapter boundary.
    // This avoids locking PICNIKO to one vendor before the model/provider is approved.
    return new Response(JSON.stringify({
      reply: "AI provider is configured. The next step is to connect the approved model adapter and PICNIKO tools."
    }), {
      headers: { ...cors, "Content-Type": "application/json" }
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: "ai_request_failed" }), {
      status: 500, headers: { ...cors, "Content-Type": "application/json" }
    });
  }
});
