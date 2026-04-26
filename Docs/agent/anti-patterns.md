# Consumer-Side Anti-Patterns

What NOT to do in app code that consumes ModaalFirebase. These are the most common ways a migration to `modaal-firebase-wrappers` goes wrong.

For library-development anti-patterns (how *not* to build the wrappers themselves), see [`CONTRIBUTING.md`](../../CONTRIBUTING.md).

## Construction

- **Do not construct entry-point wrappers directly via `init(...)` for default instances.** Use `Wrapper.makeDefault()` (or `Wrapper.makeDefault(emulator:)` against the Firebase Emulator). The direct `init` form requires `import Firebase*` at the call site and defeats the point of the wrapper:

  ```swift
  // ❌ Deprecated — requires `import FirebaseFirestore`
  let db: FirestoreProtocol = FirestoreWrapper(firestore: Firestore.firestore())

  // ✅ Standard
  let db: FirestoreProtocol = FirestoreWrapper.makeDefault()
  ```

  The `init(...)` form remains `public` only for the rare non-default-instance case (custom `FirebaseApp`, pre-configured handle); confine it to the composition root and prefer `makeDefault()` everywhere else.

## Architecture

- **Do not re-host this library behind a local consumer-side facade.** If your app today has a `FirAppConfiguring`-style god-object that returns raw Firebase types (`CollectionReference`, `DocumentReference`, `StorageReference`), the migration to `modaal-firebase-wrappers` *deletes* that facade — it does not rebuild it on top of these wrappers. Inject per-service wrapper protocols (`FirestoreProtocol`, `CloudStorageProtocol`, `FirebaseAuthProtocol`, etc.) at your composition root and pass them through the dependency graph. A facade re-hosting still leaks raw Firebase types into your app and defeats the testability and decoupling this library was built to provide.

## Dependencies

- **Do not add a direct SPM dependency on `firebase-ios-sdk` or `firebase-ios-sdk-xcframeworks` "for raw types used in app code".** This library transitively pulls in `firebase-ios-sdk-xcframeworks` at the version it was built against; a second direct pin causes duplicate-XCFramework link errors when the two diverge. Prefer wrapping the missing API or filing a coverage gap against [`coverage.md`](coverage.md) over adding a parallel SDK dependency.

## Imports

- **Do not `import FirebaseFirestore` / `import FirebaseAuth` / `import FirebaseStorage` / `import FirebaseMessaging` in app code outside the composition root.** Use `import ModaalFirestore` / `import ModaalFirebaseAuth` / `import ModaalCloudStorage` / `import ModaalFirebaseMessaging`. The wrapper-protocol types live in the `Modaal*` modules; raw Firebase imports outside the composition root indicate either a missed migration site or an escape-hatch leak.

## Escape Hatch

- **Use the escape hatch (`firestore.firestore`, `cloudStorage.storage`, etc.) only at the single call site that needs the raw type** — with a local `import FirebaseFirestore` (or whichever module) in *that file only*, never project-wide. Each escape-hatch use is a coverage gap; consider filing one against [`coverage.md`](coverage.md).

## Testing

- **Do not mix real entry-point wrappers with mocked sub-protocols in tests.** Mocks compose with mocks; wrappers compose with wrappers. The wrappers' protocol-to-concrete bridging uses `as!` force-casts internally — safe in production because only our wrappers implement these protocols. Passing a `DocumentReferenceProtocolMock` (or `FirebaseUserProtocolMock`, etc.) into a real `WriteBatchWrapper` / `TransactionWrapper` / `FirebaseAuthWrapper` method that expects a sub-protocol triggers an `as!` failure inside the wrapper at runtime. If you want a transactional / batched / auth-mutating test, mock the *entry-point* protocol (`WriteBatchProtocol`, `TransactionProtocol`, `FirebaseAuthProtocol`) directly — never an intermediate.

- **Do not roll a hand-written conformer to a generated mock protocol.** `ModaalFirebaseMocks` ships Sourcery-generated mocks for every protocol. If a generated mock's shape feels awkward (init parameters, missing convenience), use the helper `static func make(...)` factories in `Sources/ModaalFirebaseMocks/Helpers/` (reachable via `@testable import ModaalFirebaseMocks`) — or file an issue against the wrapper repo for a new helper. Don't substitute hand-written conformers; that breaks composition guarantees and drifts from the canonical protocol surface as it evolves.
