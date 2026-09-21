-- PICNIKO V28 COMPLETE MESSENGER
-- Non-destructive additive migration. Existing messaging/friend tables are preserved.

create table if not exists public.message_locations (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.messages(id) on delete cascade,
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_user_id uuid not null references public.profiles(id) on delete cascade,
  latitude numeric(10,7) not null check (latitude between -90 and 90),
  longitude numeric(10,7) not null check (longitude between -180 and 180),
  is_live boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists message_locations_message_idx on public.message_locations(message_id);
create index if not exists message_locations_conversation_idx on public.message_locations(conversation_id,created_at desc);

create table if not exists public.live_locations (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  latitude numeric(10,7) not null check (latitude between -90 and 90),
  longitude numeric(10,7) not null check (longitude between -180 and 180),
  is_active boolean not null default true,
  expires_at timestamptz not null,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index if not exists live_locations_conversation_idx on public.live_locations(conversation_id,is_active,expires_at desc);
create index if not exists live_locations_user_idx on public.live_locations(user_id,is_active,expires_at desc);

alter table public.message_locations enable row level security;
alter table public.live_locations enable row level security;

drop policy if exists message_locations_select_member on public.message_locations;
create policy message_locations_select_member on public.message_locations for select to authenticated
using (exists (select 1 from public.conversation_members cm where cm.conversation_id=message_locations.conversation_id and cm.user_id=auth.uid()));

drop policy if exists message_locations_insert_sender on public.message_locations;
create policy message_locations_insert_sender on public.message_locations for insert to authenticated
with check (sender_user_id=auth.uid() and exists (select 1 from public.conversation_members cm where cm.conversation_id=message_locations.conversation_id and cm.user_id=auth.uid()));

drop policy if exists live_locations_select_member on public.live_locations;
create policy live_locations_select_member on public.live_locations for select to authenticated
using (exists (select 1 from public.conversation_members cm where cm.conversation_id=live_locations.conversation_id and cm.user_id=auth.uid()));

drop policy if exists live_locations_insert_sender on public.live_locations;
create policy live_locations_insert_sender on public.live_locations for insert to authenticated
with check (user_id=auth.uid() and exists (select 1 from public.conversation_members cm where cm.conversation_id=live_locations.conversation_id and cm.user_id=auth.uid()));

drop policy if exists live_locations_update_sender on public.live_locations;
create policy live_locations_update_sender on public.live_locations for update to authenticated
using (user_id=auth.uid()) with check (user_id=auth.uid());

-- Private attachment bucket. Files are stored under conversation_id/user_id/filename.
insert into storage.buckets (id,name,public)
values ('message-media','message-media',false)
on conflict (id) do update set public=false;

drop policy if exists picniko_message_media_insert on storage.objects;
create policy picniko_message_media_insert on storage.objects for insert to authenticated
with check (bucket_id='message-media' and exists (select 1 from public.conversation_members cm where cm.conversation_id=(split_part(name,'/',1))::uuid and cm.user_id=auth.uid()));

drop policy if exists picniko_message_media_select on storage.objects;
create policy picniko_message_media_select on storage.objects for select to authenticated
using (bucket_id='message-media' and exists (select 1 from public.conversation_members cm where cm.conversation_id=(split_part(name,'/',1))::uuid and cm.user_id=auth.uid()));

drop policy if exists picniko_message_media_delete on storage.objects;
create policy picniko_message_media_delete on storage.objects for delete to authenticated
using (bucket_id='message-media' and split_part(name,'/',2)=auth.uid()::text);

create or replace function public.mark_conversation_read(p_conversation_id uuid)
returns boolean language plpgsql security definer set search_path=public,pg_catalog as $$
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  update public.conversation_members
     set last_read_at=now()
   where conversation_id=p_conversation_id and user_id=auth.uid();
  return found;
end; $$;
revoke all on function public.mark_conversation_read(uuid) from public,anon;
grant execute on function public.mark_conversation_read(uuid) to authenticated;

-- Mark existing incoming messages as seen when a conversation is opened.
create or replace function public.mark_messages_seen(p_conversation_id uuid)
returns integer language plpgsql security definer set search_path=public,pg_catalog as $$
declare n integer;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if not exists(select 1 from public.conversation_members where conversation_id=p_conversation_id and user_id=auth.uid()) then raise exception 'NOT_A_MEMBER'; end if;
  -- The base schema's last_read_at is the durable read cursor. This RPC intentionally does not alter messages.
  update public.conversation_members set last_read_at=now() where conversation_id=p_conversation_id and user_id=auth.uid();
  get diagnostics n=row_count;
  return n;
end; $$;
revoke all on function public.mark_messages_seen(uuid) from public,anon;
grant execute on function public.mark_messages_seen(uuid) to authenticated;

-- Realtime publication: safe additive operation; ignores already-added objects.
do $$ begin
  alter publication supabase_realtime add table public.message_locations;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.live_locations;
exception when duplicate_object then null; end $$;

-- Verification
select 'PICNIKO_V28_MESSENGER_COMPLETE' as migration,
       to_regclass('public.message_locations') as message_locations,
       to_regclass('public.live_locations') as live_locations;

-- V28.1 live-location message linkage (idempotent additive patch)
alter table public.live_locations
  add column if not exists message_id uuid references public.messages(id) on delete cascade;
create index if not exists live_locations_message_idx on public.live_locations(message_id, updated_at desc);
