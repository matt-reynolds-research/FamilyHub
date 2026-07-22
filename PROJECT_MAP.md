# FamilyHub — Project Map & Build Plan

*Reynolds Family Dashboard — a Nest Hub-style iPad app. Prepared 21 Jul 2026.*

This is your orientation doc. It answers four questions: **What is here? What actually
works? How does it compare to a real Nest Hub? What should we build next?** Nothing in
your repo has been changed yet — the "Proposed cleanup" section is a list waiting for
your approval.

---

## 1. What this project is

A Flutter app that runs full-screen on an iPad and acts like a family "home hub" — the
kind of always-on wall/counter display Google sells as the Nest Hub. It shows the
family's day at a glance (calendar, tasks, groceries, mail/packages, weather) and has an
AI assistant bar along the bottom.

**One thing to understand up front:** the app was originally started in *Google AI
Studio* (a web/Node.js tool) and then re-scaffolded as a proper Flutter project. Most of
the "mess" is leftover debris from that switch — old files that no longer apply — sitting
next to the real, working Flutter code.

---

## 2. The folder map

Everything lives in `FamilyHub/`. Here is what each piece is and whether it matters:

| Folder / file | What it is | Keep? |
|---|---|---|
| **`reynolds_family_dashboard/`** | **The real app.** This is the Flutter project you actually run. | ✅ Core |
| **`Agent/`** | A small helper package the app depends on — provides the bottom AI "terminal" bar and Gemini chat. | ✅ Core |
| `supabase_migration.sql` | The database blueprint (tables for family, events, tasks, groceries). | ✅ Keep |
| `.env.example` | Sample config file — **but it's stale**, lists AI Studio/Gemini keys, not the Supabase keys the app now needs. | ⚠️ Fix |
| `README.md` (top level) | **Leftover Google AI Studio boilerplate** — talks about `npm install` and Node. Nothing to do with your Flutter app. | ❌ Replace |
| `Calendar/`, `Postage/`, `Todo_List/` | **Empty folders.** Abandoned early module stubs; these features now live inside the app's `lib/features/`. | ❌ Delete |
| `.gemini/` | One stray notes file from AI Studio. | ❌ Delete |
| `reynolds_family_dashboard/build/` | Compiler output — 453 MB of regenerated junk. Already ignored by git; just clutters your disk. | 🧹 Clean |

### Inside the real app (`reynolds_family_dashboard/lib/`)

This part is actually **well organized** — good news. It follows a standard Flutter layout:

- `features/` — one folder per screen: `home`, `calendar`, `tasks`, `groceries`, `mail`, `settings`
- `models/` — the data shapes: `event`, `task`, `grocery_item`, `mail_item`, `package`
- `providers/` — state management (`data_providers` = live data, `mock_data_provider` = fake demo data)
- `repositories/` + `services/` — the Supabase (database) connection layer
- `shell/` — the tab bar + overall screen frame
- `theme/` — colors, fonts, styling

---

## 3. What's actually built (status map)

The key thing to know: **the app shows fake ("mock") data today.** The database plumbing
is written but not switched on. So screens look alive in a demo, but nothing saves yet.

| Feature | Status | What that means |
|---|---|---|
| App shell + tab navigation | 🟢 **Working** | Five tabs, settings button, switches between screens. |
| Theme / visual design | 🟢 **Working** | Colors, fonts (Google Fonts), card styling all defined. |
| **Home** dashboard | 🟡 **Mostly built** | Greeting, date, summary cards for events/tasks/groceries. Weather is a **hardcoded "72° Sunny"** placeholder. |
| **Tasks** | 🟡 **UI built, data mocked** | List, check-off, priority dots, assignee avatars all work against fake data. Filter chips and the "+" add button are not wired. |
| **Groceries** | 🟡 **UI built, data mocked** | Category columns, check-off, add-item box. Add box calls the DB layer — will work once DB is live. |
| **Mail & Packages** | 🟡 **UI built, data mocked** | Mail/Packages toggle, delivery progress bars. Pulls straight from mock data — **not** wired to the database at all. |
| **Calendar** | 🔴 **Placeholder** | Just a "Weekly Calendar View Placeholder" card. Day/Week/Month buttons do nothing. |
| **Settings** | 🔴 **Placeholder** | Screen exists, not built out. |
| **AI assistant bar** (Agent) | 🟡 **Built, needs key** | Bottom chat bar + Gemini integration exist. Needs a real API key and testing. |
| **Supabase database** | 🟠 **Written, not connected** | Full read/write code + SQL schema exist, but the app loads mock data instead. Schema is **missing tables for Mail & Packages.** |
| Weather | 🔴 **Fake** | No weather service; hardcoded number. |

Legend: 🟢 done · 🟡 built but on fake data / partly wired · 🟠 written but switched off · 🔴 placeholder/missing

---

## 4. How it compares to a real Google Nest Hub

You asked to model this on the Nest Hub. Here's the real device's feature set vs. yours,
so you can decide what to copy and what to skip. (A tablet app can't do the hardware bits
like sleep radar — those are marked N/A.)

| Nest Hub feature | In your app? | Worth adding? |
|---|---|---|
| At-a-glance dashboard (clock, weather, day ahead) | 🟡 Partial (weather fake) | ✅ Yes — core of the hub |
| Calendar / agenda view | 🔴 Placeholder | ✅ Yes — high value |
| Reminders & to-dos | 🟡 Tasks tab (mocked) | ✅ Yes |
| Shopping / grocery list | 🟡 Built (mocked) | ✅ Yes |
| Timers & alarms | ❌ Missing | ➕ Nice-to-have (very used on real hubs) |
| Photo frame / ambient screen when idle | ❌ Missing | ➕ Strong "hub feel" add |
| Music & media control | ❌ Missing | ➕ Optional |
| Smart-home control (lights, thermostat, cameras) | ❌ Missing | ❓ Depends on your devices |
| Voice assistant / AI Q&A | 🟡 Text AI bar (Gemini) | ✅ Yes — your twist on it |
| Recipes / step-by-step | ❌ Missing | ➖ Skip for now |
| Video calling / intercom | ❌ Missing | ➖ Skip |
| Routines (e.g. "Good morning") | ❌ Missing | ➕ Later |
| Sleep sensing, motion gestures, hardware audio | N/A | ⛔ Hardware-only, can't replicate |
| **Mail & package tracking** | 🟡 Built (mocked) | ✅ **Your original feature** — Nest Hub doesn't even have this |

**Takeaway:** you're closely tracking the Nest Hub's "family organizer" core (calendar,
tasks, groceries, glanceable dashboard) and adding two things Google doesn't — an AI chat
bar and mail/package tracking. The biggest *missing* hub staples are a real photo/ambient
mode and timers.

---

## 5. Proposed cleanup — *awaiting your approval*

None of this is done yet. These are safe, low-risk tidying steps. Tell me which to run
(or "all of them"):

1. **Delete the 3 empty folders** — `Calendar/`, `Postage/`, `Todo_List/`. They're empty and superseded by `lib/features/`.
2. **Replace the top-level `README.md`** — swap the misleading AI Studio Node.js text for a short, accurate description of the Flutter app and how to run it.
3. **Fix `.env.example`** — make it list the keys the app actually needs (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GEMINI_API_KEY`) so future-you knows what to fill in.
4. **Delete `.gemini/`** — one stray AI Studio note, not used.
5. **Clear the 453 MB `build/` folder** — regenerates automatically next time you build; frees disk space. (Optional, purely local.)
6. **Fill in `Agent/`'s placeholder README** — it still says "TODO." Minor.

**Not proposed** (would need a separate decision): renaming the project, flattening the
folder structure, or moving `Agent/` inside the app. Your naming is a little repetitive
(FamilyHub / reynolds_family_dashboard / Agent) but changing it touches git history, so
I've left it for you to decide later.

---

## 6. Build roadmap — what to do next

Ordered so each step unlocks the next. The single highest-value move is **#1: turn on the
real database** — until then, nothing the family enters actually saves.

### Phase 1 — Make it real (foundation)
1. **Connect Supabase (the database).** Run the `supabase_migration.sql` to create the tables, add your keys to `.env`, and flip the app from mock data to live data. *This is the unlock — after this, tasks/groceries/events persist.*
2. **Add Mail & Package tables** to the database schema (currently missing) so the Mail tab can save too.
3. **Test the AI bar** with a real Gemini key end-to-end.

### Phase 2 — Finish the half-built screens
4. **Build the Calendar** — replace the placeholder with a real week/day agenda view (highest-visibility gap).
5. **Wire the loose buttons** — task "+" add, task filter chips, settings screen.
6. **Real weather** — swap the fake "72°" for a live weather feed.

### Phase 3 — Make it feel like a hub
7. **Ambient / photo mode** when the iPad is idle (big "Nest Hub feel" win).
8. **Timers & alarms.**
9. **Routines** (e.g. a "Good morning" screen).

### Phase 4 — Polish
10. Tune layout for the specific iPad size, add finishing touches, decide on smart-home control if you want it.

---

## Suggested first session
Approve the cleanup in §5, then we tackle **Phase 1, step 1 (connect the database)**
together — I'll walk you through each part so you understand what's happening. That's the
step that turns this from a good-looking demo into a real family tool.
