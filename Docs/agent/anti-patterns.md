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
