-- PICNIKO V31 Digital Marketing foundation -- COMPATIBLE PATCH
-- Safe for an existing ad_accounts/ad_campaigns table created by an earlier attempt.

create table if not exists public.ad_accounts (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid references public.profiles(id) on delete cascade,
  provider text not null check (provider in ('picniko','google','meta')),
  provider_account_id text,
  display_name text,
  status text not null default 'disconnected' check (status in ('disconnected','connected','revoked','error')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

-- If ad_accounts already existed without owner_user_id, add it without dropping anything.
alter table public.ad_accounts add column if not exists owner_user_id uuid;
alter table public.ad_accounts add column if not exists provider text;
alter table public.ad_accounts add column if not exists provider_account_id text;
alter table public.ad_accounts add column if not exists display_name text;
alter table public.ad_accounts add column if not exists status text default 'disconnected';
alter table public.ad_accounts add column if not exists created_at timestamptz default now();
alter table public.ad_accounts add column if not exists updated_at timestamptz default now();

-- Backfill owner_user_id from common legacy ownership columns, if present.
do $$
declare
  has_owner boolean;
  has_user boolean;
  has_created_by boolean;
begin
  select exists(select 1 from information_schema.columns where table_schema='public' and table_name='ad_accounts' and column_name='owner_user_id') into has_owner;
  select exists(select 1 from information_schema.columns where table_schema='public' and table_name='ad_accounts' and column_name='user_id') into has_user;
  select exists(select 1 from information_schema.columns where table_schema='public' and table_name='ad_accounts' and column_name='created_by') into has_created_by;
  if has_owner and has_user then
    execute 'update public.ad_accounts set owner_user_id = user_id where owner_user_id is null and user_id is not null';
  end if;
  if has_owner and has_created_by then
    execute 'update public.ad_accounts set owner_user_id = created_by where owner_user_id is null and created_by is not null';
  end if;
end $$;

-- Keep owner mandatory only for rows that can safely be owned. New rows are required to have it.
update public.ad_accounts set status='disconnected' where status is null;

create table if not exists public.ad_campaigns (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid references public.profiles(id) on delete cascade,
  name text not null,
  objective text not null check (objective in ('messages','leads','traffic','sales','video_views','local_visits','awareness')),
  status text not null default 'draft' check (status in ('draft','review','active','paused','completed','archived')),
  daily_budget numeric(12,2) check (daily_budget is null or daily_budget >= 0),
  currency text not null default 'INR',
  audience jsonb not null default '{}'::jsonb,
  creative jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
alter table public.ad_campaigns add column if not exists owner_user_id uuid;
alter table public.ad_campaigns add column if not exists audience jsonb not null default '{}'::jsonb;
alter table public.ad_campaigns add column if not exists creative jsonb not null default '{}'::jsonb;
alter table public.ad_campaigns add column if not exists currency text not null default 'INR';
-- Compatibility: existing PICNIKO V31 schema uses campaign_name/campaign_type/budget.
-- Keep those columns as the source of truth; the frontend writes to them directly.


create table if not exists public.ad_campaign_channels (
  id uuid primary key default gen_random_uuid(), campaign_id uuid not null references public.ad_campaigns(id) on delete cascade,
  provider text not null check (provider in ('picniko','google','meta')),
  ad_account_id uuid references public.ad_accounts(id) on delete set null,
  status text not null default 'draft' check (status in ('draft','ready','submitted','active','paused','failed')),
  external_campaign_id text, created_at timestamptz not null default now(),
  unique(campaign_id, provider)
);

create index if not exists ad_campaigns_owner_idx on public.ad_campaigns(owner_user_id, created_at desc);
create index if not exists ad_accounts_owner_idx on public.ad_accounts(owner_user_id, provider);

alter table public.ad_accounts enable row level security;
alter table public.ad_campaigns enable row level security;
alter table public.ad_campaign_channels enable row level security;

drop policy if exists ad_accounts_owner_select on public.ad_accounts;
create policy ad_accounts_owner_select on public.ad_accounts for select using (owner_user_id = auth.uid());

drop policy if exists ad_campaigns_owner_all on public.ad_campaigns;
create policy ad_campaigns_owner_all on public.ad_campaigns for all using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());

drop policy if exists ad_campaign_channels_owner_all on public.ad_campaign_channels;
create policy ad_campaign_channels_owner_all on public.ad_campaign_channels for all using (exists(select 1 from public.ad_campaigns c where c.id=campaign_id and c.owner_user_id=auth.uid())) with check (exists(select 1 from public.ad_campaigns c where c.id=campaign_id and c.owner_user_id=auth.uid()));

-- Verification
select table_name, column_name, data_type
from information_schema.columns
where table_schema='public'
  and table_name in ('ad_accounts','ad_campaigns','ad_campaign_channels')
order by table_name, ordinal_position;
