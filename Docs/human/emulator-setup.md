# Firebase Emulator testing

The package ships two emulator-backed test targets, hosted by an XcodeGen-managed project at `Tests/EmulatorTests/`:

- **`ModaalFirebaseSmokeTests`** — one minimal round-trip per wrapper, proving each wrapper class forwards to Firebase correctly.
- **`ModaalFirebaseIntegrationTests`** — service-level round-trip coverage (Firestore / Auth / Cloud Storage / Remote Config) through the public protocol surface.

These run **hosted by `EmulatorTestHost.app`** — Firebase's initializers reach into LaunchServices and crash inside a bare xctest bundle without a host. SPM has no concept of a test host app, so the hosted project is a necessary layer on top of the SPM package.

Neither target appears in the default SPM build graph; they only run via `scripts/run-integration-tests.sh`.

## Run locally

```bash
bash scripts/run-integration-tests.sh
```

The script is self-sufficient and idempotent. It:

1. Installs missing prerequisites via Homebrew / npm:
   - `mint`, `node`, `firebase-tools@14` (pinned), and a keg-only `openjdk@21` (the Firebase Emulator requires Java ≥ 21 as of firebase-tools 15).
2. Starts the Firestore / Auth / Storage emulators as a background process.
3. Waits for each emulator port to respond (60 s cap).
4. Discovers the first available iOS Simulator and runs `xcodebuild test` with the smoke + integration targets, passing `MODAAL_EMULATOR_HOST` + port env vars so the harness can configure the SDK.
5. Tears down the emulator on exit (success or failure).

Override the defaults via env:

```bash
EMULATOR_PROJECT=my-proj \
FIRESTORE_PORT=8081 \
bash scripts/run-integration-tests.sh
```

## How the harness works

`Sources/ModaalFirebaseEmulatorSupport/EmulatorHarness.swift` is the **only** place in the test tree that touches Firebase SDK types directly. It:

- Builds a `FirebaseOptions` with bogus (but well-formed) values — no `GoogleService-Info.plist` is committed.
- Calls `FirebaseApp.configure(options:)` once per process (guarded by `NSLock`).
- Points `Firestore.firestore()`, `Auth.auth()`, and `Storage.storage()` at the local emulator via their `useEmulator(...)` / `settings.host` APIs.
- Exposes protocol-typed factories — `makeFirestore() -> FirestoreProtocol`, `makeAuth() -> FirebaseAuthProtocol`, `makeStorage() -> CloudStorageProtocol`. Test bodies bind to these and never import Firebase SDK types.
- Clears state between tests via the emulator REST endpoints (`DELETE /emulator/v1/projects/<projectID>/databases/(default)/documents` and `.../accounts`).

## Not covered

Firebase Emulator Suite has no emulator for **Messaging** or **Remote Config**. For those services:

- Smoke tests exercise the protocol surface (instantiation + one trivial method call).
- Integration tests for Remote Config use defaults-only (`setDefaults` → `configValue(forKey:)`).

## CI

The `.github/workflows/integration-tests.yml` workflow runs nightly (`0 3 * * *` UTC) and on manual `workflow_dispatch`. It is intentionally **not** wired to PR events — emulator-backed tests add ~2–3 minutes and catch a different class of bug than the unit tests in `scripts/build.sh`, which runs on every PR.
