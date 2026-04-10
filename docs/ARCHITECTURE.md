# Architecture

Ez Dozit follows an MVVM architecture with clean separation between data, domain, and UI layers. All async work uses Kotlin Coroutines and Flow.

## Package Structure

```
org.ezdozit.app
├── data/          # Room database, entities, DAOs, repositories
├── domain/        # Use cases and domain models
├── ui/            # Compose screens, theme, navigation
├── ble/           # BLE scanning and proximity detection
├── location/      # Location tracking and tile system
├── map/           # MapLibre integration and fog-of-war rendering
└── game/          # Game loop, achievements, Ez character system
```

### Data Layer (`data/`)

The data layer owns all persistent storage. It uses Room (SQLite) for structured data and DataStore for preferences. All data stays on the device — there is no network layer.

Key entities:
- `ExploredTile` — chunks of map the user has revealed
- `Haven` — user-tagged safe places
- `AdventureSession` — a single outing with route and stats
- `Encounter` — a detected BLE proximity event
- `DailyReflection` — optional mood check-in

Repositories abstract the DAOs and provide Flow-based APIs to the domain layer.

### Domain Layer (`domain/`)

Pure Kotlin classes with no Android framework dependencies. Contains use cases that orchestrate data access and business logic. This layer is independently testable.

### UI Layer (`ui/`)

Jetpack Compose screens with ViewModels. State is represented using sealed classes and exposed as StateFlow. The UI observes state and renders declaratively.

### BLE Layer (`ble/`)

The technically novel part of the app. Runs BLE scans during active adventure sessions to detect nearby people based on motion patterns in Bluetooth signal strength. See [BLE_DETECTION.md](BLE_DETECTION.md) for details.

### Location Layer (`location/`)

Manages location permissions, GPS tracking, and the tile revelation system. Runs as a foreground service during active sessions with battery-conscious update intervals.

### Map Layer (`map/`)

Integrates MapLibre GL Native for rendering. Handles the fog-of-war overlay, Haven markers, and the custom dark-mode map style.

### Game Layer (`game/`)

Contains the Ez character system, bird companion behaviors, and the achievement engine. Achievement logic is pure Kotlin for easy testing.

## Data Flow

```
User Action → ViewModel → Use Case → Repository → Room/DataStore
                ↑                                        ↓
            StateFlow ← ← ← ← ← ← ← ← ← ← ← ← ← Flow
```

## Key Technologies

| Component | Technology | Why |
|-----------|-----------|-----|
| UI | Jetpack Compose | Modern declarative UI, good for custom drawing |
| Database | Room | Type-safe SQLite, on-device only |
| Maps | MapLibre GL | Open source, no API keys, no Google dependency |
| Background | WorkManager + Foreground Service | Battery-friendly scheduled work + active sessions |
| Async | Coroutines + Flow | Structured concurrency, reactive data |
| DI | Manual (ServiceLocator) | Simple and transparent for now |
| Testing | JUnit 4 + MockK | Standard Android testing stack |
