# Firebase Emulator testing

ModaalFirebase ships first-class support for running against the local Firebase Emulator Suite — no `import Firebase*` in your app code.

## In your app

Two wrapper-library APIs do the heavy lifting. Both are drop-in substitutes for the equivalent Firebase SDK incantations — if you've done emulator setup with raw Firebase before, these are the same calls with the `import Firebase*` elided.

| What you want | Standard Firebase | ModaalFirebase |
|---|---|---|
| Configure Firebase in code (no plist) | `FirebaseApp.configure(options: FirebaseOptions(googleAppID: …, gcmSenderID: …))` | `ModaalFirebase.shared.configure(options: ModaalFirebaseOptions(googleAppID: …, gcmSenderID: …))` |
| Firestore against the emulator | Set `Firestore.firestore().settings = …` (host / SSL / cache) | `FirestoreWrapper.makeDefault(emulator: (host: "localhost", port: 8080))` |
| Auth against the emulator | `Auth.auth().useEmulator(withHost: "localhost", port: 9099)` | `FirebaseAuthWrapper.makeDefault(emulator: (host: "localhost", port: 9099))` |
| Storage against the emulator | `Storage.storage().useEmulator(host: "localhost", port: 9199)` | `CloudStorageWrapper.makeDefault(emulator: (host: "localhost", port: 9199))` |

Behind the scenes:

- **`ModaalFirebase.configure(options:)`** (in `ModaalFirebaseCore`) — no `GoogleService-Info.plist` required. Emulator project IDs start with `demo-`; the rest of the fields can be bogus but well-formed.
- **`makeDefault(emulator:)`** on `FirestoreWrapper`, `FirebaseAuthWrapper`, and `CloudStorageWrapper` — wraps the default SDK instance and (when the tuple is non-nil) routes it through the local emulator. Pass no tuple (`makeDefault()`) for production setups.

```swift
import ModaalFirebaseCore
import ModaalFirestore
import ModaalFirebaseAuth
import ModaalCloudStorage

ModaalFirebase.shared.configure(options: ModaalFirebaseOptions(
  googleAppID: "1:1234567890:ios:abcdef1234567890abcdef",
  gcmSenderID: "1234567890",
  apiKey: "A" + String(repeating: "z", count: 38),
  projectID: "demo-modaal",
  storageBucket: "demo-modaal.appspot.com"
))

let firestore = FirestoreWrapper.makeDefault(emulator: (host: "localhost", port: 8080))
let auth      = FirebaseAuthWrapper.makeDefault(emulator: (host: "localhost", port: 9099))
let storage   = CloudStorageWrapper.makeDefault(emulator: (host: "localhost", port: 9199))
```

See [`Examples/RunnableDemo/`](../../Examples/RunnableDemo/) for a full SwiftUI app built on top of these two APIs.

**Not covered by the Firebase Emulator Suite:** Messaging and Remote Config. `FirebaseMessagingWrapper.makeDefault()` and `FirebaseRemoteConfigWrapper.makeDefault()` still wrap the default SDK instances (no `import Firebase*` required) — there's just no emulator endpoint to point them at. Smoke tests exercise the protocol surface; Remote Config integration tests use defaults only (`setDefaults` → `configValue(forKey:)`).

## Running the package's own emulator tests

The package ships two sibling test source sets under `Tests/`:

- `Tests/ModaalFirebaseSmokeTests/` — minimal round-trip per wrapper family.
- `Tests/ModaalFirebaseIntegrationTests/` — per-service round-trips (Firestore / Auth / Cloud Storage / Remote Config) through the public protocol surface.

Both source sets are compiled into a **single** XcodeGen-managed test target, `ModaalFirebaseEmulatorTests`, at `Tests/EmulatorTests/EmulatorTests.xcodeproj`. The combined target is hosted by a tiny `EmulatorTestHost.app`: Firebase's initializers reach into LaunchServices at startup and crash inside a bare xctest bundle — SPM has no notion of a test-host app, which is why the XcodeGen project exists. Splitting smoke vs. integration into two bundles would also double-link the Firebase static xcframeworks, so they share one bundle.

Neither source set appears in the default SPM build graph — they run only via `scripts/run-integration-tests.sh`.

## Run the emulator tests locally

```bash
bash scripts/run-integration-tests.sh
```

The script is self-sufficient and idempotent. It:

1. Installs missing prerequisites via Homebrew / npm — `mint`, `node`, `firebase-tools@14` (pinned), and keg-only `openjdk@21` (the Firebase Emulator requires Java ≥ 21 as of firebase-tools 15).
2. Starts the Firestore / Auth / Storage emulators as a background process.
3. Waits for each emulator port to respond (60 s cap).
4. Discovers the first available iOS Simulator, boots it, and injects `MODAAL_EMULATOR_HOST` + port env vars via `xcrun simctl spawn … launchctl setenv` so they propagate to the test host process.
5. Generates the `EmulatorTests.xcodeproj` with XcodeGen and runs `xcodebuild test` against it.
6. Tears the emulator down on exit (success or failure).

Override the defaults via env:

```bash
EMULATOR_PROJECT=my-proj \
FIRESTORE_PORT=8081 \
bash scripts/run-integration-tests.sh
```

## How the harness works

`Tests/EmulatorTests/Shared/EmulatorHarness.swift` is the shared test helper. It contains no `import Firebase*` — all Firebase setup lives in [`EmulatorTestHost/EmulatorTestHostApp.swift`](../../Tests/EmulatorTests/EmulatorTestHost/EmulatorTestHostApp.swift), which configures Firebase (once, on the main thread) during host-app init using `ModaalFirebase.configure(options:)` and the `makeDefault(emulator:)` factories.

The harness itself provides:

- Protocol-typed factories — `makeFirestore() -> FirestoreProtocol`, `makeAuth() -> FirebaseAuthProtocol`, `makeStorage() -> CloudStorageProtocol`. Test bodies bind to these and never import Firebase SDK types.
- `skipIfDisabled()` — throws `XCTSkip` when `MODAAL_EMULATOR_HOST` is not set, letting the target still compile in non-emulator contexts.
- `resetEmulatorState()` — clears Firestore documents and Auth accounts between tests via the emulator REST endpoints (`DELETE /emulator/v1/projects/<projectID>/databases/(default)/documents`, `.../accounts`). Storage state is left in place; tests use unique paths per case.

## CI

`.github/workflows/integration-tests.yml` runs nightly (`0 3 * * *` UTC) and on manual `workflow_dispatch`. It is intentionally **not** wired to PR events — emulator-backed tests add ~2–3 minutes and catch a different class of bug than the unit tests in `scripts/build.sh`, which run on every PR.
