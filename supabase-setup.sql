-- ============================================================
--  Nourish me Bro - Supabase schema
--  Paste this whole file into your Supabase project:
--    Dashboard -> SQL Editor -> New query -> paste -> Run
--  Safe to run more than once.
-- ============================================================

-- ---------- tables ----------
-- One row per user. Created by the app on first sign-in, so there is no
-- trigger on auth.users to keep in sync.
create table if not exists public.profiles (
  user_id    uuid primary key references auth.users on delete cascade,
  name       text not null default '',
  email      text not null default '',
  cal_goal   int not null default 2000,
  p          int not null default 120,
  c          int not null default 220,
  f          int not null default 60,
  fib        int not null default 30,
  water_goal int not null default 2500,
  glass      int not null default 250,
  updated_at timestamptz not null default now()
);

-- Existing projects: create table above is skipped, so add the columns here.
alter table public.profiles add column if not exists name  text not null default '';
alter table public.profiles add column if not exists email text not null default '';

create table if not exists public.habits (
  user_id uuid not null references auth.users on delete cascade,
  id      text not null,
  name    text not null,
  emoji   text not null default '*',
  kind    text not null default 'check' check (kind in ('check','count')),
  target  int  not null default 1,
  primary key (user_id, id)
);

-- Water and habit ticks for one calendar day. Upserted, so two devices
-- editing different days never touch the same row.
create table if not exists public.day_logs (
  user_id     uuid not null references auth.users on delete cascade,
  day         date not null,
  water       int not null default 0,
  habit_state jsonb not null default '{}'::jsonb,
  primary key (user_id, day)
);

-- Each logged dish is its own row. This is the table that would collide if
-- it were a single JSON blob: two phones logging different meals would
-- overwrite each other. One row per dish makes adding an INSERT and
-- removing a DELETE, so concurrent edits merge instead of clobbering.
create table if not exists public.meal_entries (
  user_id    uuid not null references auth.users on delete cascade,
  id         text not null,
  day        date not null,
  meal       text not null check (meal in ('breakfast','lunch','snack','dinner')),
  name       text not null,
  emoji      text not null default '?',
  cal        numeric not null default 0,
  p          numeric not null default 0,
  c          numeric not null default 0,
  f          numeric not null default 0,
  fib        numeric not null default 0,
  qty_label  text not null default '',
  created_at timestamptz not null default now(),
  primary key (user_id, id)
);
create index if not exists meal_entries_user_day
  on public.meal_entries (user_id, day);

create table if not exists public.custom_foods (
  user_id    uuid not null references auth.users on delete cascade,
  id         text not null,
  name       text not null,
  emoji      text not null default '?',
  serving    text not null default '1 serving',
  cal        numeric not null default 0,
  p          numeric not null default 0,
  c          numeric not null default 0,
  f          numeric not null default 0,
  fib        numeric not null default 0,
  created_at timestamptz not null default now(),
  primary key (user_id, id)
);

-- ---------- row level security ----------
-- This is what keeps users out of each other's data. Without it, any signed-in
-- user could read every row in these tables. Enforced by Postgres itself, so a
-- bug in the frontend cannot leak another person's logs.
alter table public.profiles     enable row level security;
alter table public.habits       enable row level security;
alter table public.day_logs     enable row level security;
alter table public.meal_entries enable row level security;
alter table public.custom_foods enable row level security;

-- USING controls which rows you may read/update/delete.
-- WITH CHECK controls which rows you may insert/update into -- it stops a user
-- writing a row stamped with somebody else's user_id.
drop policy if exists own_rows on public.profiles;
create policy own_rows on public.profiles for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists own_rows on public.habits;
create policy own_rows on public.habits for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists own_rows on public.day_logs;
create policy own_rows on public.day_logs for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists own_rows on public.meal_entries;
create policy own_rows on public.meal_entries for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists own_rows on public.custom_foods;
create policy own_rows on public.custom_foods for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ---------- privileges ----------
-- Signed-in users reach the tables through these grants; RLS above then
-- narrows them to their own rows. Anonymous visitors get nothing.
grant usage on schema public to authenticated;
grant select, insert, update, delete on
  public.profiles, public.habits, public.day_logs,
  public.meal_entries, public.custom_foods
  to authenticated;

-- ---------- check it worked ----------
-- Every table below must report rls_enabled = true and policies = 1.
select c.relname            as table_name,
       c.relrowsecurity     as rls_enabled,
       count(p.polname)     as policies
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
left join pg_policy p on p.polrelid = c.oid
where n.nspname = 'public'
  and c.relname in ('profiles','habits','day_logs','meal_entries','custom_foods')
group by c.relname, c.relrowsecurity
order by c.relname;
