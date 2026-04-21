# EmulatorTests

XcodeGen-managed project that hosts the Firebase Emulator–backed tests.

The two test source sets live alongside the SPM tests:

- `Tests/ModaalFirebaseSmokeTests/` — one minimal round-trip per wrapper family.
- `Tests/ModaalFirebaseIntegrationTests/` — per-service round-trips (Firestore / Auth / Cloud Storage / Remote Config) through the public protocol surface.

Both source sets compile into a **single** XcodeGen target, `ModaalFirebaseEmulatorTests`, hosted by `EmulatorTestHost.app`. Two reasons for the hosted-app + combined-bundle layout:

1. Firebase's initializers reach into LaunchServices (`+[LSApplicationProxy bundleProxyForCurrentProcess]`) at startup; running inside a bare xctest bundle raises `NSInternalInconsistencyException: bundleProxyForCurrentProcess is nil`. SPM has no notion of a test-host app, hence this separate project.
2. Splitting smoke vs. integration into two bundles would double-link the Firebase static xcframeworks into the host + each bundle. Keeping them combined sidesteps the conflict. Tests are distinguished by class-name convention (`FirebaseXxxSmokeTests` vs. `XxxIntegrationTests`).

The shared harness at `Shared/EmulatorHarness.swift` has zero `import Firebase*` — all Firebase configuration happens in `EmulatorTestHost/EmulatorTestHostApp.swift` via `ModaalFirebase.configure(options:)` + `makeDefault(emulator:)` factories.

## Run

Use the script:

```bash
bash scripts/run-integration-tests.sh
```

It installs prerequisites, generates this project, starts the emulator, runs the combined target, and tears the emulator down on exit.
