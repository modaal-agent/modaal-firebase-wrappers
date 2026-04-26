# Consumption Patterns

How to *use* ModaalFirebase from app code. Library-implementation patterns (how wrappers are designed and built) live in [`CONTRIBUTING.md`](../../CONTRIBUTING.md).

## Construction — `makeDefault()`

Every entry-point wrapper exposes a `makeDefault()` static factory that wraps the default Firebase SDK instance. Consumer code never needs `import Firebase*` to construct a wrapper.

```swift
import ModaalFirestore
import ModaalFirebaseAuth
import ModaalCloudStorage

let firestore: FirestoreProtocol     = FirestoreWrapper.makeDefault()
let auth:      FirebaseAuthProtocol  = FirebaseAuthWrapper.makeDefault()
let storage:   CloudStorageProtocol  = CloudStorageWrapper.makeDefault()
```

**Services with a Firebase Emulator** (Firestore, Auth, Cloud Storage) take an optional `emulator: (host: String, port: Int)?` overload:

```swift
let firestore = FirestoreWrapper.makeDefault(emulator: (host: "localhost", port: 8080))
let auth      = FirebaseAuthWrapper.makeDefault(emulator: (host: "localhost", port: 9099))
let storage   = CloudStorageWrapper.makeDefault(emulator: (host: "localhost", port: 9199))
```

**Services without an emulator** (Messaging, Remote Config) have a bare factory:

```swift
let messaging    = FirebaseMessagingWrapper.makeDefault()
let remoteConfig = FirebaseRemoteConfigWrapper.makeDefault()
```

**Direct-conformance services** (Crashlytics) put the factory on the protocol with a `where Self == ConcreteFirebaseType` constraint. Call via implicit-member syntax with an explicit expected-type context:

```swift
let crashlytics: FirebaseCrashlyticsProtocol = .makeDefault()
```

**Analytics** ships a parameterless concrete wrapper (`FirebaseAnalyticsWrapper()`) — `Analytics` from the Firebase SDK has no instance to wrap; it's all static methods.

**Need a non-default instance?** (custom `FirebaseApp`, a pre-configured handle, etc.) Use the wrapper's public `init(...)` directly — that path requires `import Firebase*` for the SDK type name, but only at the composition root:

```swift
import FirebaseFirestore  // composition root only
import ModaalFirestore

let secondary: FirestoreProtocol = FirestoreWrapper(firestore: Firestore.firestore(app: secondaryApp))
```

## Two-tier API surface {#two-tier-api-surface}

ModaalFirebase exposes its API in two tiers:

1. **Protocol declarations** are 1:1 with `firebase-ios-sdk` — same parameter labels, same method names, same overload shapes — modulo two safety carve-outs:
   - `Result<…, Error>` completion shape instead of `(value, error)` two-param closures.
   - Required `completion:` handler with no `nil` default (silent error suppression is prevented).
2. **Swift-idiomatic extensions** atop the protocols add ergonomic forms — `MergeOption` enum, labeled `child(path:)`, `getDownloadURL` aliased over `downloadURL`, `canHandleOpenUrl` aliased over `canHandle`, etc. They delegate to the canonical method.

**Mocks reflect the protocol layer only** — Sourcery doesn't generate from extensions. Tests stub the canonical handlers (`setDataDocumentDataMergeCompletionHandler`, `childHandler`, `downloadURLHandler`, `canHandleHandler`).

**Both forms work at the call site.** Pick whichever reads better at the use site:

| Canonical (matches Firebase iOS SDK) | Swift-idiomatic (extension) |
|---|---|
| `setData(_:merge: Bool, completion:)` / `setData(_:mergeFields: [Any], completion:)` | `setData(_:mergeOption: MergeOption, completion:)` |
| `child(_ pathString: String)` | `child(path: String)` |
| `downloadURL(completion:)` | `getDownloadURL(completion:)` |
| `canHandle(_ url:)` | `canHandleOpenUrl(_ url:)` |
| `canHandleNotification(_:)` | `canHandleRemoteNotification(_:)` |

When migrating raw Firebase code, prefer the canonical form — code lifts over with the `import` swap and the protocol-typing of injected dependencies, no signature rewrites.

## Iterating query snapshots {#iterating-query-snapshots}

`QuerySnapshotProtocol.documents` returns `[QueryDocumentSnapshotProtocol]` — a refining protocol that overrides the parent `DocumentSnapshotProtocol`'s optional `data() -> [String: Any]?` with a non-optional `data() -> [String: Any]`. This mirrors Firebase iOS SDK's `QueryDocumentSnapshot : DocumentSnapshot` class hierarchy and restores the type-level existence guarantee.

```swift
// Parent — getDocument returns DocumentSnapshotProtocol; data may not exist.
ref.getDocument { result in
  if case .success(let snapshot) = result {
    if let data = snapshot.data() { ... }   // optional — guard required
  }
}

// Refined — query results yield QueryDocumentSnapshotProtocol; data is by definition present.
query.getDocuments { result in
  if case .success(let snapshot) = result {
    for doc in snapshot.documents {         // [QueryDocumentSnapshotProtocol]
      let data: [String: Any] = doc.data()  // non-optional — no guard let
      ...
    }
  }
}
```

`DocumentChangeProtocol.document` is also typed `QueryDocumentSnapshotProtocol` — change events always reference an existent query-context document.

Cursor positions on `QueryProtocol` (`start(atDocument:)`, `start(afterDocument:)`, `end(atDocument:)`, `end(beforeDocument:)`) keep accepting the parent `DocumentSnapshotProtocol` — they're position markers, callers may legitimately pass a `getDocument`-derived snapshot.

## Combine layer — when to prefer {#combine-layer}

For any Combine-based architecture (CombineRIBs, MVVM with Combine bindings), prefer Combine variants throughout. Inventory:

- **4 streaming publishers**: `Query.snapshotPublisher`, `DocumentReference.snapshotPublisher`, `Auth.authStateDidChangePublisher`, `RemoteConfig.configUpdatePublisher`.
- **~43 `Future<T, Error>` one-shot methods** across all services.

Migration shapes:

- `addSnapshotListener { result in … }` + manual `registration?.remove()` → `snapshotPublisher().sink { … }.store(in: &cancellables)`
- `addStateDidChangeListener` + manual `removeStateDidChangeListener(handle)` → `authStateDidChangePublisher().sink { … }.store(in: &cancellables)`
- Completion-handler `setData` / `getDocument` / `putData` → `Future<…, Error>` chaining

**Cancellable retention is the lifecycle binding.** Storing the `AnyCancellable` keeps the subscription alive; dropping it cancels and tears down the underlying listener. This is *intended* — it forces the consumer to bind the listener to a parent's lifecycle (worker, view model, builder) rather than orphaning it. Compare to `addSnapshotListener` which returns a `ListenerRegistrationProtocol` that can be silently dropped without any compile-time consequence.

Combine extensions are protocol default implementations, so they work with both real wrappers and mock objects.

## Escape hatches

Every entry-point wrapper exposes the underlying Firebase type as a `public` property. Use this for APIs not yet covered by the wrapper:

```swift
import FirebaseFirestore  // explicit opt-in to raw Firebase types — composition root only
import ModaalFirestore

let wrapper = FirestoreWrapper.makeDefault()

// Wrapped API (no Firebase import needed)
wrapper.collection("users").document("alice").getDocument { ... }

// Escape hatch for unwrapped API (call site must `import FirebaseFirestore`)
wrapper.firestore.settings.isPersistenceEnabled = false
wrapper.firestore.clearPersistence { error in ... }
```

Each escape-hatch use is a coverage gap — see [`coverage.md`](coverage.md) for what's wrapped and what isn't, and consider filing a request for new coverage.

## Testing — mocks

Every protocol has a Sourcery-generated mock in `ModaalFirebaseMocks`. Import via `@testable`:

```swift
@testable import ModaalFirebaseMocks
import ModaalFirestore
import XCTest

final class MyTests: XCTestCase {
  func testSomething() {
    let mock = FirestoreProtocolMock()
    mock.collectionHandler = { _ in CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock()) }
    let sut = MyViewModel(firestore: mock)
    // assert against sut
  }
}
```

**Compose mocks with mocks; wrappers with wrappers.** The wrappers' protocol-to-concrete bridging uses `as!` force-casts internally — this is safe in production because only our wrappers implement these protocols. Passing a `DocumentReferenceProtocolMock` (or `FirebaseUserProtocolMock`, etc.) into a real `WriteBatchWrapper` / `TransactionWrapper` / `FirebaseAuthWrapper` method that expects a sub-protocol triggers an `as!` failure inside the wrapper at runtime. Mock the *entry-point* protocol (`WriteBatchProtocol`, `TransactionProtocol`, `FirebaseAuthProtocol`) directly — never an intermediate. See [`anti-patterns.md`](anti-patterns.md).

**Snapshot mock construction.** Sourcery-generated `QueryDocumentSnapshotProtocolMock` and `DocumentSnapshotProtocolMock` require `metadata:` and `reference:` at construction but expose `documentID` / `exists` as bare `var` defaults. Convenience `static func make(...)` factories live in `Sources/ModaalFirebaseMocks/Helpers/QueryDocumentSnapshotProtocolMock+Make.swift` to shorten the call site:

```swift
let snapshot = QueryDocumentSnapshotProtocolMock.make(documentID: "alice", exists: true)
```

These helpers are `internal` and reachable through `@testable import ModaalFirebaseMocks`.
