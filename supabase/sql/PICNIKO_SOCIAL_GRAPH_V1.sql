-- PICNIKO SOCIAL GRAPH V1
-- Additive / non-destructive. Existing QR, reward, auth and messaging tables are not modified.

create table if not exists public.picniko_connections (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles(id) on delete cascade,
  addressee_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','declined','blocked','cancelled')),
  created_at timestamptz not null default now(),
  responded_at timestamptz,
  constraint picniko_connections_no_self check (requester_id <> addressee_id)
);

create unique index if not exists picniko_connections_pair_uidx
on public.picniko_connections (least(requester_id, addressee_id), greatest(requester_id, addressee_id));
create index if not exists picniko_connections_requester_idx on public.picniko_connections(requester_id,status,created_at desc);
create index if not exists picniko_connections_addressee_idx on public.picniko_connections(addressee_id,status,created_at desc);

create table if not exists public.picniko_content_items (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  content_type text not null default 'post' check (content_type in ('post','reel','story','activity','news','education','business','professional','civic')),
  title text,
  body text,
  media_url text,
  city text,
  audience text not null default 'public' check (audience in ('public','connections','role','private')),
  target_roles text[] not null default '{}',
  tags text[] not null default '{}',
  status text not null default 'published' check (status in ('draft','published','archived')),
  published_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index if not exists picniko_content_feed_idx on public.picniko_content_items(status,content_type,published_at desc);
create index if not exists picniko_content_author_idx on public.picniko_content_items(author_id,published_at desc);
create index if not exists picniko_content_city_idx on public.picniko_content_items(city,published_at desc);

create table if not exists public.picniko_content_events (
  id bigint generated always as identity primary key,
  content_id uuid not null references public.picniko_content_items(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete set null,
  event_type text not null check (event_type in ('impression','open','view','like','comment','share','save','hide','not_interested')),
  watch_seconds numeric(10,2),
  created_at timestamptz not null default now()
);
create index if not exists picniko_content_events_content_idx on public.picniko_content_events(content_id,event_type,created_at desc);
create index if not exists picniko_content_events_user_idx on public.picniko_content_events(user_id,created_at desc);

alter table public.picniko_connections enable row level security;
alter table public.picniko_content_items enable row level security;
alter table public.picniko_content_events enable row level security;

drop policy if exists picniko_connections_select on public.picniko_connections;
create policy picniko_connections_select on public.picniko_connections for select to authenticated
using (requester_id = auth.uid() or addressee_id = auth.uid());

drop policy if exists picniko_content_public_read on public.picniko_content_items;
create policy picniko_content_public_read on public.picniko_content_items for select to authenticated
using (status = 'published' and (audience = 'public' or author_id = auth.uid()));

drop policy if exists picniko_content_events_insert on public.picniko_content_events;
create policy picniko_content_events_insert on public.picniko_content_events for insert to authenticated
with check (user_id = auth.uid());

drop policy if exists picniko_content_events_select_self on public.picniko_content_events;
create policy picniko_content_events_select_self on public.picniko_content_events for select to authenticated
using (user_id = auth.uid());

create or replace function public.picniko_discover_people(p_search text default '', p_limit integer default 30)
returns table(user_id uuid, full_name text, role text, city text, relationship text)
language sql
security definer
set search_path = public, pg_catalog
stable
as $$
  with rel as (
    select case when c.requester_id = auth.uid() then c.addressee_id else c.requester_id end as other_id,
           c.status,
           case when c.requester_id = auth.uid() then 'outgoing' else 'incoming' end as direction
    from public.picniko_connections c
    where c.requester_id = auth.uid() or c.addressee_id = auth.uid()
  )
  select p.id, p.full_name, p.role::text, p.city,
         coalesce(case when r.status='accepted' then 'friend'
                       when r.status='pending' and r.direction='outgoing' then 'pending_sent'
                       when r.status='pending' and r.direction='incoming' then 'pending_received'
                       when r.status='declined' then 'declined' end, 'none') as relationship
  from public.profiles p
  left join rel r on r.other_id = p.id
  where p.id <> auth.uid()
    and coalesce(p.is_active,true) = true
    and (nullif(btrim(coalesce(p_search,'')),'') is null
         or coalesce(p.full_name,'') ilike '%'||btrim(p_search)||'%'
         or coalesce(p.city,'') ilike '%'||btrim(p_search)||'%'
         or coalesce(p.role::text,'') ilike '%'||btrim(p_search)||'%')
  order by case when r.status='accepted' then 0 when r.status='pending' then 1 else 2 end,
           lower(coalesce(p.full_name,'')), p.id
  limit greatest(1, least(coalesce(p_limit,30),100));
$$;
revoke all on function public.picniko_discover_people(text,integer) from public, anon;
grant execute on function public.picniko_discover_people(text,integer) to authenticated;

create or replace function public.picniko_send_friend_request(p_target uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_catalog
as $$
declare v_existing public.picniko_connections; v_id uuid;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if p_target is null or p_target = auth.uid() then raise exception 'INVALID_TARGET'; end if;
  select * into v_existing from public.picniko_connections
  where least(requester_id,addressee_id)=least(auth.uid(),p_target)
    and greatest(requester_id,addressee_id)=greatest(auth.uid(),p_target)
  limit 1;
  if v_existing.id is not null then
    if v_existing.status='declined' then
      update public.picniko_connections set requester_id=auth.uid(), addressee_id=p_target, status='pending', created_at=now(), responded_at=null where id=v_existing.id;
      return jsonb_build_object('ok',true,'id',v_existing.id,'status','pending');
    end if;
    return jsonb_build_object('ok',true,'id',v_existing.id,'status',v_existing.status);
  end if;
  insert into public.picniko_connections(requester_id,addressee_id,status) values(auth.uid(),p_target,'pending') returning id into v_id;
  return jsonb_build_object('ok',true,'id',v_id,'status','pending');
end;
$$;
revoke all on function public.picniko_send_friend_request(uuid) from public, anon;
grant execute on function public.picniko_send_friend_request(uuid) to authenticated;

create or replace function public.picniko_respond_friend_request(p_connection uuid, p_action text)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_catalog
as $$
declare v_status text; v_addressee uuid;
begin
  select status, addressee_id into v_status,v_addressee from public.picniko_connections where id=p_connection for update;
  if v_addressee is null or v_addressee <> auth.uid() then raise exception 'NOT_AUTHORIZED'; end if;
  if v_status <> 'pending' then return jsonb_build_object('ok',true,'status',v_status); end if;
  if lower(p_action)='accept' then
    update public.picniko_connections set status='accepted', responded_at=now() where id=p_connection;
  elsif lower(p_action)='decline' then
    update public.picniko_connections set status='declined', responded_at=now() where id=p_connection;
  else raise exception 'INVALID_ACTION'; end if;
  select status into v_status from public.picniko_connections where id=p_connection;
  return jsonb_build_object('ok',true,'status',v_status);
end;
$$;
revoke all on function public.picniko_respond_friend_request(uuid,text) from public, anon;
grant execute on function public.picniko_respond_friend_request(uuid,text) to authenticated;

create or replace function public.picniko_ranked_feed(p_limit integer default 20)
returns table(content_id uuid, author_id uuid, content_type text, title text, body text, media_url text, city text, published_at timestamptz, score numeric)
language sql
security definer
set search_path = public, pg_catalog
stable
as $$
  with me as (select id, city, role::text as role from public.profiles where id=auth.uid()),
  friends as (
    select case when requester_id=auth.uid() then addressee_id else requester_id end as user_id
    from public.picniko_connections where (requester_id=auth.uid() or addressee_id=auth.uid()) and status='accepted'
  ),
  stats as (
    select content_id,
      sum(case when event_type='like' then 3 when event_type='comment' then 5 when event_type='share' then 7 when event_type='save' then 6 when event_type='view' then 0.5 else 0 end) as engagement
    from public.picniko_content_events group by content_id
  )
  select c.id,c.author_id,c.content_type,c.title,c.body,c.media_url,c.city,c.published_at,
    round((coalesce(s.engagement,0)
      + case when f.user_id is not null then 35 else 0 end
      + case when m.city is not null and c.city=m.city then 18 else 0 end
      + case when c.target_roles && array[m.role] then 12 else 0 end
      + greatest(0, 30 - extract(epoch from (now()-c.published_at))/3600.0)::numeric
    ),2) as score
  from public.picniko_content_items c
  cross join me m
  left join friends f on f.user_id=c.author_id
  left join stats s on s.content_id=c.id
  where c.status='published' and (c.audience='public' or c.author_id=auth.uid() or (c.audience='connections' and f.user_id is not null))
  order by score desc, c.published_at desc
  limit greatest(1,least(coalesce(p_limit,20),50));
$$;
revoke all on function public.picniko_ranked_feed(integer) from public, anon;
grant execute on function public.picniko_ranked_feed(integer) to authenticated;
