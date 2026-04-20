# SampleApp — Compile-only API surface verification

A **compile-only** SwiftUI app that exercises 100 % of the `ModaalFirebase` public API surface across all 8 service modules. It's never meant to run against Firebase — the goal is to catch API regressions at build time in CI.

`scripts/build.sh` builds this target on every PR. If a wrapper protocol, factory, or Combine extension is renamed, removed, or changes signature, the SampleApp stops compiling and the CI job fails.

For an app that actually runs against the Firebase Emulator, see [`../RunnableDemo/`](../RunnableDemo/).

## Files

Each `…Usage.swift` file imports one ModaalFirebase module and calls every protocol method + Combine extension at least once. The entry point ([`Placeholder.swift`](SampleApp/Placeholder.swift)) is a stub SwiftUI app — it never runs the usage code, but the compiler still type-checks every call site.

| File | Covers |
|---|---|
| `CoreUsage.swift` | `ModaalFirebase.configure()` variants + `ModaalFirebaseOptions` |
| `AuthUsage.swift` | `FirebaseAuthProtocol`, `FirebaseUserProtocol`, credentials, state listeners |
| `FirestoreUsage.swift` | `FirestoreProtocol`, collection/document/query/batch/transaction, snapshot listeners |
| `CloudStorageUsage.swift` | `CloudStorageProtocol`, upload/download/metadata/list |
| `AnalyticsUsage.swift` | `FirebaseAnalyticsProtocol` |
| `CrashlyticsUsage.swift` | `FirebaseCrashlyticsProtocol` (extension conformance on `Crashlytics`) |
| `MessagingUsage.swift` | `FirebaseMessagingProtocol` + FCM token flows |
| `RemoteConfigUsage.swift` | `FirebaseRemoteConfigProtocol`, `RemoteConfigValueProtocol` |

## Regenerate / build manually

```bash
cd Examples/SampleApp
$(brew --prefix)/bin/mint run yonaskolb/XcodeGen xcodegen generate --spec xcodegen.yml
open SampleApp.xcodeproj
```

> Homebrew's `mint` is shadowed by an npm package of the same name — use the absolute `$(brew --prefix)/bin/mint` so the right binary is invoked. `scripts/build.sh` already does this.

## Why keep this next to `RunnableDemo`?

| | SampleApp | RunnableDemo |
|---|---|---|
| Goal | Exhaustive API surface compile check | One end-to-end workflow against the emulator |
| Runs | Never — stub `@main` | iOS Simulator, against local emulator |
| Module coverage | All 8 ModaalFirebase products | Firestore only |
| CI cost | ~30 s (part of every PR) | ~3 min (nightly via `scripts/run-integration-tests.sh`) |
| Breaks when | Public API shape regresses | Firestore wrapper behaviour regresses |

They cover complementary regression classes; the followup plan explicitly calls for keeping both.
