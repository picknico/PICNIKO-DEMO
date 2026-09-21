// Shared Supabase boundary. Browser code must only use the public anon key.
// Never put a service-role key or database password here.
export function getConfig(){return window.PICNIKO_CONFIG||{}}
export function isConfigured(){const c=getConfig();return !!(c.SUPABASE_URL&&c.SUPABASE_ANON_KEY)}
export function createClient(){const c=getConfig();if(!isConfigured()||!window.supabase?.createClient)return null;return window.supabase.createClient(c.SUPABASE_URL,c.SUPABASE_ANON_KEY)}
