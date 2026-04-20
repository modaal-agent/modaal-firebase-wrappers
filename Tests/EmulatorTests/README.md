# EmulatorTests

XcodeGen-managed project that hosts the Firebase Emulator–backed test targets:

- `ModaalFirebaseSmokeTests` — one per wrapper family
- `ModaalFirebaseIntegrationTests` — per-service round-trips

Both are regular **unit-test bundles hosted by `EmulatorTestHost.app`**. This is required because Firebase's initializers reach into LaunchServices (`+[LSApplicationProxy bundleProxyForCurrentProcess]`) at startup; running inside a bare xctest bundle raises `NSInternalInconsistencyException: bundleProxyForCurrentProcess is nil`. SPM has no notion of test-host apps, hence this separate project.

Sources live alongside the SPM tests at `Tests/ModaalFirebaseSmokeTests/` and `Tests/ModaalFirebaseIntegrationTests/`; this XcodeGen project references them by relative path. The shared harness at `Shared/EmulatorHarness.swift` is included in both test target source sets and is the single place that imports Firebase SDK types.

## Run

Use the script:

```bash
bash scripts/run-integration-tests.sh
```

It generates this project, starts the emulator, runs both test targets, and tears down on exit.
