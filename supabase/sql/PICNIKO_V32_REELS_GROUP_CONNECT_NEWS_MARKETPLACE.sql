-- PICNIKO V32
-- Reels + Groups + Connect + News + Marketplace backend foundation
-- ADDITIVE ONLY. Does not alter or drop existing PICNIKO tables, RPCs, RLS or data.
-- Connect intentionally reuses the existing production friend_requests RPCs.

-- ============================================================
-- REELS
-- ============================================================
create table if not exists public.picniko_reels (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  video_path text not null,
  cover_path text,
  caption text,
  hashtags text[] not null default '{}',
  location_name text,
  duration_seconds numeric(8,2),
  status text not null default 'published' check (status in ('draft','published','archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists picniko_reels_author_idx on public.picniko_reels(author_id,created_at desc);
create index if not exists picniko_reels_feed_idx on public.picniko_reels(status,created_at desc);

create table if not exists public.picniko_reel_likes (
  reel_id uuid not null references public.picniko_reels(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (reel_id,user_id)
);
create table if not exists public.picniko_reel_saves (
  reel_id uuid not null references public.picniko_reels(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (reel_id,user_id)
);
create table if not exists public.picniko_reel_comments (
  id uuid primary key default gen_random_uuid(),
  reel_id uuid not null references public.picniko_reels(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (length(btrim(body)) between 1 and 2000),
  parent_comment_id uuid references public.picniko_reel_comments(id) on delete cascade,
  created_at timestamptz not null default now()
);
create index if not exists picniko_reel_comments_idx on public.picniko_reel_comments(reel_id,created_at desc);

-- ============================================================
-- GROUPS
-- ============================================================
create table if not exists public.picniko_groups (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null check (length(btrim(name)) between 2 and 120),
  description text,
  cover_path text,
  visibility text not null default 'public' check (visibility in ('public','private')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists picniko_groups_created_idx on public.picniko_groups(created_at desc);

create table if not exists public.picniko_group_members (
  group_id uuid not null references public.picniko_groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','admin','moderator','member')),
  status text not null default 'active' check (status in ('active','pending','blocked')),
  joined_at timestamptz not null default now(),
  primary key(group_id,user_id)
);
create index if not exists picniko_group_members_user_idx on public.picniko_group_members(user_id,status);

create table if not exists public.picniko_group_posts (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.picniko_groups(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text,
  media_path text,
  created_at timestamptz not null default now()
);
create index if not exists picniko_group_posts_idx on public.picniko_group_posts(group_id,created_at desc);

-- ============================================================
-- NEWS
-- ============================================================
create table if not exists public.picniko_news (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references public.profiles(id) on delete set null,
  title text not null check (length(btrim(title)) between 3 and 300),
  summary text,
  body text,
  image_path text,
  category text,
  city text,
  source_name text,
  source_url text,
  status text not null default 'published' check (status in ('draft','published','archived')),
  published_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists picniko_news_feed_idx on public.picniko_news(status,published_at desc);
create index if not exists picniko_news_city_idx on public.picniko_news(city,published_at desc);
create index if not exists picniko_news_category_idx on public.picniko_news(category,published_at desc);

create table if not exists public.picniko_news_bookmarks (
  news_id uuid not null references public.picniko_news(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(news_id,user_id)
);

-- ============================================================
-- MARKETPLACE
-- ============================================================
create table if not exists public.picniko_marketplace_listings (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (length(btrim(title)) between 2 and 200),
  description text,
  category text,
  price numeric(14,2) not null default 0 check (price >= 0),
  currency text not null default 'INR',
  image_paths text[] not null default '{}',
  stock_quantity integer not null default 0 check (stock_quantity >= 0),
  city text,
  status text not null default 'active' check (status in ('draft','active','sold_out','archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists picniko_marketplace_feed_idx on public.picniko_marketplace_listings(status,created_at desc);
create index if not exists picniko_marketplace_seller_idx on public.picniko_marketplace_listings(seller_id,created_at desc);
create index if not exists picniko_marketplace_category_idx on public.picniko_marketplace_listings(category,status);

create table if not exists public.picniko_marketplace_favorites (
  listing_id uuid not null references public.picniko_marketplace_listings(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(listing_id,user_id)
);

create table if not exists public.picniko_marketplace_inquiries (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.picniko_marketplace_listings(id) on delete cascade,
  buyer_id uuid not null references public.profiles(id) on delete cascade,
  message text not null check (length(btrim(message)) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index if not exists picniko_marketplace_inquiries_idx on public.picniko_marketplace_inquiries(listing_id,created_at desc);

-- ============================================================
-- RLS
-- ============================================================
alter table public.picniko_reels enable row level security;
alter table public.picniko_reel_likes enable row level security;
alter table public.picniko_reel_saves enable row level security;
alter table public.picniko_reel_comments enable row level security;
alter table public.picniko_groups enable row level security;
alter table public.picniko_group_members enable row level security;
alter table public.picniko_group_posts enable row level security;
alter table public.picniko_news enable row level security;
alter table public.picniko_news_bookmarks enable row level security;
alter table public.picniko_marketplace_listings enable row level security;
alter table public.picniko_marketplace_favorites enable row level security;
alter table public.picniko_marketplace_inquiries enable row level security;

-- Reels
 drop policy if exists v32_reels_read on public.picniko_reels;
create policy v32_reels_read on public.picniko_reels for select to authenticated
using (status='published' or author_id=auth.uid());
drop policy if exists v32_reels_insert on public.picniko_reels;
create policy v32_reels_insert on public.picniko_reels for insert to authenticated
with check (author_id=auth.uid());
drop policy if exists v32_reels_update on public.picniko_reels;
create policy v32_reels_update on public.picniko_reels for update to authenticated
using (author_id=auth.uid()) with check (author_id=auth.uid());
drop policy if exists v32_reels_delete on public.picniko_reels;
create policy v32_reels_delete on public.picniko_reels for delete to authenticated
using (author_id=auth.uid());

drop policy if exists v32_reel_likes_all on public.picniko_reel_likes;
create policy v32_reel_likes_all on public.picniko_reel_likes for all to authenticated
using (user_id=auth.uid()) with check (user_id=auth.uid());
drop policy if exists v32_reel_comments_read on public.picniko_reel_comments;
create policy v32_reel_comments_read on public.picniko_reel_comments for select to authenticated using (true);
drop policy if exists v32_reel_comments_insert on public.picniko_reel_comments;
create policy v32_reel_comments_insert on public.picniko_reel_comments for insert to authenticated with check (user_id=auth.uid());
drop policy if exists v32_reel_comments_update on public.picniko_reel_comments;
create policy v32_reel_comments_update on public.picniko_reel_comments for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
drop policy if exists v32_reel_comments_delete on public.picniko_reel_comments;
create policy v32_reel_comments_delete on public.picniko_reel_comments for delete to authenticated using (user_id=auth.uid());
drop policy if exists v32_reel_saves_all on public.picniko_reel_saves;
create policy v32_reel_saves_all on public.picniko_reel_saves for all to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());

-- Groups
create or replace function public.picniko_is_group_member(p_group_id uuid, p_user_id uuid default auth.uid())
returns boolean language sql security definer stable set search_path=public,pg_catalog as $$
  select exists(select 1 from public.picniko_group_members gm where gm.group_id=p_group_id and gm.user_id=p_user_id and gm.status='active');
$$;
revoke all on function public.picniko_is_group_member(uuid,uuid) from public,anon;
grant execute on function public.picniko_is_group_member(uuid,uuid) to authenticated;
create or replace function public.picniko_is_group_owner(p_group_id uuid, p_user_id uuid default auth.uid())
returns boolean language sql security definer stable set search_path=public,pg_catalog as $$
  select exists(select 1 from public.picniko_groups g where g.id=p_group_id and g.owner_id=p_user_id);
$$;
revoke all on function public.picniko_is_group_owner(uuid,uuid) from public,anon;
grant execute on function public.picniko_is_group_owner(uuid,uuid) to authenticated;

drop policy if exists v32_groups_read on public.picniko_groups;
create policy v32_groups_read on public.picniko_groups for select to authenticated
using (visibility='public' or owner_id=auth.uid() or public.picniko_is_group_member(id));
drop policy if exists v32_groups_insert on public.picniko_groups;
create policy v32_groups_insert on public.picniko_groups for insert to authenticated with check (owner_id=auth.uid());
drop policy if exists v32_groups_update on public.picniko_groups;
create policy v32_groups_update on public.picniko_groups for update to authenticated using (owner_id=auth.uid()) with check (owner_id=auth.uid());
drop policy if exists v32_groups_delete on public.picniko_groups;
create policy v32_groups_delete on public.picniko_groups for delete to authenticated using (owner_id=auth.uid());

drop policy if exists v32_group_members_read on public.picniko_group_members;
create policy v32_group_members_read on public.picniko_group_members for select to authenticated
using (user_id=auth.uid() or public.picniko_is_group_member(group_id));
drop policy if exists v32_group_members_insert on public.picniko_group_members;
create policy v32_group_members_insert on public.picniko_group_members for insert to authenticated
with check (user_id=auth.uid() or public.picniko_is_group_owner(group_id));
drop policy if exists v32_group_members_update on public.picniko_group_members;
create policy v32_group_members_update on public.picniko_group_members for update to authenticated
using (user_id=auth.uid() or public.picniko_is_group_owner(group_id))
with check (user_id=auth.uid() or public.picniko_is_group_owner(group_id));
drop policy if exists v32_group_members_delete on public.picniko_group_members;
create policy v32_group_members_delete on public.picniko_group_members for delete to authenticated
using (user_id=auth.uid() or public.picniko_is_group_owner(group_id));

drop policy if exists v32_group_posts_read on public.picniko_group_posts;
create policy v32_group_posts_read on public.picniko_group_posts for select to authenticated
using (public.picniko_is_group_member(group_id));
drop policy if exists v32_group_posts_insert on public.picniko_group_posts;
create policy v32_group_posts_insert on public.picniko_group_posts for insert to authenticated
with check (author_id=auth.uid() and public.picniko_is_group_member(group_id));
drop policy if exists v32_group_posts_update on public.picniko_group_posts;
create policy v32_group_posts_update on public.picniko_group_posts for update to authenticated using (author_id=auth.uid()) with check (author_id=auth.uid());
drop policy if exists v32_group_posts_delete on public.picniko_group_posts;
create policy v32_group_posts_delete on public.picniko_group_posts for delete to authenticated using (author_id=auth.uid());

-- News
drop policy if exists v32_news_read on public.picniko_news;
create policy v32_news_read on public.picniko_news for select to authenticated using (status='published' or author_id=auth.uid());
drop policy if exists v32_news_insert on public.picniko_news;
create policy v32_news_insert on public.picniko_news for insert to authenticated with check (author_id=auth.uid());
drop policy if exists v32_news_update on public.picniko_news;
create policy v32_news_update on public.picniko_news for update to authenticated using (author_id=auth.uid()) with check (author_id=auth.uid());
drop policy if exists v32_news_delete on public.picniko_news;
create policy v32_news_delete on public.picniko_news for delete to authenticated using (author_id=auth.uid());
drop policy if exists v32_news_bookmarks_all on public.picniko_news_bookmarks;
create policy v32_news_bookmarks_all on public.picniko_news_bookmarks for all to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());

-- Marketplace
drop policy if exists v32_marketplace_read on public.picniko_marketplace_listings;
create policy v32_marketplace_read on public.picniko_marketplace_listings for select to authenticated using (status='active' or seller_id=auth.uid());
drop policy if exists v32_marketplace_insert on public.picniko_marketplace_listings;
create policy v32_marketplace_insert on public.picniko_marketplace_listings for insert to authenticated with check (seller_id=auth.uid());
drop policy if exists v32_marketplace_update on public.picniko_marketplace_listings;
create policy v32_marketplace_update on public.picniko_marketplace_listings for update to authenticated using (seller_id=auth.uid()) with check (seller_id=auth.uid());
drop policy if exists v32_marketplace_delete on public.picniko_marketplace_listings;
create policy v32_marketplace_delete on public.picniko_marketplace_listings for delete to authenticated using (seller_id=auth.uid());
drop policy if exists v32_marketplace_favorites_all on public.picniko_marketplace_favorites;
create policy v32_marketplace_favorites_all on public.picniko_marketplace_favorites for all to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
drop policy if exists v32_marketplace_inquiries_read on public.picniko_marketplace_inquiries;
create policy v32_marketplace_inquiries_read on public.picniko_marketplace_inquiries for select to authenticated
using (buyer_id=auth.uid() or exists(select 1 from public.picniko_marketplace_listings l where l.id=listing_id and l.seller_id=auth.uid()));
drop policy if exists v32_marketplace_inquiries_insert on public.picniko_marketplace_inquiries;
create policy v32_marketplace_inquiries_insert on public.picniko_marketplace_inquiries for insert to authenticated with check (buyer_id=auth.uid());

-- ============================================================
-- PRIVATE REEL MEDIA STORAGE
-- ============================================================
insert into storage.buckets(id,name,public) values('reel-media','reel-media',true)
on conflict(id) do update set public=true;
drop policy if exists v32_reel_media_insert on storage.objects;
create policy v32_reel_media_insert on storage.objects for insert to authenticated
with check (bucket_id='reel-media' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists v32_reel_media_delete on storage.objects;
create policy v32_reel_media_delete on storage.objects for delete to authenticated
using (bucket_id='reel-media' and (storage.foldername(name))[1]=auth.uid()::text);

-- ============================================================
-- Realtime (safe/idempotent)
-- ============================================================
do $$ begin alter publication supabase_realtime add table public.picniko_reel_comments; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.picniko_group_posts; exception when duplicate_object then null; end $$;

select 'PICNIKO_V32_BACKEND_ADDITIVE_READY' as migration;
