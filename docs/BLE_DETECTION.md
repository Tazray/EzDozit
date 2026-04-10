# BLE Proximity Detection

Ez Dozit uses Bluetooth Low Energy (BLE) scanning to detect nearby people and count them as "encounters" — a core part of the game loop that rewards players for being around others.

## How It Works

During an active adventure session, the app performs periodic BLE scans and tracks observed devices over time. Each device is recorded as a series of `(device_hash, RSSI, timestamp)` tuples.

### Device Hashing

We never store actual MAC addresses. Each device address is hashed with a daily-rotating salt, so the same physical device produces different hashes on different days. This prevents long-term tracking while still allowing us to track a device across a single session.

### Motion Signature Classification

The classifier examines RSSI (signal strength) patterns over time to distinguish between:

**Stationary devices** (routers, smart appliances, TVs):
- RSSI stays roughly constant across many scans
- These are ignored — they're not people

**Approaching/receding devices** (a person walking past):
- RSSI follows a characteristic curve: increasing → peak → decreasing
- This pattern occurs over a 10-30 second window
- Counted as an encounter

**Brief flash devices** (someone walking quickly past):
- A single strong reading that appears and disappears
- Counted as an encounter with lower confidence

### Distance Estimation

Peak RSSI is converted to an approximate distance using a tunable path-loss model. The formula accounts for:
- Reference RSSI at 1 meter (calibrated per-device or using a conservative default)
- Path-loss exponent (typically 2.0-4.0 depending on environment)

This estimate is intentionally rough — we display it as "nearby" / "passing by" / "in the distance" rather than exact meters.

### Filtering

The app maintains an ignore list to filter out:
- The user's own paired devices (earbuds, smartwatch)
- Known stationary devices encountered repeatedly at the same location

## Privacy Considerations

- No MAC addresses are stored — only daily-rotating hashes
- No data about encountered devices leaves the phone
- Encounter records store signal patterns, not device identifiers
- The daily salt rotation means yesterday's encounters cannot be correlated with today's

## Battery Optimization

- BLE scanning only runs during active adventure sessions (user explicitly starts/stops)
- Scan intervals are tuned to balance detection quality vs battery drain
- The scanner uses low-power scan mode where possible
- Background scanning is never performed without user awareness
