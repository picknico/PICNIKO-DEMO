-- PICNIKO Messages User Discovery V1
-- Non-destructive: adds one narrowly scoped read RPC for authenticated message discovery.
-- Returns only minimal profile fields needed to choose a messaging recipient.

create or replace function public.discover_message_users(p_search text default '')
returns table(user_id uuid, full_name text, role text)
language sql
security definer
set search_path = pg_catalog, public
stable
as $$
  select p.id, p.full_name, p.role
  from public.profiles p
  where p.id <> auth.uid()
    and (
      nullif(btrim(coalesce(p_search, '')), '') is null
      or coalesce(p.full_name, '') ilike '%' || btrim(p_search) || '%'
    )
  order by lower(coalesce(p.full_name, '')) asc, p.id asc
  limit 30;
$$;

revoke all on function public.discover_message_users(text) from public;
revoke all on function public.discover_message_users(text) from anon;
grant execute on function public.discover_message_users(text) to authenticated;

comment on function public.discover_message_users(text)
is 'Returns up to 30 non-self PICNIKO profiles for authenticated message recipient discovery. Minimal fields only.';
