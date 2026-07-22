# FamilyHub — Reynolds Family Dashboard

A Flutter app that runs full-screen on an iPad as an always-on family "home hub" —
a customized take on the Google Nest Hub. It shows the family's day at a glance
(calendar, tasks, groceries, mail & packages, weather) with an AI assistant bar
along the bottom.

> New here? Read **[PROJECT_MAP.md](PROJECT_MAP.md)** first — it explains what's built,
> what's still a placeholder, and the build roadmap.

## Structure

- **`reynolds_family_dashboard/`** — the Flutter app (this is what you run).
- **`Agent/`** — a local Flutter package that provides the bottom AI terminal bar and Gemini chat.
- **`supabase_migration.sql`** — the database schema (family, events, tasks, groceries).
- **`.env.example`** — template for the config keys the app needs (copy to `.env`).

## Run locally

**Prerequisites:** [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.2+.

```bash
cd reynolds_family_dashboard
cp ../.env.example .env      # then fill in your keys (see below)
flutter pub get
flutter run                  # pick your iPad or simulator
```

## Configuration

Create a `.env` file inside `reynolds_family_dashboard/` with:

- `SUPABASE_URL` and `SUPABASE_ANON_KEY` — from your Supabase project (database).
- `GEMINI_API_KEY` — from Google AI Studio (powers the AI assistant bar).

Until Supabase is connected, the app displays mock demo data. See the roadmap in
PROJECT_MAP.md for turning on the live database.
