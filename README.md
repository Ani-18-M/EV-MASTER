# ⚡ EV-MASTER

Cross-platform Electric Vehicle (EV) charging station discovery, slot reservation, and live telemetry platform built with **Flutter** and **Supabase (PostgreSQL + PostGIS)**.

---

## 📌 Pinned Tech Stack

- **Mobile App**: Flutter (Dart 3.x) with Riverpod 2.x
- **Backend**: Supabase (PostgreSQL 15+, PostGIS spatial extensions, Realtime, Storage)
- **API & Serverless**: Supabase Edge Functions (TypeScript / Deno)
- **Maps**: Mapbox Maps SDK / Google Maps Flutter
- **Payments**: Razorpay / Stripe integration

For full details, see:
- [TECH_STACK.md](file:///Users/marrianil/Desktop/EV-MASTER/TECH_STACK.md) — Comprehensive stack specification and rationale.
- [ARCHITECTURE.md](file:///Users/marrianil/Desktop/EV-MASTER/ARCHITECTURE.md) — System architecture, data flow, and PostGIS SQL queries.

---

## 🚀 Getting Started

### 1. Supabase Setup
1. Create a Supabase project at [supabase.com](https://supabase.com).
2. Enable the `postgis` extension in **Database -> Extensions**.
3. Run the SQL schema and functions from [ARCHITECTURE.md](file:///Users/marrianil/Desktop/EV-MASTER/ARCHITECTURE.md).

### 2. Client Setup
1. Initialize the Flutter app dependencies:
   ```bash
   flutter pub get
   ```
2. Configure your Supabase URL and Anon Key in `.env`:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```
