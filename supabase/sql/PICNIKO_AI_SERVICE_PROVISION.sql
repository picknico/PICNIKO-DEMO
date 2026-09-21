-- PICNIKO AI Service — non-destructive provision
-- Run only after reviewing against the live PICNIKO schema.
-- No DROP/TRUNCATE/DELETE/UPDATE statements.

create table if not exists public.ai_conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text,
  status text not null default 'active' check (status in ('active','archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ai_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.ai_conversations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('user','assistant','system','tool')),
  content text not null,
  tool_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.ai_usage_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  conversation_id uuid references public.ai_conversations(id) on delete set null,
  event_type text not null,
  model text,
  input_tokens integer,
  output_tokens integer,
  latency_ms integer,
  created_at timestamptz not null default now()
);

alter table public.ai_conversations enable row level security;
alter table public.ai_messages enable row level security;
alter table public.ai_usage_events enable row level security;

create policy "ai conversations own rows"
on public.ai_conversations for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ai messages own rows"
on public.ai_messages for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ai usage own rows"
on public.ai_usage_events for select
to authenticated
using (user_id = auth.uid());

create index if not exists ai_messages_conversation_created_idx
on public.ai_messages(conversation_id, created_at);

create index if not exists ai_usage_user_created_idx
on public.ai_usage_events(user_id, created_at);
