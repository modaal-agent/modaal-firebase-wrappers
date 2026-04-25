# Anti-Patterns — What NOT to Do

## Protocol Design

- **Never expose raw Firebase types in protocol surfaces.** No `CollectionReference`, `DocumentSnapshot`, `StorageReference` etc. in protocol method signatures. Always use the corresponding wrapper protocol. This is a review-blocker.

- **Never add `import Firebase*` to protocol files.** Protocol definitions must be Firebase-free. Only wrapper implementation files import Firebase.

- **Never add `import Combine` to protocol files.** Combine extensions live in separate `Combine/` directory files, not in protocol definitions.

- **Never add Sourcery/Mockable annotations.** Mock generation tooling is TBD. Don't add `/// sourcery: CreateMock`, `@Mockable`, or similar annotations. The chosen tool will add its own.

## Wrapper Implementation

- **Never create umbrella facades.** No `ModaalFirebase.auth`, `ModaalFirebase.firestore` etc. Each module is independent. Consumers compose what they need.

- **Never port RIBs-specific code.** Workers, Interactors, `Working` protocols — these stay in the consumer app. This library is architecture-agnostic.

- **Never add the `-ObjC` linker flag to the library.** This is the consumer app's responsibility. Document it in getting-started.md instead.

- **Never swallow errors silently.** Always propagate errors through `Result.failure` or `completion(.failure(...))`. Use `NSError(domain: "Unknown error", code: -1)` only as a last resort when Firebase returns nil for both result and error.

## Dependencies

- **Never depend on `FirebaseCore` directly.** The xcframeworks package doesn't expose it as a standalone product. `ModaalFirebaseCore` depends on `FirebaseAnalytics` (which bundles `_FirebaseCore` internally).

- **Never use the internal package name `"Firebase"` in SPM.** SPM 5.9 uses URL-derived identity: `"firebase-ios-sdk-xcframeworks"`.

## Testing & Verification

- **Never ship a module without SampleApp coverage.** Every protocol method must be exercised in `Examples/SampleApp/SampleApp/<Module>Usage.swift`.

- **Never skip `./scripts/build.sh`.** It builds library targets, SampleApp, and tests. A module isn't done until this passes.

## Combine Layer

- **Never add Combine methods as protocol requirements.** They are protocol extensions (default implementations). Adding them as requirements would force every mock to implement them.

- **Never use `Deferred` in Combine extensions.** `Future` is intentionally eager (starts on creation, not subscription) — matching FirebaseCombineSwift behavior. The completion-handler method is called immediately.

## Consumer-Side (App Code Using This Library)

The rules above govern the wrapper library itself. The rules in this section apply to **app code that consumes this library** — they are the most common ways a migration to `modaal-firebase-wrappers` goes wrong.

- **Do not re-host this library behind a local consumer-side facade.** If your app today has a `FirAppConfiguring`-style god-object that returns raw Firebase types (`CollectionReference`, `DocumentReference`, `StorageReference`), the migration to `modaal-firebase-wrappers` *deletes* that facade — it does not rebuild it on top of these wrappers. Inject per-service wrapper protocols (`FirestoreProtocol`, `CloudStorageProtocol`, `FirebaseAuthProtocol`, etc.) at your composition root and pass them through the dependency graph. A facade re-hosting still leaks raw Firebase types into your app and defeats the testability and decoupling this library was built to provide.

- **Do not add a direct SPM dependency on `firebase-ios-sdk` or `firebase-ios-sdk-xcframeworks` "for raw types used in app code".** This library transitively pulls in `firebase-ios-sdk-xcframeworks` at the version it was built against; a second direct pin causes duplicate-XCFramework link errors when the two diverge. Prefer wrapping the missing API or filing a coverage gap against [`coverage.md`](coverage.md) over adding a parallel SDK dependency.

- **Do not `import FirebaseFirestore` / `import FirebaseAuth` / `import FirebaseStorage` / `import FirebaseMessaging` in app code outside the composition root.** Use `import ModaalFirestore` / `import ModaalFirebaseAuth` / `import ModaalCloudStorage` / `import ModaalFirebaseMessaging`. The wrapper-protocol types live in the `Modaal*` modules; raw Firebase imports indicate either a missed migration site or an escape-hatch leak.

- **Do use the escape hatch (`firestore.firestore`, `cloudStorage.storage`, etc.) only at the single call site that needs the raw type** — with a local `import FirebaseFirestore` (or whichever module) in *that file only*, never project-wide. Each escape-hatch use is a coverage gap; consider filing one against [`coverage.md`](coverage.md).
