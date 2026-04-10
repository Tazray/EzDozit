# Design Principles

These principles guide every decision in Ez Dozit — from architecture to UI copy to which features we build and which we reject.

## 1. Privacy Is Absolute

All data stays on the device. No cloud sync, no analytics, no telemetry, no crash reporting that leaves the phone. Ever.

The user must be able to trust this app with their location data and emotional state without reservation. This is not a feature we can partially implement or compromise on for convenience. If a feature requires sending data off-device, we don't build that feature.

**In practice:**
- No network permission in the manifest
- No analytics SDKs, not even "privacy-respecting" ones
- No cloud backup of app data
- BLE device addresses are hashed with daily-rotating salts
- The codebase is open source so anyone can verify these claims

## 2. No Streak Pressure, No Shame Mechanics

Bad days do not punish the user. Streaks do not exist. Returning after time away should feel welcoming, never like catching up.

Many of our users have conditions where some days, leaving the house is impossible. The app must never make them feel worse about that. Progress is permanent — the map never decays, achievements never expire, and the app never asks "where have you been?"

**In practice:**
- No streak counters or daily login rewards
- No decay mechanics on explored areas
- Welcome-back messages are warm, never guilt-inducing
- Achievement language is celebratory, never comparative
- No "you missed X days" notifications

## 3. The User Always Has an Escape

A one-tap "Retreat" feature must always be accessible to route the user to their nearest tagged safe space.

For someone having a panic attack, every extra tap is a barrier. The Retreat button is always visible, always one tap, and always routes to the nearest Haven. It's the most important button in the app.

**In practice:**
- Retreat button is persistent on the main screen
- It works offline (routing data cached locally)
- It highlights the nearest Haven with distance and direction
- It never requires confirmation — one tap, immediate response

## 4. Gentle Over Gamified

Notifications are rare and opt-in. The app never nags. It meets the user where they are.

Ez Dozit is not trying to maximize engagement or screen time. It's trying to help people feel safe enough to step outside. Every notification, every nudge, every piece of copy should be evaluated against: "would this feel supportive or would this feel like pressure?"

**In practice:**
- No push notifications by default
- Optional notifications use warm, encouraging language
- No "come back and play!" re-engagement
- Session length is never displayed as a metric to optimize
- The app works perfectly fine if opened once a week

## 5. Open Source From Day One

GPL-3.0 or AGPL-3.0 license. No proprietary dependencies. No Google Play Services dependencies where avoidable. Should be installable from F-Droid eventually.

Open source is how we prove our privacy claims. It's also how we build trust with a community that has been let down by closed systems. And it's how we invite contributors who share this mission.

**In practice:**
- AGPL-3.0 license
- MapLibre instead of Google Maps
- FusedLocationProvider with LocationManager fallback
- All dependencies must be open-source compatible
- Build instructions in README for anyone to compile from source
- F-Droid metadata maintained alongside Play Store assets
