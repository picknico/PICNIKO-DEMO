-- PICNIKO Messages Auto Discovery V2
-- Non-destructive. Uses Supabase Auth as the source for registered accounts.
-- Returns only minimal recipient fields; email is NOT exposed.

create or replace function public.discover_message_users(p_search text default '')
returns table(user_id uuid, full_name text, role text)
language sql
security definer
set search_path = pg_catalog, public, auth
stable
as $$
  select
    u.id as user_id,
    coalesce(
      nullif(btrim(u.raw_user_meta_data ->> 'full_name'), ''),
      nullif(btrim(u.raw_user_meta_data ->> 'name'), ''),
      nullif(btrim(p.full_name), ''),
      split_part(coalesce(u.email, ''), '@', 1),
      'PICNIKO User'
    ) as full_name,
    coalesce(nullif(btrim(p.role), ''), 'USER') as role
  from auth.users u
  left join public.profiles p on p.id = u.id
  where u.id <> auth.uid()
    and coalesce(u.banned_until, now() - interval '1 second') < now()
    and (
      nullif(btrim(coalesce(p_search, '')), '') is null
      or coalesce(u.raw_user_meta_data ->> 'full_name', '') ilike '%' || btrim(p_search) || '%'
      or coalesce(u.raw_user_meta_data ->> 'name', '') ilike '%' || btrim(p_search) || '%'
      or coalesce(p.full_name, '') ilike '%' || btrim(p_search) || '%'
      or split_part(coalesce(u.email, ''), '@', 1) ilike '%' || btrim(p_search) || '%'
    )
  order by lower(
    coalesce(
      nullif(btrim(u.raw_user_meta_data ->> 'full_name'), ''),
      nullif(btrim(u.raw_user_meta_data ->> 'name'), ''),
      nullif(btrim(p.full_name), ''),
      split_part(coalesce(u.email, ''), '@', 1),
      'PICNIKO User'
    )
  ), u.id
  limit 50;
$$;

revoke all on function public.discover_message_users(text) from public;
revoke all on function public.discover_message_users(text) from anon;
grant execute on function public.discover_message_users(text) to authenticated;

create or replace function public.create_direct_conversation(p_recipient_user_id uuid)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $$
declare
  v_me uuid := auth.uid();
  v_conversation_id uuid;
begin
  if v_me is null then
    raise exception 'Authentication required';
  end if;
  if p_recipient_user_id is null then
    raise exception 'Recipient user id is required';
  end if;
  if p_recipient_user_id = v_me then
    raise exception 'You cannot create a direct conversation with yourself';
  end if;

  if not exists (select 1 from auth.users u where u.id = p_recipient_user_id) then
    raise exception 'Recipient account was not found';
  end if;

  select c.id into v_conversation_id
  from public.conversations c
  where c.conversation_type = 'direct'
    and exists (select 1 from public.conversation_members cm where cm.conversation_id=c.id and cm.user_id=v_me)
    and exists (select 1 from public.conversation_members cm where cm.conversation_id=c.id and cm.user_id=p_recipient_user_id)
    and (select count(*) from public.conversation_members cm where cm.conversation_id=c.id)=2
  order by c.updated_at desc
  limit 1;

  if v_conversation_id is not null then
    return v_conversation_id;
  end if;

  insert into public.conversations (conversation_type, title, created_by)
  values ('direct', null, v_me)
  returning id into v_conversation_id;

  insert into public.conversation_members (conversation_id, user_id, member_role)
  values (v_conversation_id, v_me, 'member'), (v_conversation_id, p_recipient_user_id, 'member');

  return v_conversation_id;
end;
$$;

revoke all on function public.create_direct_conversation(uuid) from public;
revoke all on function public.create_direct_conversation(uuid) from anon;
grant execute on function public.create_direct_conversation(uuid) to authenticated;

comment on function public.discover_message_users(text)
is 'Authenticated-only recipient discovery from registered Supabase Auth accounts. Returns user id, safe display name and role; never returns email.';
comment on function public.create_direct_conversation(uuid)
is 'Creates or reuses a 2-member direct PICNIKO conversation for an authenticated user using a verified Auth account id.';
