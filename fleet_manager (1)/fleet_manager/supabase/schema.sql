-- Enable pgcrypto for gen_random_uuid()
create extension if not exists pgcrypto;

-- Profiles table linked to auth.users
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  company text,
  created_at timestamptz default now()
);

-- Trucks table
create table if not exists trucks (
  id uuid primary key default gen_random_uuid(),
  plate text unique,
  model text,
  driver uuid references profiles(id),
  capacity int,
  status text,
  created_at timestamptz default now()
);

-- Trips table
create table if not exists trips (
  id uuid primary key default gen_random_uuid(),
  truck_id uuid references trucks(id) on delete set null,
  started_at timestamptz,
  ended_at timestamptz,
  origin text,
  destination text,
  status text,
  created_by uuid references profiles(id),
  created_at timestamptz default now()
);

-- Locations table (history of GPS pings)
create table if not exists locations (
  id uuid primary key default gen_random_uuid(),
  truck_id uuid references trucks(id) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  recorded_at timestamptz default now()
);

create index if not exists idx_locations_truck_id on locations(truck_id);
create index if not exists idx_locations_recorded_at on locations(recorded_at);

-- Example function to keep only recent location points (optional)
-- You can run maintenance jobs to trim old data if needed.
