# Wrapper Implementation Patterns

## Protocol Design

1. **One protocol per Firebase class.** `FirestoreProtocol` wraps `Firestore`, `DocumentReferenceProtocol` wraps `DocumentReference`, etc.

2. **Protocol inheritance mirrors SDK class hierarchy.** `CollectionReferenceProtocol: QueryProtocol` mirrors `CollectionReference: Query`.

3. **Completion handlers with `Result`.** All async methods use `completion: @escaping (Result<T, Error>) -> Void)` — not the Firebase SDK's `(T?, Error?)` pattern. This is safer and more Swift-idiomatic.

4. **Protocol extensions for convenience overloads.** Default parameter values can't go on protocol requirements, so they're protocol extensions:
   ```swift
   // Protocol requirement (canonical Firebase iOS SDK signature)
   func setData(_ documentData: [String: Any], merge: Bool, completion: ...)

   // Protocol extension — Swift-idiomatic alias delegating to the canonical method
   // (lives in Sources/ModaalFirestore/Extensions/DocumentReferenceProtocol+Idioms.swift)
   func setData(_ data: [String: Any], mergeOption: MergeOption, completion: ...) {
     switch mergeOption {
     case .overwrite: setData(data, completion: completion)
     case .merge:     setData(data, merge: true, completion: completion)
     case .mergeFields(let fields):
       setData(data, mergeFields: fields, completion: completion)
     }
   }
   ```

5. **No raw Firebase types in protocol surfaces.** Return types and parameters use wrapper protocols or mirrored types. The only Firebase import is in wrapper implementation files.

6. **Mirrored enums for SDK-specific types.** `FirestoreSource`, `DocumentChangeType`, `FirestoreAggregateSource`, `ModaalRemoteConfigFetchStatus`, etc. — so consumers don't need `import Firebase*`.

## Wrapper Classes

1. **Entry-point wrappers are `public final class`.** `FirestoreWrapper`, `FirebaseAuthWrapper`, `CloudStorageWrapper`, etc. They expose the underlying Firebase type as a `public let` property (escape hatch).

2. **Sub-wrappers are `internal final class`.** `DocumentReferenceWrapper`, `QueryWrapper`, etc. Created by entry-point wrappers, never by consumers.

3. **`QueryWrapper` is `class` (not `final`).** `CollectionReferenceWrapper` subclasses it, mirroring the SDK's `CollectionReference: Query` relationship.

4. **Force-cast for protocol-to-concrete bridging.** When a protocol method accepts a protocol type but the wrapper needs the concrete Firebase type:
   ```swift
   let docRef = (document as! DocumentReferenceWrapper).documentRef
   ```
   This is safe because only our wrappers implement these protocols in production.

5. **Direct extension conformance** when the Firebase class already satisfies the protocol:
   ```swift
   extension FirebaseAuth.UserMetadata: FirebaseUserMetadataProtocol {}
   extension FirebaseFirestore.SnapshotMetadata: SnapshotMetadataProtocol {}
   extension FirebaseCrashlytics.Crashlytics: FirebaseCrashlyticsProtocol {}
   ```

6. **Static `makeDefault()` factory** on every entry-point wrapper — mandatory, not optional. Saves consumers from `import Firebase*` at the construction site.

   **Services with an emulator** (Firestore, Auth, Cloud Storage) also take an optional `emulator: (host: String, port: Int)?` tuple:
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

## Type Conversions

Internal extensions on Modaal types convert to Firebase SDK types:

```swift
// In FirestoreTypeConversions.swift
extension FieldPath {
  var asFirestoreFieldPath: FirebaseFirestore.FieldPath { ... }
}

extension Filter {
  var asFirestoreFilter: FirebaseFirestore.Filter { ... }
}

extension FirestoreSource {
  var asFirestoreType: FirebaseFirestore.FirestoreSource { ... }
}
```

These are `internal` — not visible to consumers.

## Combine Extension Layer

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

3. **Works with mocks.** Since these are protocol extensions, mock objects get the Combine API for free — the `Future` calls the mock's completion-handler implementation.

## Two-tier API surface {#two-tier-api-surface}

**Hard rule for code review.** Protocol *declarations* are 1:1 with `firebase-ios-sdk` — same parameter labels, same method names, same overload shapes — modulo the two safety carve-outs (`Result<…, Error>` completion shape; required `completion:` handler with no `nil` default). Any other divergence is a wrapper bug.

Swift-idiomatic ergonomic forms — `MergeOption` enum, labeled `child(path:)`, `getDownloadURL` aliased over `downloadURL`, `canHandleOpenUrl` aliased over `canHandle`, etc. — live as protocol *extensions* atop the canonical surface. They delegate to the canonical method.

Why the split:

- **Mocks stay 1:1 with Firebase.** Sourcery only generates from protocol declarations, not extensions. `MockDocumentReferenceProtocol` mirrors Firebase exactly. No doubled mock surface.
- **Modaal-side docs stay simple.** Only the canonical Firebase surface is documented in the `modaal-agent` KB. Agents migrating consumer code can lift raw-Firebase code unchanged.
- **Power users get sugar.** The wrapper repo's own docs (this file, getting-started.md) surface the extensions as Swift-idiomatic alternatives.

**Adding a new wrapper protocol method?** Look up the Firebase signature first. If you can't justify a divergence on safety grounds, mirror the signature exactly. If a Swift-idiomatic ergonomic shape is desirable, add it as an extension (delegating to the canonical method) — never as a parallel protocol declaration. Wrapper-style aliases declared on the protocol get reverted in PR review (see [anti-patterns.md](anti-patterns.md)).

**Examples in v1.4.0:**

| Canonical (protocol) | Swift-idiomatic (extension) |
|---|---|
| `setData(_:merge: Bool, completion:)` / `setData(_:mergeFields: [Any], completion:)` | `setData(_:mergeOption: MergeOption, completion:)` (DocumentReference / WriteBatch / Transaction) |
| `child(_ pathString: String)` | `child(path: String)` |
| `downloadURL(completion:)` | `getDownloadURL(completion:)` |
| `canHandle(_ url:)` | `canHandleOpenUrl(_ url:)` |
| `canHandleNotification(_:)` | `canHandleRemoteNotification(_:)` |

## Iterating query snapshots {#iterating-query-snapshots}

`QuerySnapshotProtocol.documents` returns `[QueryDocumentSnapshotProtocol]` — a refining protocol that overrides the parent `DocumentSnapshotProtocol`'s optional `data() -> [String: Any]?` with a non-optional `data() -> [String: Any]`. This restores the type-level existence guarantee Firebase encodes via `QueryDocumentSnapshot : DocumentSnapshot`.

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

Combine variants are documented in `Sources/<Module>/Combine/`. Inventory:

- **4 streaming publishers**: `Query.snapshotPublisher`, `DocumentReference.snapshotPublisher`, `Auth.authStateDidChangePublisher`, `RemoteConfig.configUpdatePublisher`.
- **~43 `Future<T, Error>` one-shot methods** across all services.

**Prefer Combine in any Combine-based architecture** (CombineRIBs, MVVM with Combine bindings):

- `addSnapshotListener { result in … }` + manual `registration?.remove()` → `snapshotPublisher().sink { … }.store(in: &cancellables)`
- `addStateDidChangeListener` + manual `removeStateDidChangeListener(handle)` → `authStateDidChangePublisher().sink { … }.store(in: &cancellables)`
- Completion-handler `setData`/`getDocument`/`putData` → `Future<…, Error>` chaining

**Cancellable retention is the lifecycle binding.** Storing the `AnyCancellable` keeps the subscription alive; dropping it cancels and tears down the underlying listener. This is *intended* — it forces the consumer to bind the listener to a parent's lifecycle (worker, view model, builder) rather than orphaning it. Compare to `addSnapshotListener` which returns a `ListenerRegistrationProtocol` that can be silently dropped without any compile-time consequence.

## Escape Hatches

Every entry-point wrapper exposes the underlying Firebase type as a `public` property. Consumers who need an API not yet wrapped can drop down:

```swift
// Wrapped API
firestoreWrapper.collection("users").document("alice").getDocument { ... }

// Escape hatch for unwrapped API
firestoreWrapper.firestore.settings.isPersistenceEnabled = false
```

This requires `import Firebase*` at the call site — an explicit opt-in.
