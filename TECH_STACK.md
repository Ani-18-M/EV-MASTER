# ⚡ EV-MASTER: Pinned Tech Stack Specification

**Status:** Pinned & Finalized  
**Project:** EV-MASTER (Electric Vehicle Charging, Navigation & Fleet Ecosystem)

---

## 1. Core Stack Summary

| Layer | Selected Technology | Purpose & Rationale |
| :--- | :--- | :--- |
| **Client (Mobile)** | **Flutter (Dart 3.x)** | Cross-platform (iOS & Android) with high-performance 60/120 FPS map rendering. |
| **State Management** | **Flutter Riverpod (2.x)** | Type-safe, compile-time verified, reactive state management and caching. |
| **Backend & Database** | **Supabase (PostgreSQL 15+)** | Managed PostgreSQL with native PostGIS, Auth, Realtime, and S3-compatible Storage. |
| **Geospatial Engine** | **PostGIS Extension** | Spatial index (`GIST`) queries: finding nearest EV chargers, geofencing, radius filtering. |
| **Authentication** | **Supabase Auth** | Phone OTP (SMS), Google OAuth, Apple Sign-in, and JWT session handling. |
| **Realtime Engine** | **Supabase Realtime (CDC & Channels)** | Instant live updates for station slot occupancy (Available, Charging, Offline). |
| **Business Logic & APIs** | **Supabase Edge Functions (Deno / TS)** | Serverless compute for payment webhooks, slot reservation locks, and third-party APIs. |
| **Maps & Routing** | **Mapbox Maps SDK / Google Maps Flutter** | Vector maps, custom station pin markers, clustering, and turn-by-turn navigation. |
| **Networking & HTTP** | **Dio + Supabase Flutter SDK** | Robust HTTP handling, interceptors, and typed Supabase client. |
| **Local Storage** | **Flutter Secure Storage + Hive** | Secure JWT storage and local station caching for offline resilience. |
| **Payment Gateway** | **Razorpay / Stripe** | In-app wallet top-up, UPI, card payments, and pay-per-charge billing. |

---

## 2. Flutter Mobile Architecture

```
lib/
├── core/
│   ├── constants/            # API keys, map styles, assets, app strings
│   ├── network/              # Dio client, interceptors, error handling
│   ├── services/             # Supabase client singleton, location service, notifications
│   ├── theme/                # Light/Dark EV-themed design system
│   └── utils/                # PostGIS lat/lng parsers, formatters, validators
│
├── features/
│   ├── auth/                 # Phone OTP, login, profile setup
│   ├── map/                  # Interactive map, station clusters, radius search
│   ├── station_details/      # Charger speed (kW), connector types (CCS2, Type 2), pricing
│   ├── booking/              # Slot reservation, timer countdown, QR scan unlock
│   ├── charging_session/     # Live telemetry (kWh delivered, charging speed, current cost)
│   ├── wallet_payments/      # Wallet balance, transaction history, payment gateways
│   └── profile/              # User vehicles (EV models, battery capacity, connector compatibility)
│
└── main.dart                 # App initialization & Supabase bootstrap
```

---

## 3. Database & PostGIS Schema Design

### Essential Tables
1. **`profiles`**: User metadata, phone, wallet balance, saved vehicles.
2. **`vehicles`**: Make, model, battery capacity (kWh), compatible connector types.
3. **`charging_stations`**:
   - `id`: UUID
   - `name`: Text
   - `location`: `GEOGRAPHY(Point, 4326)` *(PostGIS spatial point for ultra-fast spatial search)*
   - `address`: Text
   - `is_operational`: Boolean
   - `pricing_per_kwh`: Decimal
4. **`connectors`**:
   - `id`: UUID
   - `station_id`: FK -> `charging_stations.id`
   - `type`: Enum (`CCS2`, `CHADEMO`, `TYPE_2`, `GB_T`)
   - `power_kw`: Integer (e.g., 30, 60, 120, 240 kW)
   - `status`: Enum (`available`, `charging`, `reserved`, `faulted`, `offline`)
5. **`charging_sessions`**:
   - `id`: UUID
   - `user_id`: FK -> `profiles.id`
   - `connector_id`: FK -> `connectors.id`
   - `energy_delivered_kwh`: Decimal
   - `total_cost`: Decimal
   - `status`: Enum (`in_progress`, `completed`, `cancelled`)
6. **`wallet_transactions`**:
   - `id`: UUID
   - `user_id`: FK -> `profiles.id`
   - `amount`: Decimal
   - `type`: Enum (`credit`, `debit`)

---

## 4. Key Engineering Conventions

1. **Spatial Queries**: Always query chargers using PostGIS functions (`ST_DWithin` or `ST_DistanceSphere`) indexed with `GIST(location)` for sub-millisecond response times.
2. **State Management**: Use `StateNotifierProvider` or `AsyncNotifier` (Riverpod) for reactive UI state.
3. **Security**: Enforce **PostgreSQL Row Level Security (RLS)** on all Supabase tables.
4. **Hardware Extension**: If physical hardware chargers require raw persistent OCPP 1.6J/2.0.1 sockets, connect chargers to a lightweight OCPP gateway microservice that writes state directly into the Supabase PostgreSQL database.
