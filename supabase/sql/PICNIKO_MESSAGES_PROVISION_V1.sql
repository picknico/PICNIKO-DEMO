-- PICNIKO Messages V1: controlled direct-conversation creation
-- Review against the live schema before execution. No existing tables are altered.

create or replace function public.create_direct_conversation(p_recipient_user_id uuid)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public
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

  if not exists (select 1 from public.profiles p where p.id = p_recipient_user_id) then
    raise exception 'Recipient account was not found';
  end if;

  -- Reuse an existing 2-member direct conversation when one already exists.
  select c.id
    into v_conversation_id
  from public.conversations c
  where c.conversation_type = 'direct'
    and exists (
      select 1 from public.conversation_members cm
      where cm.conversation_id = c.id and cm.user_id = v_me
    )
    and exists (
      select 1 from public.conversation_members cm
      where cm.conversation_id = c.id and cm.user_id = p_recipient_user_id
    )
    and (
      select count(*) from public.conversation_members cm
      where cm.conversation_id = c.id
    ) = 2
  order by c.updated_at desc
  limit 1;

  if v_conversation_id is not null then
    return v_conversation_id;
  end if;

  insert into public.conversations (conversation_type, title, created_by)
  values ('direct', null, v_me)
  returning id into v_conversation_id;

  insert into public.conversation_members (conversation_id, user_id, member_role)
  values
    (v_conversation_id, v_me, 'member'),
    (v_conversation_id, p_recipient_user_id, 'member');

  return v_conversation_id;
end;
$$;

revoke all on function public.create_direct_conversation(uuid) from public;
revoke all on function public.create_direct_conversation(uuid) from anon;
grant execute on function public.create_direct_conversation(uuid) to authenticated;

comment on function public.create_direct_conversation(uuid)
is 'Creates or reuses a 2-member direct PICNIKO conversation for the authenticated user. No PII or secrets are returned.';
