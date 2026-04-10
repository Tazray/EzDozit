# Ez Dozit

**Turn your neighborhood into an adventure.**

Ez Dozit is a gentle GPS-based exploration game for Android. You walk around your real neighborhood with a pixel character named Ez and a small bird companion. As you move, a fog-of-war map reveals your world. You discover and pin "Havens" — quiet, calming places. You earn points for proximity encounters with other people, detected via Bluetooth Low Energy.

Ez Dozit is designed primarily for people living with anxiety, agoraphobia, PTSD, and serious mental illness — but it's framed as a charming indie adventure game, not a mental health app. No stigma, no clinical framing, just a cozy game that quietly supports its players in expanding their relationship with the outside world.

## Philosophy

- **Privacy is absolute.** All data stays on the device. No cloud sync, no analytics, no telemetry.
- **No streak pressure.** Bad days don't punish you. Returning after time away feels welcoming.
- **Always an escape.** One-tap "Retreat" routes you to your nearest safe space.
- **Gentle over gamified.** Notifications are rare and opt-in. The app never nags.
- **Open source.** AGPL-3.0 licensed. No proprietary dependencies where avoidable.

## Building

### Requirements

- Android Studio (latest stable)
- JDK 17 or higher
- Android SDK with API 36 installed
- No Google Play Services required

### Build from source

```bash
git clone https://github.com/your-username/ezdozit.git
cd ezdozit
./gradlew assembleDebug
```

The debug APK will be at `app/build/outputs/apk/debug/app-debug.apk`.

### Run tests

```bash
./gradlew testDebugUnitTest
```

## Technical Overview

- **Language:** Kotlin
- **UI:** Jetpack Compose with Material 3
- **Min SDK:** 26 (Android 8.0)
- **Maps:** MapLibre GL Native (OpenStreetMap tiles, no Google Maps)
- **Database:** Room (SQLite, all data on-device)
- **Architecture:** MVVM with Coroutines and Flow

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full technical breakdown.

## Documentation

- [Architecture](docs/ARCHITECTURE.md) — package structure and data flow
- [BLE Detection](docs/BLE_DETECTION.md) — how proximity detection works
- [Privacy](docs/PRIVACY.md) — our plain-language privacy statement
- [Contributing](docs/CONTRIBUTING.md) — how to help build Ez Dozit
- [Design Principles](docs/DESIGN_PRINCIPLES.md) — the philosophy behind every decision

## License

Ez Dozit is licensed under the [GNU Affero General Public License v3.0](LICENSE).
