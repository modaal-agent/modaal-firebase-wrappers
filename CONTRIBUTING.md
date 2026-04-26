# Contributing

This guide is for **contributors to the wrapper library itself**. If you're consuming the library in an app, see [Getting Started](Docs/human/getting-started.md) and the [agent-facing usage docs](Docs/agent/index.md) instead.

## Development Rules

1. **Every new wrapped service ships as a complete PR:** protocol + wrapper + Combine extensions + SampleApp usage + documentation updates. Partial PRs are rejected.

2. **No raw Firebase types in any protocol surface** (return or parameter). Violations are a review-blocker. Use mirrored enums for Firebase-specific types.

3. **No `import Combine` in protocol files.** Combine extensions live in `Sources/<Module>/Combine/`.

4. **Follow the established template.** New wrappers model after Auth (wrapper class pattern) or Crashlytics (direct conformance pattern). Deviate only when the service's shape genuinely requires it.

5. **Update `Docs/agent/coverage.md`** in the same PR that adds or modifies a service wrapper.

6. **Keep the SampleApp working.** Every PR that touches the public API must update the SampleApp usage file and verify it still builds.

7. **Keep CI green.** Run `./scripts/build.sh` before pushing. Breakages on main block all PRs until fixed.

## Building

```bash
./scripts/build.sh
```

This runs three steps:
1. Build all library targets
2. Generate and build the SampleApp (XcodeGen + xcodebuild)
3. Run tests

## Project Structure

```
Sources/<Module>/
├── Protocols/     # Protocol definitions (no Firebase imports)
├── Combine/       # Combine extensions (Future, AnyPublisher)
├── Wrappers/      # Firebase SDK bridging
├── Extensions/    # Swift-idiomatic protocol extensions (sugar over canonical)
└── Types/         # Mirrored enums, value types
```

## Code Style

- Copyright header: `// Copyright (c) 2026 Modaal.dev`
- MIT license reference in header
- `public` on protocols, entry-point wrappers, and types
- `internal` (default) on sub-wrappers
- Completion handlers use `Result<T, Error>`
- Combine extensions use `Future<T, Error>` (one-shot) or `AnyPublisher<T, Error>` (streaming)

---

## Wrapper Implementation Patterns

### Protocol Design

1. **One protocol per Firebase class.** `FirestoreProtocol` wraps `Firestore`, `DocumentReferenceProtocol` wraps `DocumentReference`, etc.

2. **Protocol inheritance mirrors SDK class hierarchy.** `CollectionReferenceProtocol: QueryProtocol` mirrors `CollectionReference: Query`. `QueryDocumentSnapshotProtocol: DocumentSnapshotProtocol` mirrors `QueryDocumentSnapshot : DocumentSnapshot`.

3. **Completion handlers with `Result`.** All async methods use `completion: @escaping (Result<T, Error>) -> Void)` — not the Firebase SDK's `(T?, Error?)` pattern. This is safer and more Swift-idiomatic.

4. **No raw Firebase types in protocol surfaces.** Return types and parameters use wrapper protocols or mirrored types. The only Firebase import is in wrapper implementation files.

5. **Mirrored enums for SDK-specific types.** `FirestoreSource`, `DocumentChangeType`, `FirestoreAggregateSource`, `ModaalRemoteConfigFetchStatus`, etc. — so consumers don't need `import Firebase*`.

6. **Protocol extensions for convenience overloads.** Default parameter values can't go on protocol requirements, so they live as protocol extensions. The same mechanism hosts the Swift-idiomatic ergonomic forms (see [Two-tier API surface](#two-tier-api-surface) below).

### Wrapper Classes

1. **Entry-point wrappers are `public final class`.** `FirestoreWrapper`, `FirebaseAuthWrapper`, `CloudStorageWrapper`, etc. They expose the underlying Firebase type as a `public let` property (escape hatch).

2. **Sub-wrappers are `internal final class`.** `DocumentReferenceWrapper`, `QueryWrapper`, etc. Created by entry-point wrappers, never by consumers.

3. **`QueryWrapper` is `class` (not `final`).** `CollectionReferenceWrapper` subclasses it, mirroring the SDK's `CollectionReference: Query` relationship.

4. **Force-cast for protocol-to-concrete bridging.** When a protocol method accepts a protocol type but the wrapper needs the concrete Firebase type:
   ```swift
   let docRef = (document as! DocumentReferenceWrapper).documentRef
   ```
   This is safe because only our wrappers implement these protocols in production. Consumers must NOT mix mocks with real wrappers (see [Docs/agent/anti-patterns.md § Compose mocks with mocks](Docs/agent/anti-patterns.md)).

5. **Direct extension conformance** when the Firebase class already satisfies the protocol:
   ```swift
   extension FirebaseAuth.UserMetadata: FirebaseUserMetadataProtocol {}
   extension FirebaseFirestore.SnapshotMetadata: SnapshotMetadataProtocol {}
   extension FirebaseCrashlytics.Crashlytics: FirebaseCrashlyticsProtocol {}
   ```

6. **Static `makeDefault()` factory** on every entry-point wrapper — mandatory, not optional. Saves consumers from `import Firebase*` at the construction site.

   **Services with an emulator** (Firestore, Auth, Cloud Storage) take an optional `emulator: (host: String, port: Int)?` tuple:
   ```swift
   public static func makeDefault(emulator: (host: String, port: Int)? = nil) -> MyServiceWrapper {
     let sdk = MyService.myService()
     if let emulator {
       sdk.useEmulator(withHost: emulator.host, port: emulator.port)
     }
     return MyServiceWrapper(sdk: sdk)
   }
   ```
   **Services without an emulator** (Messaging, Remote Config) have a bare factory — no tuple parameter:
   ```swift
   public static func makeDefault() -> MyServiceWrapper {
     MyServiceWrapper(sdk: MyService.myService())
   }
   ```
   **Direct-conformance services** (Crashlytics) put the factory on the protocol with a `where Self == ConcreteFirebaseType` constraint, returning `Self`. Consumers call it via implicit-member syntax:
   ```swift
   public extension FirebaseCrashlyticsProtocol where Self == FirebaseCrashlytics.Crashlytics {
     static func makeDefault() -> Self { Crashlytics.crashlytics() }
   }
   // Call site:
   let crashlytics: FirebaseCrashlyticsProtocol = .makeDefault()
   ```

   Wrapper-class factories live on the concrete class (not the protocol) so existing `Sourcery`-generated mocks in `ModaalFirebaseMocks` aren't invalidated. The emulator tuple is deliberately compact; promote to a dedicated options struct only if it grows beyond `host` + `port`.

### Type Conversions

Internal extensions on Modaal types convert to Firebase SDK types:

```swift
// In FirestoreTypeConversions.swift
extension FieldPath {
  var asFirestoreFieldPath: FirebaseFirestore.FieldPath { ... }
}

extension Filter {
  var asFirestoreFilter: FirebaseFirestore.Filter { ... }
}
```

These are `internal` — not visible to consumers.

### Combine Layer

Protocol extensions in `Sources/<Module>/Combine/` provide FirebaseCombineSwift-compatible API:

1. **`Future<T, Error>` for one-shot operations.** Wraps the completion-handler method:
   ```swift
   func signInAnonymously() -> Future<FirebaseAuthDataResultProtocol, Error> {
     Future { promise in self.signInAnonymously { promise($0) } }
   }
   ```

2. **`AnyPublisher<T, Error>` for streaming.** Uses `PassthroughSubject` with lazy subscription:
   ```swift
   func snapshotPublisher(includeMetadataChanges: Bool = false) -> AnyPublisher<DocumentSnapshotProtocol, Error> {
     let subject = PassthroughSubject<DocumentSnapshotProtocol, Error>()
     var registration: ListenerRegistrationProtocol?
     return subject
       .handleEvents(
         receiveSubscription: { _ in
           registration = self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { ... }
         },
         receiveCancel: { registration?.remove() }
       )
       .eraseToAnyPublisher()
   }
   ```

3. **Works with mocks for free.** Combine extensions are protocol default implementations — mock objects get them automatically; the `Future` calls the mock's completion-handler implementation.

### Two-tier API surface {#two-tier-api-surface}

**Hard rule for code review.** Protocol *declarations* are 1:1 with `firebase-ios-sdk` — same parameter labels, same method names, same overload shapes — modulo two safety carve-outs (`Result<…, Error>` completion shape; required `completion:` handler with no `nil` default). Any other divergence is a wrapper bug.

Swift-idiomatic ergonomic forms — `MergeOption` enum, labeled `child(path:)`, `getDownloadURL` aliased over `downloadURL`, `canHandleOpenUrl` aliased over `canHandle`, etc. — live as protocol *extensions* atop the canonical surface, in `Sources/<Module>/Extensions/`. They delegate to the canonical method.

Why the split:

- **Mocks stay 1:1 with Firebase.** Sourcery only generates from protocol declarations, not extensions. `MockDocumentReferenceProtocol` mirrors Firebase exactly. No doubled mock surface.
- **Modaal-side docs stay simple.** Only the canonical Firebase surface is documented in the `modaal-agent` KB. Agents migrating consumer code can lift raw-Firebase code unchanged.
- **Power users get sugar.** The wrapper repo's own consumer-facing docs surface the extensions as Swift-idiomatic alternatives.

**Adding a new wrapper protocol method?** Look up the Firebase signature first. If you can't justify a divergence on safety grounds, mirror the signature exactly. If a Swift-idiomatic ergonomic shape is desirable, add it as an extension (delegating to the canonical method) — never as a parallel protocol declaration. Wrapper-style aliases declared on the protocol get reverted in PR review.

---

## Library-side anti-patterns

These rules apply to **wrapper-library development**. Consumer-side anti-patterns live in [Docs/agent/anti-patterns.md](Docs/agent/anti-patterns.md).

### Protocol Design

- **Never expose raw Firebase types in protocol surfaces.** No `CollectionReference`, `DocumentSnapshot`, `StorageReference` etc. in protocol method signatures. Always use the corresponding wrapper protocol. This is a review-blocker.

- **Never add `import Firebase*` to protocol files.** Protocol definitions must be Firebase-free. Only wrapper implementation files import Firebase.

- **Never add `import Combine` to protocol files.** Combine extensions live in separate `Combine/` directory files, not in protocol definitions.

- **Never declare wrapper-idiomatic methods on the *protocol* that diverge from Firebase iOS SDK signatures.** The protocol layer is 1:1 with `firebase-ios-sdk` (modulo the documented safety carve-outs). Swift-idiomatic ergonomic forms belong in protocol *extensions* under `Sources/<Module>/Extensions/`, where they delegate to the canonical Firebase-shaped protocol method. Wrapper-style aliases declared on the protocol get reverted in code review.

### Wrapper Implementation

- **Never create umbrella facades.** No `ModaalFirebase.auth`, `ModaalFirebase.firestore` etc. Each module is independent. Consumers compose what they need.

- **Never port RIBs-specific code.** Workers, Interactors, `Working` protocols — these stay in the consumer app. This library is architecture-agnostic.

- **Never add the `-ObjC` linker flag to the library.** This is the consumer app's responsibility. Document it in getting-started.md instead.

- **Never swallow errors silently.** Always propagate errors through `Result.failure` or `completion(.failure(...))`. Use `NSError(domain: "Unknown error", code: -1)` only as a last resort when Firebase returns nil for both result and error.

### Dependencies

- **Never depend on `FirebaseCore` directly.** The xcframeworks package doesn't expose it as a standalone product. `ModaalFirebaseCore` depends on `FirebaseAnalytics` (which bundles `_FirebaseCore` internally).

- **Never use the internal package name `"Firebase"` in SPM.** SPM 5.9 uses URL-derived identity: `"firebase-ios-sdk-xcframeworks"`.

### Testing & Verification

- **Never ship a module without SampleApp coverage.** Every protocol method must be exercised in `Examples/SampleApp/SampleApp/<Module>Usage.swift`.

- **Never skip `./scripts/build.sh`.** It builds library targets, SampleApp, and tests. A module isn't done until this passes.

### Combine Layer

- **Never add Combine methods as protocol requirements.** They are protocol extensions (default implementations). Adding them as requirements would force every mock to implement them.

- **Never use `Deferred` in Combine extensions.** `Future` is intentionally eager (starts on creation, not subscription) — matching FirebaseCombineSwift behavior. The completion-handler method is called immediately.

---

## Adding a New Firebase Service Wrapper

Step-by-step guide for wrapping a new Firebase service (e.g., Firebase Database, Firebase Functions).

### Prerequisites

- Verify the Firebase product exists in `firebase-ios-sdk-xcframeworks` at the current version
- Check if the product name matches the service (e.g., `FirebaseDatabase`, `FirebaseFunctions`)

### Steps

#### 1. Add to Package.swift

```swift
// Add library product
.library(name: "ModaalFirebaseDatabase", targets: ["ModaalFirebaseDatabase"]),

// Add target
.target(
  name: "ModaalFirebaseDatabase",
  dependencies: [
    "ModaalFirebaseCore",
    .product(name: "FirebaseDatabase", package: firebaseSDK),
  ]
),
```

#### 2. Create directory structure

```
Sources/ModaalFirebaseDatabase/
├── Protocols/
│   └── FirebaseDatabaseProtocol.swift
├── Combine/
│   └── Database+Combine.swift
├── Extensions/
│   └── (Swift-idiomatic aliases, if any)
└── Wrappers/
    └── FirebaseDatabaseWrapper.swift
```

#### 3. Define protocols

- One protocol per Firebase class you need to wrap
- Use completion handlers with `Result<T, Error>` — not Firebase's `(T?, Error?)` pattern
- No `import Firebase*` in protocol files
- Mirror any Firebase-specific enums as Modaal types
- Add convenience overloads as protocol extensions (for default parameter values and Swift-idiomatic aliases)

#### 4. Implement wrappers

- Entry-point wrapper: `public final class` with `public let` underlying Firebase type (escape hatch)
- Sub-wrappers: `internal final class`
- Follow the `FirebaseAuthWrapper` template as the canonical example
- Use force-cast (`as!`) for protocol-to-concrete bridging in sub-wrappers
- **Every new wrapper ships a `makeDefault()` static factory** so consumers don't need `import Firebase*` at the construction site. Three shapes, pick the one matching the service:
  - Service with a Firebase Emulator (Firestore / Auth / Storage pattern): `public static func makeDefault(emulator: (host: String, port: Int)? = nil) -> MyWrapper` — wire emulator settings when the tuple is non-nil. See `FirestoreWrapper.makeDefault`.
  - Service without a Firebase Emulator (Messaging / Remote Config pattern): `public static func makeDefault() -> MyWrapper` — no tuple parameter. See `FirebaseMessagingWrapper.makeDefault`.
  - Direct-conformance service (Crashlytics pattern): factory lives on the protocol with `where Self == ConcreteFirebaseType` constraint, returning `Self`. Consumers call via implicit-member syntax: `let x: MyProtocol = .makeDefault()`. See `FirebaseCrashlyticsExtensions.swift`.

#### 5. Add Combine extensions

- `Future<T, Error>` for every completion-handler method
- `AnyPublisher<T, Error>` for any listener/observer-based APIs
- Put in `Combine/` subdirectory

#### 6. Add SampleApp usage

- Create `Examples/SampleApp/SampleApp/<Service>Usage.swift`
- Exercise every protocol method, property, and enum case
- Include a Combine section exercising every `Future` and streaming publisher
- Add wrapper instantiation exercise (`let _: Wrapper.Type = Wrapper.self`)
- Update `Examples/SampleApp/xcodegen.yml` to add the product dependency

#### 7. Verify

```bash
./scripts/build.sh
```

#### 8. Update documentation

- Update `Docs/agent/coverage.md` with the new module's coverage table
- Update `README.md` module table
- Update `CHANGELOG.md`

### Checklist

- [ ] Package.swift updated (product + target)
- [ ] Protocol(s) defined — no raw Firebase types, no Combine imports
- [ ] Wrapper(s) implemented — escape hatch on entry-point wrapper
- [ ] `makeDefault()` factory added (with `emulator:` overload if the service supports a Firebase Emulator; or on the protocol with `where Self == …` for direct-conformance services)
- [ ] Combine extensions added
- [ ] Mirrored types created (if any Firebase enums appear in the protocol surface)
- [ ] SampleApp usage file — 100% method/property/enum coverage + Combine
- [ ] xcodegen.yml updated
- [ ] `./scripts/build.sh` passes
- [ ] `Docs/agent/coverage.md` updated
- [ ] `README.md` module table updated
- [ ] `CHANGELOG.md` updated
