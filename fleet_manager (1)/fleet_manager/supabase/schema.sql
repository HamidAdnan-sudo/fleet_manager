-- ============================================================================
-- Fleet Manager — full database schema for Supabase
--
-- HOW TO USE:
--   1. Open your Supabase project → SQL Editor → New query.
--   2. Paste this entire file and click "Run".
--   3. In Project Settings → API, copy the "Project URL" and the
--      "anon" / "publishable" key into fleet_manager/.env
--      (see .env.example) as SUPABASE_URL and SUPABASE_ANON_KEY.
--   4. In Project Settings → API → Realtime, make sure "trips" and
--      "locations" are enabled for Realtime (the publication statement
--      near the bottom of this file does this for you automatically).
--
-- WARNING: this script drops and recreates the app's tables, so any
-- existing data in profiles/trucks/trips/locations will be erased. It
-- does NOT touch auth.users — your sign-up accounts are unaffected.
-- ============================================================================

create extension if not exists pgcrypto;

-- ── Clean slate ──────────────────────────────────────────────────────────
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user();
drop function if exists public.set_updated_at();
drop table if exists public.locations cascade;
drop table if exists public.trips cascade;
drop table if exists public.trucks cascade;
drop table if exists public.profiles cascade;

-- ============================================================================
-- profiles — one row per auth.users account, created automatically on sign-up
-- ============================================================================
create table public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  email      text,
  full_name  text,
  company    text,
  role       text not null default 'driver'
             check (role in ('admin', 'dispatcher', 'driver')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on column public.profiles.role is
  'admin = fleet manager/owner, dispatcher = plans trips, driver = drives trucks';

-- ============================================================================
-- trucks
-- ============================================================================
create table public.trucks (
  id         uuid primary key default gen_random_uuid(),
  plate      text not null unique,
  model      text,
  driver_id  uuid references public.profiles(id) on delete set null,
  capacity   int,
  status     text not null default 'idle'
             check (status in ('active', 'idle', 'maintenance')),
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_trucks_driver_id on public.trucks(driver_id);

-- ============================================================================
-- trips
-- ============================================================================
create table public.trips (
  id           uuid primary key default gen_random_uuid(),
  truck_id     uuid references public.trucks(id) on delete set null,
  origin       text,
  destination  text,
  cargo        text,
  started_at   timestamptz,
  ended_at     timestamptz,
  status       text not null default 'pending'
               check (status in ('pending', 'in_transit', 'delivered', 'delayed', 'completed')),
  created_by   uuid references public.profiles(id) on delete set null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index idx_trips_truck_id on public.trips(truck_id);
create index idx_trips_created_by on public.trips(created_by);

-- ============================================================================
-- locations — GPS ping history per truck
-- ============================================================================
create table public.locations (
  id          uuid primary key default gen_random_uuid(),
  truck_id    uuid references public.trucks(id) on delete cascade,
  latitude    double precision not null,
  longitude   double precision not null,
  recorded_at timestamptz not null default now()
);

create index idx_locations_truck_id on public.locations(truck_id);
create index idx_locations_recorded_at on public.locations(recorded_at);

-- ============================================================================
-- Auto-create a profile row whenever someone signs up.
-- full_name / company / role are passed in from the app as auth user
-- metadata (see SupabaseService.client.auth.signUp(..., data: {...})).
-- ============================================================================
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, company, role)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'company',
    coalesce(new.raw_user_meta_data ->> 'role', 'driver')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================================
-- Keep updated_at current on every row update.
-- ============================================================================
create function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();
create trigger set_trucks_updated_at before update on public.trucks
  for each row execute function public.set_updated_at();
create trigger set_trips_updated_at before update on public.trips
  for each row execute function public.set_updated_at();

-- ============================================================================
-- Row Level Security
--
-- This is a small-team app: every signed-in user is treated as fleet
-- staff and can see/manage all trucks, trips and locations. Only a
-- user's own profile can be edited by that user. Anonymous (logged-out)
-- access is blocked everywhere.
-- ============================================================================
alter table public.profiles  enable row level security;
alter table public.trucks    enable row level security;
alter table public.trips     enable row level security;
alter table public.locations enable row level security;

-- profiles: anyone signed in can view all profiles (needed to show driver
-- names on trucks/trips); a user may insert/update only their own row.
create policy "profiles_select_authenticated" on public.profiles
  for select to authenticated using (true);
create policy "profiles_insert_own" on public.profiles
  for insert to authenticated with check (auth.uid() = id);
create policy "profiles_update_own" on public.profiles
  for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

-- trucks: full access for any signed-in user.
create policy "trucks_select_authenticated" on public.trucks
  for select to authenticated using (true);
create policy "trucks_insert_authenticated" on public.trucks
  for insert to authenticated with check (true);
create policy "trucks_update_authenticated" on public.trucks
  for update to authenticated using (true) with check (true);
create policy "trucks_delete_authenticated" on public.trucks
  for delete to authenticated using (true);

-- trips: full access for any signed-in user.
create policy "trips_select_authenticated" on public.trips
  for select to authenticated using (true);
create policy "trips_insert_authenticated" on public.trips
  for insert to authenticated with check (true);
create policy "trips_update_authenticated" on public.trips
  for update to authenticated using (true) with check (true);
create policy "trips_delete_authenticated" on public.trips
  for delete to authenticated using (true);

-- locations: append-only GPS log. Any signed-in user can read and add
-- points; nobody edits/deletes history.
create policy "locations_select_authenticated" on public.locations
  for select to authenticated using (true);
create policy "locations_insert_authenticated" on public.locations
  for insert to authenticated with check (true);

-- ============================================================================
-- Realtime — let the app subscribe to live changes on trips and locations
-- (used by SupabaseRealtimeService). Supabase projects already have a
-- "supabase_realtime" publication; this just adds our tables to it.
-- ============================================================================
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'trips'
  ) then
    alter publication supabase_realtime add table public.trips;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'locations'
  ) then
    alter publication supabase_realtime add table public.locations;
  end if;
end $$;
