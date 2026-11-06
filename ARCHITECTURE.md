# 🏗️ EV-MASTER Architecture & Data Flow

This document details the system design, communication patterns, and database procedures for **EV-MASTER**.

---

## 1. System Data Flow

```
                               ┌────────────────────────────────┐
                               │   Flutter Client (iOS/Android) │
                               └────────────────┬───────────────┘
                                                │
                 ┌──────────────────────────────┼──────────────────────────────┐
                 │ (1) PostGIS Radius Query     │ (2) Realtime Status Stream   │ (3) Slot Booking / Pay
                 ▼                              ▼                              ▼
    ┌───────────────────────────┐  ┌───────────────────────────┐  ┌───────────────────────────┐
    │  PostgreSQL (Supabase)    │  │  Supabase Realtime        │  │  Supabase Edge Functions  │
    │  - ST_DWithin (Nearby)    │  │  - Connector Status       │  │  - Razorpay/Stripe Verify │
    │  - Row Level Security     │  │  - Live kWh Telemetry     │  │  - Slot Reservation Lock  │
    └───────────────────────────┘  └───────────────────────────┘  └───────────────────────────┘
```

---

## 2. PostGIS Nearby Stations Query (SQL Function)

Save this function in Supabase SQL Editor to support instant spatial lookup:

```sql
-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Function: Find nearby charging stations within radius (meters)
CREATE OR REPLACE FUNCTION get_nearby_stations(
  user_lat DOUBLE PRECISION,
  user_lng DOUBLE PRECISION,
  radius_meters DOUBLE PRECISION DEFAULT 10000
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  distance_meters DOUBLE PRECISION,
  is_operational BOOLEAN
)
LANGUAGE sql
STABLE
AS $$
  SELECT 
    s.id,
    s.name,
    s.address,
    ST_Y(s.location::geometry) AS latitude,
    ST_X(s.location::geometry) AS longitude,
    ST_Distance(s.location, ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography) AS distance_meters,
    s.is_operational
  FROM charging_stations s
  WHERE ST_DWithin(
    s.location,
    ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
    radius_meters
  )
  ORDER BY distance_meters ASC;
$$;
```

---

## 3. Realtime Subscription Pattern in Flutter (Riverpod)

```dart
// Stream provider listening to live connector status changes
final connectorStatusStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, stationId) {
  final supabase = Supabase.instance.client;
  return supabase
      .from('connectors')
      .stream(primaryKey: ['id'])
      .eq('station_id', stationId);
});
```
