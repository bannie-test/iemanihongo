-- Iemanihongo database schema.
-- Run once in the Supabase dashboard: SQL Editor → New query → paste → Run.
-- Safe to re-run.
--
-- Sync model: the app is local-first. Every row carries `updated_at`
-- (client epoch ms, used for last-write-wins merging) and `synced_at`
-- (server time, set by trigger, used as the pull cursor).

create or replace function public.touch_synced_at()
returns trigger language plpgsql as $$
begin
  new.synced_at := now();
  return new;
end $$;

-- Per-user settings (daily goal, level, reminder time, …)
create table if not exists public.profiles (
  user_id    uuid primary key default auth.uid() references auth.users on delete cascade,
  settings   jsonb not null default '{}'::jsonb,
  updated_at bigint not null default 0,
  synced_at  timestamptz not null default now()
);

-- Spaced-repetition state per word
create table if not exists public.user_cards (
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  word_id    text not null,
  state      smallint not null default 0,
  step       smallint not null default 0,
  ease       real not null default 2.5,
  interval_days real not null default 0,
  due        bigint not null default 0,
  reps       integer not null default 0,
  lapses     integer not null default 0,
  updated_at bigint not null default 0,
  synced_at  timestamptz not null default now(),
  primary key (user_id, word_id)
);

-- Daily activity, one row per day per device (summed in the app, so two
-- devices studying offline on the same day never overwrite each other).
create table if not exists public.daily_stats (
  user_id      uuid not null default auth.uid() references auth.users on delete cascade,
  day          text not null,            -- yyyy-MM-dd in the user's local time
  device_id    text not null,
  reviews      integer not null default 0,
  correct      integer not null default 0,
  new_words    integer not null default 0,
  quiz_total   integer not null default 0,
  quiz_correct integer not null default 0,
  seconds      integer not null default 0,
  goal         integer not null default 20,
  updated_at   bigint not null default 0,
  synced_at    timestamptz not null default now(),
  primary key (user_id, day, device_id)
);

-- Custom decks ("starred" is the built-in bookmarks deck)
create table if not exists public.decks (
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  id         text not null,
  name       text not null,
  deleted    boolean not null default false,
  updated_at bigint not null default 0,
  synced_at  timestamptz not null default now(),
  primary key (user_id, id)
);

create table if not exists public.deck_words (
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  deck_id    text not null,
  word_id    text not null,
  deleted    boolean not null default false,
  updated_at bigint not null default 0,
  synced_at  timestamptz not null default now(),
  primary key (user_id, deck_id, word_id)
);

-- Completed grammar lessons
create table if not exists public.grammar_progress (
  user_id      uuid not null default auth.uid() references auth.users on delete cascade,
  grammar_id   text not null,
  completed_at bigint not null default 0,
  updated_at   bigint not null default 0,
  synced_at    timestamptz not null default now(),
  primary key (user_id, grammar_id)
);

do $$
declare t text;
begin
  foreach t in array array['profiles','user_cards','daily_stats','decks','deck_words','grammar_progress'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "own rows" on public.%I', t);
    execute format('create policy "own rows" on public.%I for all to authenticated
                    using (user_id = auth.uid()) with check (user_id = auth.uid())', t);
    execute format('drop trigger if exists touch_synced_at on public.%I', t);
    execute format('create trigger touch_synced_at before insert or update on public.%I
                    for each row execute function public.touch_synced_at()', t);
    execute format('create index if not exists %I on public.%I (user_id, synced_at)', t || '_sync_idx', t);
    -- Realtime: other devices are told about changes as they happen.
    if not exists (select 1 from pg_publication_tables
                   where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;
