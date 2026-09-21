-- PICNIKO V34 — Reels engagement state/counts
-- ADDITIVE ONLY. Does not drop/alter existing tables, RPCs or data.

create or replace function public.picniko_get_reel_engagements(p_reel_ids uuid[])
returns table(
  reel_id uuid,
  like_count bigint,
  comment_count bigint,
  save_count bigint,
  liked boolean,
  saved boolean
)
language sql
security definer
stable
set search_path = public, pg_catalog
as $$
  select
    r.id as reel_id,
    (select count(*) from public.picniko_reel_likes l where l.reel_id = r.id) as like_count,
    (select count(*) from public.picniko_reel_comments c where c.reel_id = r.id) as comment_count,
    (select count(*) from public.picniko_reel_saves s where s.reel_id = r.id) as save_count,
    exists(select 1 from public.picniko_reel_likes l where l.reel_id = r.id and l.user_id = auth.uid()) as liked,
    exists(select 1 from public.picniko_reel_saves s where s.reel_id = r.id and s.user_id = auth.uid()) as saved
  from public.picniko_reels r
  where r.id = any(coalesce(p_reel_ids, '{}'::uuid[]));
$$;

revoke all on function public.picniko_get_reel_engagements(uuid[]) from public, anon;
grant execute on function public.picniko_get_reel_engagements(uuid[]) to authenticated;

select 'PICNIKO_V34_REELS_ENGAGEMENT_READY' as migration;
