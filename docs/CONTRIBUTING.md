# Contributing to Ez Dozit

Thank you for wanting to help build something that matters. Ez Dozit is a gift to a community that has been underserved by most technology designed to "help" them. The care we put into this code is the care we're putting into their lives.

## Before You Start

Please read [DESIGN_PRINCIPLES.md](DESIGN_PRINCIPLES.md). Every contribution should align with the project's core philosophy. If you're unsure whether a change fits, open an issue to discuss it first.

## Building the Project

### Requirements

- Android Studio (latest stable)
- JDK 17 or higher
- Android SDK with API 36

### Setup

```bash
git clone https://github.com/your-username/ezdozit.git
cd ezdozit
./gradlew assembleDebug
```

### Running Tests

```bash
# Unit tests
./gradlew testDebugUnitTest

# Lint checks
./gradlew lintDebug
```

## How to Contribute

1. **Find or create an issue** describing the change you want to make
2. **Fork the repository** and create a branch from `main`
3. **Make your changes** following the code style below
4. **Write tests** for any new logic
5. **Run all tests** and fix any failures
6. **Submit a pull request** with a clear description of what and why

## Code Style

- Follow [Kotlin official style](https://kotlinlang.org/docs/coding-conventions.html)
- Use Coroutines for all async work — no callback chains
- Use sealed classes for state representation in ViewModels
- Write Compose previews for every composable
- Use meaningful variable names — this code will be read by people who care about the mission
- Add comments where the "why" isn't obvious, especially in the BLE module
- All user-facing strings go in `strings.xml` for localization

## What Makes a Good Contribution

- **Bug fixes** with a test that reproduces the bug
- **Accessibility improvements** — making the app usable by more people
- **Localization** — translating strings.xml to new languages
- **Documentation** — improving clarity, fixing errors, adding examples
- **Art assets** — pixel art for Ez, the bird, Haven icons (see art requirements in docs)
- **Battery optimization** — making the BLE and location systems more efficient

## What to Avoid

- Features that add network communication or data transmission
- Gamification mechanics that create pressure (streaks, leaderboards, penalties)
- Dependencies on Google Play Services
- Proprietary or restrictively-licensed dependencies
- Changes that weaken privacy guarantees

## Code of Conduct

Be kind. The people who use this app are often having the hardest days of their lives. The people who build it should treat each other with the same gentleness we want the app to embody.
