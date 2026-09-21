-- PICNIKO V31.5 Creative Intelligence + Media Storage
alter table public.ad_campaigns add column if not exists description text;
alter table public.ad_campaigns add column if not exists hashtags text[] not null default '{}';
alter table public.ad_campaigns add column if not exists ad_keywords text[] not null default '{}';
alter table public.ad_campaigns add column if not exists media_path text;
alter table public.ad_campaigns add column if not exists media_type text;
alter table public.ad_campaigns add column if not exists media_name text;
alter table public.ad_campaigns add column if not exists ai_strategy jsonb not null default '{}'::jsonb;

-- Private creative bucket. The browser can upload only inside the signed-in user's folder.
insert into storage.buckets (id, name, public)
values ('ad-creatives','ad-creatives',false)
on conflict (id) do update set public=false;

drop policy if exists ad_creatives_owner_insert on storage.objects;
create policy ad_creatives_owner_insert on storage.objects
for insert to authenticated
with check (bucket_id='ad-creatives' and (storage.foldername(name))[1]=auth.uid()::text);

drop policy if exists ad_creatives_owner_select on storage.objects;
create policy ad_creatives_owner_select on storage.objects
for select to authenticated
using (bucket_id='ad-creatives' and (storage.foldername(name))[1]=auth.uid()::text);

drop policy if exists ad_creatives_owner_delete on storage.objects;
create policy ad_creatives_owner_delete on storage.objects
for delete to authenticated
using (bucket_id='ad-creatives' and (storage.foldername(name))[1]=auth.uid()::text);

create index if not exists ad_campaigns_keywords_gin_idx on public.ad_campaigns using gin(ad_keywords);
create index if not exists ad_campaigns_hashtags_gin_idx on public.ad_campaigns using gin(hashtags);
