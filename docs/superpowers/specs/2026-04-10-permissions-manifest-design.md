# Task 2: Permissions and Manifest — Design Spec

## Overview

Add all required permission declarations to AndroidManifest.xml and build a centralized PermissionManager that feature screens will use to request permissions contextually with Ez's warm, friendly rationale text.

No permissions are requested at app launch. Each permission is requested only when the feature that needs it is first used.

## Target Platform

- minSdk raised from 26 to 36 (Android 16)
- Only modern permission model (post-API 31 Bluetooth permissions)
- Broader device compatibility deferred to later

## Manifest Changes

### Permissions Declared

| Permission | Purpose | When Requested |
|-----------|---------|---------------|
| `ACCESS_FINE_LOCATION` | Show position on map, reveal tiles | First map open (Task 5/6) |
| `ACCESS_BACKGROUND_LOCATION` | Continue tracking when screen off | After fine location granted, first adventure |
| `BLUETOOTH_SCAN` | Detect nearby BLE devices for encounters | First adventure start (Task 4) |
| `BLUETOOTH_CONNECT` | Identify user's paired devices to ignore | First adventure start (Task 4) |
| `ACTIVITY_RECOGNITION` | Optional step counting | When user enables step tracking (Task 8) |
| `FOREGROUND_SERVICE` | Keep adventure session alive | Automatic (normal permission, no prompt) |
| `FOREGROUND_SERVICE_LOCATION` | Foreground service type for location | Automatic (no prompt) |
| `POST_NOTIFICATIONS` | Show "Ez is exploring with you" during sessions | First adventure start |

### Additional Manifest Entries

- `<uses-feature android:name="android.hardware.bluetooth_le" android:required="false" />` — BLE not required, app still installable on devices without it
- No `INTERNET` permission — enforces privacy-first at the manifest level

## Architecture

### Package: `org.ezdozit.app.permissions`

#### AppPermission.kt — Enum of all app permissions

Each entry holds:
- The Android permission string(s) needed
- Ez's rationale message (warm friend tone, shown before system dialog)
- A "denied" message (gentle, with Settings redirect hint)
- Whether it's required or optional for the feature

Permissions defined:
- `FineLocation` — "Hey, I need to know where we are so I can show you the map. Mind sharing your location?"
- `BackgroundLocation` — "To keep tracking your adventure when the screen is off, I need background location access. You're in control — you can turn this off anytime."
- `BluetoothScan` — "I use Bluetooth to notice when people are nearby — it's how encounters work! Can I turn on scanning?"
- `BluetoothConnect` — "I'd like to check your paired devices so I can ignore things like your earbuds. Cool?"
- `ActivityRecognition` — "Want me to count your steps while we explore? I'll need access to your activity data for that."
- `Notifications` — "I'd like to let you know when I'm exploring with you. Mind if I send notifications?"

#### PermissionManager.kt — Core check/request logic

- `fun check(permission: AppPermission): PermissionStatus` — checks current grant state
- Works with Activity Result API (`registerForActivityResult`) under the hood
- Handles the full flow: check → show rationale if needed → request → return result

#### PermissionStatus — Sealed class

- `Granted` — permission granted
- `NotRequested` — never asked
- `Denied` — user said no, can ask again
- `PermanentlyDenied` — "don't ask again" checked, must redirect to Settings

#### PermissionUI.kt — Compose helpers

- `EzRationaleDialog` — friendly dialog with Ez's rationale text and Grant/Not Now buttons
- `EzDeniedDialog` — shown when permanently denied, with Open Settings button
- `rememberPermissionRequest()` — composable that feature screens call to handle the full permission flow

## Testing

- Unit tests verify each `AppPermission` maps to correct Android permission strings
- Unit tests verify rationale and denied text exists for every permission entry
- Unit tests verify `PermissionStatus` sealed class covers all states
- Visual UI testing deferred to emulator when features are wired up in later tasks

## Design Principles Alignment

- **Privacy is absolute:** No INTERNET permission. Permissions explained honestly.
- **No shame mechanics:** Denied messages are gentle, never guilt-inducing.
- **Gentle over gamified:** Rationale uses warm friend tone, not urgency or pressure.
- **Contextual only:** No upfront permission requests. Each asked when feature needs it.
