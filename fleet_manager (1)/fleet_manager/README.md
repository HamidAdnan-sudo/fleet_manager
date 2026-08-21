# Fleet Manager

A Flutter fleet management app (trucks, trips, drivers) backed by
Supabase (Postgres + Auth). Accounts sign up with a role — Fleet
Manager, Dispatcher, or Driver — and the app greets each user by name
and role after login.

## Setup

1. **Database.** Open your Supabase project → SQL Editor → New query,
   paste the entire contents of [`supabase/schema.sql`](supabase/schema.sql),
   and click Run. This creates the `profiles`, `trucks`, `trips` and
   `locations` tables, the trigger that auto-creates a profile on
   sign-up, and all Row Level Security policies. It's safe to re-run —
   it drops and recreates the app's own tables without touching your
   `auth.users` accounts.

2. **Credentials.** Copy `.env.example` to `assets/.env` (not the
   project root — that's the file the app actually loads) and fill in:
   - `SUPABASE_URL` / `SUPABASE_ANON_KEY` — Project Settings → API in
     your Supabase dashboard.
   - `MAPS_API_KEY` — a Google Maps API key, if you're using the map view.

3. **Install & run.**
   ```
   flutter pub get
   flutter run -d chrome   # or an Android/iOS device
   ```

## How auth + database line up

- Sign-up collects full name, company, and role, and passes them as
  Supabase auth user metadata. A Postgres trigger (`on_auth_user_created`
  in `schema.sql`) reads that metadata and creates the matching
  `profiles` row automatically — no separate "create profile" API call
  from the app.
- Login and sign-up both fetch that profile immediately afterward
  (`ProfileService`) and show a "Welcome back, {name}! Signed in as
  {role}" message.
- The home, trucks and trips screens all read live data from Supabase
  (`FleetService`) — nothing is hardcoded/mock.
- Row Level Security is enabled on every table: any signed-in user can
  read/write fleet data (trucks, trips, locations), but can only edit
  their own profile row.

## Android Maps key

`android/app/build.gradle.kts` reads `MAPS_API_KEY` out of
`assets/.env` at build time and injects it into
`AndroidManifest.xml`'s `${MAPS_API_KEY}` placeholder, so you only
need to set the key in one place.
