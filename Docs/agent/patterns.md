# Wrapper Implementation Patterns

## Protocol Design

1. **One protocol per Firebase class.** `FirestoreProtocol` wraps `Firestore`, `DocumentReferenceProtocol` wraps `DocumentReference`, etc.

2. **Protocol inheritance mirrors SDK class hierarchy.** `CollectionReferenceProtocol: QueryProtocol` mirrors `CollectionReference: Query`.

3. **Completion handlers with `Result`.** All async methods use `completion: @escaping (Result<T, Error>) -> Void)` — not the Firebase SDK's `(T?, Error?)` pattern. This is safer and more Swift-idiomatic.

4. **Protocol extensions for convenience overloads.** Default parameter values can't go on protocol requirements, so they're protocol extensions:
   ```swift
   // Protocol requirement (full parameters)
   func setData(_ data: [String: Any], mergeOption: MergeOption, completion: ...)
   
   // Protocol extension (convenience with default)
   func setData(_ data: [String: Any], completion: ...) {
     setData(data, mergeOption: .overwrite, completion: completion)
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

## Escape Hatches

Every entry-point wrapper exposes the underlying Firebase type as a `public` property. Consumers who need an API not yet wrapped can drop down:

```swift
// Wrapped API
firestoreWrapper.collection("users").document("alice").getDocument { ... }

// Escape hatch for unwrapped API
firestoreWrapper.firestore.settings.isPersistenceEnabled = false
```

This requires `import Firebase*` at the call site — an explicit opt-in.
