# Plan: Determinate-progress + cancellable upload API for `CloudFileStoring` (Wave 1 + Wave 2)

## Context

A recent feature attempt needed to render a determinate upload-progress bar for files going to Firebase Cloud Storage, but `CloudFileStoring` only exposes fire-and-forget completion callbacks — even though Firebase's `StorageUploadTask` natively supports `.observe(.progress)`, `.pause()`, `.resume()`, and `.cancel()`. We are filling this gap in two waves so each is small and reviewable, while Wave 1 already locks in forward-compatible types so Wave 2 is **purely source-additive**.

- **Wave 1 (ships now):** determinate progress events + cancellation. Tier 1 protocol callbacks; Tier 2 Combine publisher.
- **Wave 2 (planned, separate change):** Wave 2a — programmatic pause/resume. Wave 2b — investigative spike on iOS background uploads (Firebase SDK does **not** support `URLSessionConfiguration.background(...)` out of the box; needs design work).

Existing non-progress upload methods stay; the new API is additive.

## Forward-compatibility decisions (baked into Wave 1)

Three deliberate choices in Wave 1 keep Wave 2 from breaking any public surface:

1. **Tier-1 callback is event-based, not two `Int64`s.** Signature uses `events: @escaping (CloudStorageUploadEvent) -> Void`. Wave 1 only emits `.progress(...)`; Wave 2 adds `.paused` / `.resumed` cases without touching any method signatures.
2. **`CloudStorageUploadTaskProtocol` is a minimal handle in Wave 1 — just `cancel()`.** Wave 2 adds `pause()` and `resume()` as new protocol requirements with default no-op implementations on a protocol extension, so external conformers remain source-compatible.
3. **`CloudStorageUploadEvent` is a non-frozen public enum.** The doc comment explicitly directs consumers to use `@unknown default` in switches — making Wave 2's new cases additive at the source level.

---

# Wave 1 — Progress + Cancel

## API Design

### New protocol — cancel handle

`Sources/ModaalCloudStorage/Protocols/CloudStorageUploadTaskProtocol.swift` (new file):

```swift
/// Opaque handle to an in-flight upload, returned by the progress-aware
/// upload methods on `CloudFileStoring`.
///
/// Wave 2 will add `pause()` and `resume()` requirements with default
/// implementations on a protocol extension, so existing conformers remain
/// source-compatible.
public protocol CloudStorageUploadTaskProtocol: AnyObject {
  /// Cancels the in-flight upload. Idempotent — safe to call after completion.
  /// On cancellation, the original completion handler fires with
  /// `.failure(NSError)` where `code == -13040` (StorageErrorCode.cancelled).
  func cancel()
}
```

### New event type — emitted to the Tier-1 callback and via Tier-2 publisher

`Sources/ModaalCloudStorage/Types/CloudStorageUploadEvent.swift` (new file):

```swift
/// Events emitted during an upload.
///
/// This enum is intentionally non-frozen. Wave 2 will add `.paused` and
/// `.resumed` cases. Consumers MUST use `@unknown default` in switches over
/// this enum to remain source-compatible across versions.
public enum CloudStorageUploadEvent {
  case progress(bytesTransferred: Int64, totalBytes: Int64)
}
```

### Tier 1 — protocol additions

Four overloads added to [Sources/ModaalCloudStorage/Protocols/CloudFileStoring.swift](Sources/ModaalCloudStorage/Protocols/CloudFileStoring.swift) under a new `// MARK: - Upload with progress` divider, inserted between line 49 (last upload) and line 51 (`delete`):

```swift
@discardableResult
func putData(
  _ data: Data,
  events: @escaping (CloudStorageUploadEvent) -> Void,
  completion: @escaping (Result<Void, Error>) -> Void
) -> CloudStorageUploadTaskProtocol

@discardableResult
func putData(
  _ data: Data,
  metadata: CloudStorageMetadata,
  events: @escaping (CloudStorageUploadEvent) -> Void,
  completion: @escaping (Result<Void, Error>) -> Void
) -> CloudStorageUploadTaskProtocol

@discardableResult
func uploadFromFile(
  localURL: URL,
  events: @escaping (CloudStorageUploadEvent) -> Void,
  completion: @escaping (Result<Void, Error>) -> Void
) -> CloudStorageUploadTaskProtocol

@discardableResult
func uploadFromFile(
  localURL: URL,
  metadata: CloudStorageMetadata,
  events: @escaping (CloudStorageUploadEvent) -> Void,
  completion: @escaping (Result<Void, Error>) -> Void
) -> CloudStorageUploadTaskProtocol
```

The `events:` argument label disambiguates these overloads from the existing four non-progress methods (which still exist). `@discardableResult` so callers who only want events (not cancel) don't get unused-result warnings.

### Tier 2 — Combine extension

Added to [Sources/ModaalCloudStorage/Combine/CloudFileStoring+Combine.swift](Sources/ModaalCloudStorage/Combine/CloudFileStoring+Combine.swift) under a new `// MARK: - Upload with progress` section after line 56. **Names use a `WithProgress` suffix** to avoid overload-by-return-type ambiguity with the existing `putData(_:) -> Future<Void, Error>` family:

```swift
public extension CloudFileStoring {
  func putDataWithProgress(_ data: Data)
    -> AnyPublisher<CloudStorageUploadEvent, Error>

  func putDataWithProgress(_ data: Data, metadata: CloudStorageMetadata)
    -> AnyPublisher<CloudStorageUploadEvent, Error>

  func uploadFromFileWithProgress(localURL: URL)
    -> AnyPublisher<CloudStorageUploadEvent, Error>

  func uploadFromFileWithProgress(localURL: URL, metadata: CloudStorageMetadata)
    -> AnyPublisher<CloudStorageUploadEvent, Error>
}
```

Implementation pattern (one body — the other three are identical modulo the Tier-1 method called):

```swift
func putDataWithProgress(_ data: Data) -> AnyPublisher<CloudStorageUploadEvent, Error> {
  let subject = PassthroughSubject<CloudStorageUploadEvent, Error>()
  var task: CloudStorageUploadTaskProtocol?
  return subject
    .handleEvents(
      receiveSubscription: { _ in
        task = self.putData(
          data,
          events: { event in subject.send(event) },
          completion: { result in
            switch result {
            case .success: subject.send(completion: .finished)
            case .failure(let error): subject.send(completion: .failure(error))
            }
          }
        )
      },
      receiveCancel: { task?.cancel() }
    )
    .eraseToAnyPublisher()
}
```

The publisher emits whatever events the Tier-1 callback emits — so Wave 2's new event cases (`.paused`, `.resumed`) flow through the same publisher with no Tier-2 changes needed.

## Files to modify / create — Wave 1

### New files

| File | Purpose |
| --- | --- |
| [Sources/ModaalCloudStorage/Protocols/CloudStorageUploadTaskProtocol.swift](Sources/ModaalCloudStorage/Protocols/CloudStorageUploadTaskProtocol.swift) | Cancel-handle protocol (~10 LOC) |
| [Sources/ModaalCloudStorage/Types/CloudStorageUploadEvent.swift](Sources/ModaalCloudStorage/Types/CloudStorageUploadEvent.swift) | Event enum (~6 LOC) — single case in Wave 1 |
| [Sources/ModaalCloudStorage/Types/CloudStorageUploadTask.swift](Sources/ModaalCloudStorage/Types/CloudStorageUploadTask.swift) | Internal concrete wrapper over `FirebaseStorage.StorageUploadTask` |

### Modified files

- [Sources/ModaalCloudStorage/Protocols/CloudFileStoring.swift](Sources/ModaalCloudStorage/Protocols/CloudFileStoring.swift) — insert the four new signatures between L49 and L51 under a new MARK.
- [Sources/ModaalCloudStorage/Types/CloudStorageReference.swift](Sources/ModaalCloudStorage/Types/CloudStorageReference.swift) — after L112, add the four progress overloads plus a shared private `observe(_:events:completion:)` helper:

  ```swift
  private func observe(
    _ task: FirebaseStorage.StorageUploadTask,
    events: @escaping (CloudStorageUploadEvent) -> Void,
    completion: @escaping (Result<Void, Error>) -> Void
  ) -> CloudStorageUploadTaskProtocol {
    task.observe(.progress) { snapshot in
      let p = snapshot.progress
      events(.progress(
        bytesTransferred: p?.completedUnitCount ?? 0,
        totalBytes: p?.totalUnitCount ?? 0
      ))
    }
    task.observe(.success) { _ in completion(.success(())) }
    task.observe(.failure) { snapshot in
      completion(.failure(snapshot.error ?? NSError(domain: "Unknown error", code: -1)))
    }
    return CloudStorageUploadTask(task: task)
  }
  ```

  Each of the four new public methods is a one-line call: `observe(reference.putData(data), events: events, completion: completion)` (and variants). Wave 2 will extend this helper to also `.observe(.pause)` / `.observe(.resume)`.

- [Sources/ModaalCloudStorage/Combine/CloudFileStoring+Combine.swift](Sources/ModaalCloudStorage/Combine/CloudFileStoring+Combine.swift) — append the four Combine methods at the end of the extension. `import Combine` already present at L4.
- [Sources/ModaalFirebaseMocks/Annotations/ModaalCloudStorage+CreateMock.swift](Sources/ModaalFirebaseMocks/Annotations/ModaalCloudStorage+CreateMock.swift) — append:

  ```swift
  /// sourcery: CreateMock
  extension CloudStorageUploadTaskProtocol {}
  ```

  Then run `./scripts/generate-mocks.sh` to regenerate [Sources/ModaalFirebaseMocks/Generated/ModaalCloudStorageMocks.swift](Sources/ModaalFirebaseMocks/Generated/ModaalCloudStorageMocks.swift).

- [Tests/ModaalCloudStorageCombineTests/CloudStorageSignatureParityTests.swift](Tests/ModaalCloudStorageCombineTests/CloudStorageSignatureParityTests.swift) — four parity tests (stub Tier-1 mock to emit `.progress(50, 100)` then `.success`; assert publisher emits one `.progress` value then `.finished`) plus one cancel-propagation test (cancel `AnyCancellable`, assert `CloudStorageUploadTaskProtocolMock.cancelCallCount == 1`).
- [Tests/ModaalFirebaseIntegrationTests/CloudStorageIntegrationTests.swift](Tests/ModaalFirebaseIntegrationTests/CloudStorageIntegrationTests.swift) — `testPutDataReportsProgressAndCompletes` (~1 MiB payload, assert progress events fire and final tick equals payload size) and `testPutDataCancelSurfacesFailure` (8 MiB payload, cancel via task handle, assert `.failure` with `NSError.code == -13040`).
- [Tests/ModaalFirebaseSmokeTests/CloudStorageWrapperSmokeTests.swift](Tests/ModaalFirebaseSmokeTests/CloudStorageWrapperSmokeTests.swift) — compile-only signature check for the four new protocol methods + four new Combine methods.
- [Examples/SampleApp/SampleApp/CloudStorageUsage.swift](Examples/SampleApp/SampleApp/CloudStorageUsage.swift) — exercise all four new canonical methods + four new Combine forms (CONTRIBUTING.md rule 6).
- `Docs/agent/coverage.md` and `CHANGELOG.md` — document new methods + public types; note `@unknown default` requirement for `CloudStorageUploadEvent`.

## Edge cases & key decisions — Wave 1

1. **`StorageTaskSnapshot.progress` is `Progress?`.** Emit `.progress(0, 0)` in the nil case rather than swallowing the tick. Document that `totalBytes` may be 0 briefly at the start; fraction computations must guard against divide-by-zero.
2. **Threading.** Firebase delivers observer callbacks via `storage.callbackQueue.async { ... }` (default: main). We do **not** re-marshal — matches the existing wrapper's behavior. Combine consumers wanting strict main-thread delivery can chain `.receive(on:)` themselves.
3. **Observer leaks.** None. Firebase's `StorageUploadTask.finishTaskWithStatus` calls `removeAllObservers()` on success/failure/cancel. We do not capture observer handles.
4. **Combine cancellation semantics.** When the consumer cancels the `AnyCancellable`, `receiveCancel` fires synchronously and calls `task.cancel()`. The Tier-1 closure then receives `.failure(cancelled)`, but Combine has already torn down the subscription, so the `subject.send(completion:)` is silently dropped. Subscribers see no terminal event after cancel — the canonical Combine semantic.
5. **Existing non-progress methods remain.** Not deprecated. The progress variant is purely additive.
6. **No `@Sendable`.** Repo doesn't annotate completion closures `@Sendable`; stay consistent.
7. **`CloudStorageUploadEvent` is non-frozen.** Doc comment explicitly directs consumers to use `@unknown default` in switches.
8. **Single-subscription publishers (footgun).** `makeUploadPublisher(start:)` captures `subject` and `task` per publisher instance; re-subscribing to the same `AnyPublisher` value would call `start(...)` again, overwriting `task` and leaking the first upload (no way to cancel it from the second subscription's lifecycle). This matches the existing pattern in `DocumentReference+Combine.snapshotPublisher` and `Query+Combine.snapshotPublisher`. Documented on the public `…WithProgress(…)` methods and on the private `makeUploadPublisher` helper. Consumers wanting to re-broadcast must wrap with `.share()` / `.multicast(...)` themselves, with the understanding that the upload still runs exactly once.

## Verification — Wave 1

1. **Library compile:** `swift build --target ModaalCloudStorage` then `swift build --target ModaalFirebaseMocks`.
2. **Regenerate mocks:** `./scripts/generate-mocks.sh`. Confirm `CloudStorageUploadTaskProtocolMock` + four new handler properties on `CloudFileStoringMock` / `CloudStorageReferencingMock`.
3. **Unit + parity tests:** `swift test --filter CloudStorageSignatureParityTests`.
4. **Smoke tests:** `swift test --filter CloudStorageWrapperSmokeTests`.
5. **Emulator integration:** `./scripts/run-integration-tests.sh`. Asserts at least one progress event with final `(N, N)` tick, plus cancellation surfaces as `.failure` with `NSError.code == -13040`.
6. **Full build:** `./scripts/build.sh` — SwiftPM + SampleApp xcodebuild.
7. **Optional manual demo:** SampleApp button bound to `putDataWithProgress`, progress bar bound to `.progress` events, Cancel button on the cancellable.

---

# Wave 2 — Pause/Resume + iOS-Background Upload Survey (planned, separate change)

## Wave 2a — Programmatic pause/resume

### Additive changes

- **`CloudStorageUploadTaskProtocol`** gains two requirements with **default no-op implementations** on a protocol extension:

  ```swift
  public protocol CloudStorageUploadTaskProtocol: AnyObject {
    func cancel()
    func pause()    // Wave 2a — new requirement
    func resume()   // Wave 2a — new requirement
  }

  public extension CloudStorageUploadTaskProtocol {
    func pause() {}   // No-op default keeps external conformers source-compatible.
    func resume() {}  // Real impl lives on CloudStorageUploadTask wrapper.
  }
  ```

  External conformers (custom mocks, user-written stubs) compile unchanged. The production `CloudStorageUploadTask` wrapper overrides both to call `FirebaseStorage.StorageUploadTask.pause()` / `.resume()`. The Sourcery mock is regenerated and gains the two new methods + their call counts/handlers.

- **`CloudStorageUploadEvent`** gains two cases:

  ```swift
  public enum CloudStorageUploadEvent {
    case progress(bytesTransferred: Int64, totalBytes: Int64)
    case paused      // Wave 2a — new
    case resumed     // Wave 2a — new
  }
  ```

  Switches written against Wave 1 with `@unknown default` continue to compile and behave reasonably (treat new cases as unknown).

- **`CloudStorageReference.observe(_:events:completion:)`** helper gains:

  ```swift
  task.observe(.pause)  { _ in events(.paused) }
  task.observe(.resume) { _ in events(.resumed) }
  ```

- **No changes** to `CloudFileStoring` protocol method signatures, no new Tier-2 Combine method names, no new files outside the wrapper internals.

### Tests added in Wave 2a

- Parity tests for the two new event cases.
- A pause/resume integration test against the emulator: start a multi-MiB upload, pause it, observe `.paused`, resume, observe `.resumed`, assert completion.
- A mock test asserting `pauseCallCount` / `resumeCallCount` on `CloudStorageUploadTaskProtocolMock`.

### Wave 2a additivity audit

| Surface | Wave 2a change | Source-compatible? |
| --- | --- | --- |
| `CloudStorageUploadTaskProtocol` | +2 requirements with default impls | Yes — defaults cover existing conformers |
| `CloudStorageUploadEvent` | +2 enum cases | Yes — provided consumers use `@unknown default` (documented in Wave 1) |
| `CloudFileStoring` upload methods | No change | Yes |
| `CloudFileStoring+Combine` | No change | Yes |
| Mock annotations | No change | Yes (regen pulls in new methods) |

## Wave 2b — Resumable upload session: URL + status + persistence

Firebase Storage's iOS SDK does **not** use `URLSessionConfiguration.background(...)` itself and provides no SDK surface for the system to resume an upload after app suspension. The wrapper will not attempt to drive a background upload pipeline — instead, **expose a Codable session token** (URL + bookkeeping) so consumers can:

1. Persist the token (e.g., to UserDefaults, a file, Keychain) across app launches.
2. Drive their own `URLSession` background upload using the embedded session URL.
3. Query the wrapper for the current uploaded-byte offset to know where to resume.

### New types

`Sources/ModaalCloudStorage/Types/CloudStorageResumableUploadSession.swift` (new file):

```swift
/// Serializable handle to an in-progress GCS resumable upload session.
///
/// Persist this value (it conforms to `Codable`) across app launches to
/// resume large uploads from background — the Firebase Storage SDK does not
/// support `URLSessionConfiguration.background(...)`, so consumers must
/// drive the byte transfer via their own `URLSession`. Use
/// `resumableUploadStatus(session:completion:)` to learn how many bytes
/// have already reached GCS before sending the next chunk.
public struct CloudStorageResumableUploadSession: Codable, Equatable, Hashable {
  /// The GCS resumable upload session URI. Single-use; authorization is
  /// embedded — no additional auth headers are required for chunk PUTs.
  /// Expires per GCS rules (~ 1 week from creation).
  public let sessionURL: URL

  /// Expected total upload size in bytes. Required for `Content-Range` headers.
  public let totalBytes: Int64

  /// Cloud storage path this session targets. For diagnostic / dedup use.
  public let path: String

  /// When this session was created. Used for expiry checks (~7 days).
  public let createdAt: Date
}
```

`Codable` makes persistence trivial:

```swift
let data = try JSONEncoder().encode(session)
UserDefaults.standard.set(data, forKey: "pendingUpload")
// ... later, possibly after an app relaunch ...
if let data = UserDefaults.standard.data(forKey: "pendingUpload"),
   let session = try? JSONDecoder().decode(CloudStorageResumableUploadSession.self, from: data) {
  ref.resumableUploadStatus(session: session) { ... }
}
```

### New API (additive)

Added to [Sources/ModaalCloudStorage/Protocols/CloudFileStoring.swift](Sources/ModaalCloudStorage/Protocols/CloudFileStoring.swift):

```swift
// MARK: - Resumable upload session

/// Creates a GCS resumable upload session and returns a persistable token.
///
/// The caller drives the actual byte transfer by PUTing chunks (with
/// `Content-Range` headers) to `session.sessionURL`. Authorization is
/// embedded in the URL — no additional auth headers are required.
///
/// Use this when the upload must survive app suspension (large media,
/// poor connectivity). For ordinary foregrounded uploads, prefer
/// `putData(_:events:completion:)` / `uploadFromFile(_:events:completion:)`.
func createResumableUploadSession(
  totalBytes: Int64,
  metadata: CloudStorageMetadata?,
  completion: @escaping (Result<CloudStorageResumableUploadSession, Error>) -> Void
)

/// Queries the GCS session for the byte offset at which the next chunk
/// should be PUT. Use after an app relaunch (or any network interruption)
/// to learn how much of the upload has already reached GCS.
///
/// Returns the count of bytes already uploaded. If equal to
/// `session.totalBytes`, the upload is complete. Errors with
/// `CloudStorageError.resumableSessionExpired` if the session URL has
/// expired (GCS responds 410 Gone).
func resumableUploadStatus(
  session: CloudStorageResumableUploadSession,
  completion: @escaping (Result<Int64, Error>) -> Void
)
```

Plus Combine variants in `CloudFileStoring+Combine.swift`:

```swift
func createResumableUploadSession(
  totalBytes: Int64,
  metadata: CloudStorageMetadata? = nil
) -> Future<CloudStorageResumableUploadSession, Error>

func resumableUploadStatus(
  session: CloudStorageResumableUploadSession
) -> Future<Int64, Error>
```

### New error case

[Sources/ModaalCloudStorage/Types/CloudStorageError.swift](Sources/ModaalCloudStorage/Types/CloudStorageError.swift) (new file, or add to existing error type if there is one — to be confirmed during implementation):

```swift
public enum CloudStorageError: Error {
  case resumableSessionExpired
  // Future cases as needed.
}
```

(If a `CloudStorageError` type already exists in the repo, extend it instead. The plan should be verified against the current state of `Sources/ModaalCloudStorage/Types/` before adding a new file.)

### Implementation note

The Firebase iOS SDK does **not** publicly expose a method to create a resumable session URI. Wave 2b therefore begins as a **scoped spike** to validate the implementation path. Two candidate approaches:

1. **Direct GCS Resumable Upload API call.** Build the POST request against `https://storage.googleapis.com/upload/storage/v1/b/<bucket>/o?uploadType=resumable&name=<path>`, attach a Firebase Auth ID token + App Check token, set `Content-Type: application/json; charset=UTF-8` with the object metadata as the body, send `X-Goog-Upload-Protocol: resumable`, and parse the `Location:` response header. This is the documented GCS approach and the same protocol the Firebase SDK uses internally. Pros: documented public API; supports `?uploadType=resumable` status queries naturally (`PUT` with `Content-Range: bytes */<total>` and no body returns `308 Resume Incomplete` with a `Range:` header — exactly what `resumableUploadStatus(...)` needs). Cons: auth headers must be constructed manually (likely `Auth.auth().currentUser?.getIDToken(...)` + the bucket from `Storage.storage().reference()`).
2. **Surface a session URI captured from a Firebase-driven upload.** Start a `StorageUploadTask`, observe the network request, extract the session URI from the in-flight `GTMSessionUploadFetcher`. Hacky, brittle, relies on private internals — **rejected** unless option 1 is blocked.

Spike deliverable (separate commit, before Wave 2b implementation):
- `Docs/spike/resumable-upload-url.md` — feasibility check for option 1, including the exact auth-token plumbing on iOS and a request/response transcript against the emulator.
- If option 1 is feasible: a working prototype call against the emulator that produces both a session URL and a status query.
- Decision recorded in the doc.

Then Wave 2b implementation follows: types, two protocol methods, two Combine variants, implementation in `CloudStorageReference`, Sourcery mock regen, parity test, integration test (emulator-backed: create session, upload chunk via `URLSession`, query status, verify offset), SampleApp exercises, doc topic page.

### What Wave 2b does NOT do

- No background upload pipeline inside the wrapper.
- No `BGProcessingTask` / `BackgroundTasks` integration.
- No automatic retry / chunking — the wrapper hands off a session token; chunking and retries are the consumer's responsibility.
- No completion-notification API — the consumer's `URLSessionDelegate` is the source of truth for "upload done."
- No automatic session-expiry refresh — the wrapper exposes `session.createdAt` so the caller can detect and discard expired tokens; expired-session detection via `resumableUploadStatus(...)` surfaces `CloudStorageError.resumableSessionExpired`.

This narrows Wave 2b sharply: one new value type, one new error case, two new method pairs (canonical + Combine), plus docs that explain the handoff pattern.

---

# SampleApp & Documentation Expansion (across all waves)

The SampleApp follows a compile-only convention: each `exercise...(_:)` function names every public API on the protocol/type, never actually invokes them, and proves the API compiles. Documentation is split between `Docs/agent/*` (machine-oriented coverage) and `Docs/human/*` (narrative).

## SampleApp — Wave 1

[Examples/SampleApp/SampleApp/CloudStorageUsage.swift](Examples/SampleApp/SampleApp/CloudStorageUsage.swift) — extend `exerciseFileStoring(_:)` at L97 (just before `// Uploads`):

```swift
// Uploads with progress + cancel (canonical Tier 1)
let events: (CloudStorageUploadEvent) -> Void = { event in
  switch event {
  case .progress(let sent, let total): _ = (sent, total)
  @unknown default: break  // Wave 2 may add .paused/.resumed
  }
}

let task1: CloudStorageUploadTaskProtocol = file.putData(Data(), events: events) { _ in }
task1.cancel()

let task2: CloudStorageUploadTaskProtocol =
  file.putData(Data(), metadata: meta, events: events) { _ in }
_ = task2

let task3: CloudStorageUploadTaskProtocol =
  file.uploadFromFile(localURL: URL(fileURLWithPath: "/tmp/file"), events: events) { _ in }
_ = task3

let task4: CloudStorageUploadTaskProtocol = file.uploadFromFile(
  localURL: URL(fileURLWithPath: "/tmp/file"),
  metadata: meta,
  events: events
) { _ in }
_ = task4
```

And extend `exerciseFileStoringCombine(_:)` after L181:

```swift
// Combine — upload with progress
let _: AnyPublisher<CloudStorageUploadEvent, Error> = file.putDataWithProgress(Data())
let _: AnyPublisher<CloudStorageUploadEvent, Error> =
  file.putDataWithProgress(Data(), metadata: CloudStorageMetadata(contentType: "image/png"))
let _: AnyPublisher<CloudStorageUploadEvent, Error> =
  file.uploadFromFileWithProgress(localURL: URL(fileURLWithPath: "/tmp/file"))
let _: AnyPublisher<CloudStorageUploadEvent, Error> = file.uploadFromFileWithProgress(
  localURL: URL(fileURLWithPath: "/tmp/file"),
  metadata: CloudStorageMetadata(contentType: "image/png")
)
```

## SampleApp — Wave 2a (additive)

In `exerciseFileStoring(_:)`, extend the `events` switch and add pause/resume calls:

```swift
let events: (CloudStorageUploadEvent) -> Void = { event in
  switch event {
  case .progress(let sent, let total): _ = (sent, total)
  case .paused: break    // Wave 2a
  case .resumed: break   // Wave 2a
  @unknown default: break
  }
}
// (... existing task1..task4 ...)
task1.pause()    // Wave 2a
task1.resume()   // Wave 2a
```

No new top-level function needed — the Wave 1 exercises grow.

## SampleApp — Wave 2b (additive)

Add a new exercise to `CloudStorageUsage.swift`:

```swift
// MARK: - Resumable upload session (Wave 2b)

/// Exercises the resumable upload session API.
func exerciseResumableUploadSession(_ file: CloudFileStoring) {
  // Create a session for a 100 MiB upload (no metadata).
  file.createResumableUploadSession(totalBytes: 100 * 1024 * 1024, metadata: nil) { result in
    switch result {
    case .success(let session):
      _ = session.sessionURL
      _ = session.totalBytes
      _ = session.path
      _ = session.createdAt
    case .failure: break
    }
  }

  // With metadata.
  file.createResumableUploadSession(
    totalBytes: 100 * 1024 * 1024,
    metadata: CloudStorageMetadata(contentType: "video/mp4")
  ) { _ in }

  // Status query — pretend we deserialized a session from disk.
  let session = CloudStorageResumableUploadSession(
    sessionURL: URL(string: "https://storage.googleapis.com/...")!,
    totalBytes: 100 * 1024 * 1024,
    path: "videos/sample.mp4",
    createdAt: Date()
  )
  file.resumableUploadStatus(session: session) { result in
    switch result {
    case .success(let bytesUploaded): _ = bytesUploaded
    case .failure: break
    }
  }

  // Codable round-trip (proves persistence works at the type level).
  let data = try? JSONEncoder().encode(session)
  _ = data.flatMap { try? JSONDecoder().decode(CloudStorageResumableUploadSession.self, from: $0) }

  // Combine
  let _: Future<CloudStorageResumableUploadSession, Error> =
    file.createResumableUploadSession(totalBytes: 100 * 1024 * 1024)
  let _: Future<CloudStorageResumableUploadSession, Error> = file.createResumableUploadSession(
    totalBytes: 100 * 1024 * 1024,
    metadata: CloudStorageMetadata(contentType: "video/mp4")
  )
  let _: Future<Int64, Error> = file.resumableUploadStatus(session: session)
}
```

## Documentation — Wave 1

- [Docs/agent/coverage.md](Docs/agent/coverage.md) — add a row under `ModaalCloudStorage` for the four new canonical methods + four new Combine methods + `CloudStorageUploadTaskProtocol` + `CloudStorageUploadEvent`.
- [Docs/agent/patterns.md](Docs/agent/patterns.md) — if it currently lacks a section on "progressing/streaming wrappers" (a pattern likely to recur for downloads later), add a short subsection that captures: (1) event enum + `@unknown default` requirement, (2) cancel-handle protocol, (3) Combine projection via `PassthroughSubject + handleEvents(receiveSubscription:receiveCancel:)`. This is the second instance of this pattern in the repo (after `DocumentReference+Combine.swift`'s listener pattern) — worth codifying.
- `Docs/human/upload-progress.md` (new file, optional) — narrative for human consumers: when to use the progress API vs the fire-and-forget API, how cancellation works in Combine, thread-delivery notes.
- `CHANGELOG.md` — new entry under the next version:
  ```
  ## [next-version]
  ### Added
  - `CloudFileStoring`: determinate-progress + cancellable upload overloads
    (`putData(_:events:completion:)`, `uploadFromFile(_:events:completion:)`,
    plus metadata variants) returning a `CloudStorageUploadTaskProtocol` handle.
  - `CloudStorageUploadEvent` enum (non-frozen — use `@unknown default`).
  - Combine variants: `putDataWithProgress(_:)` / `uploadFromFileWithProgress(_:)`
    returning `AnyPublisher<CloudStorageUploadEvent, Error>`.
  ```
- **Inline doc comments** on every new public symbol — see snippets in the API Design section.

## Documentation — Wave 2a

- Update `Docs/agent/coverage.md` row: add `pause()`/`resume()` on the task protocol and `.paused`/`.resumed` on the event enum.
- Update `Docs/human/upload-progress.md` (or equivalent topic): add a "Pause / Resume" subsection — show the call pattern and clarify that pause/resume is programmatic, **not** OS-background.
- `CHANGELOG.md`:
  ```
  ### Added
  - `CloudStorageUploadTaskProtocol`: `pause()` / `resume()` methods (default
    no-op for backward compatibility).
  - `CloudStorageUploadEvent`: `.paused` / `.resumed` cases.
  ```

## Documentation — Wave 2b

- `Docs/agent/coverage.md`: add rows for `createResumableUploadSession(...)`, `resumableUploadStatus(...)`, `CloudStorageResumableUploadSession`, `CloudStorageError.resumableSessionExpired`.
- `Docs/human/upload-progress.md`: add a top-level "Resumable / background uploads" section. Includes:
  - When to use this (large files, must survive app suspension).
  - The handoff pattern (snippet showing: call `createResumableUploadSession(totalBytes:metadata:)`, persist the returned token via `Codable`, hand `session.sessionURL` to a `URLSession` with `URLSessionConfiguration.background(withIdentifier:)`, PUT chunks with `Content-Range: bytes <start>-<end>/<total>`, hook `URLSessionDelegate.urlSession(_:task:didCompleteWithError:)` for completion).
  - The resumption pattern (on relaunch: decode the persisted token, call `resumableUploadStatus(session:)` to learn the byte offset, continue uploading from there).
  - Session lifecycle (single-use, ~1-week expiry per GCS rules, auth baked into the URL, `createdAt` for expiry checks, `CloudStorageError.resumableSessionExpired` if the session has gone away).
  - What the wrapper does NOT do (chunking, retries, completion notification — caller's responsibility; the wrapper is a session broker, not a transfer engine).
- `Docs/spike/resumable-upload-url.md` — the upfront feasibility findings doc (precedes implementation).
- `CHANGELOG.md`:
  ```
  ### Added
  - `CloudStorageResumableUploadSession` — Codable handle to a GCS resumable
    upload session, persistable across app launches to drive background uploads
    via the consumer's own `URLSession`.
  - `CloudFileStoring.createResumableUploadSession(totalBytes:metadata:completion:)`
    creates a session and returns the persistable token.
  - `CloudFileStoring.resumableUploadStatus(session:completion:)` queries the
    current uploaded-byte offset to support resumption after app relaunch.
  - `CloudStorageError.resumableSessionExpired` error case.
  ```

---

# Wave 2 — what is *not* changed (proof of additivity)

For every Wave-1 public symbol, Wave 2 either leaves it untouched or extends it in a strictly additive way:

| Wave 1 surface | Wave 2 change | Source-compatible? |
| --- | --- | --- |
| `CloudFileStoring` upload method signatures (4 progress overloads) | No change | Yes |
| `CloudFileStoring+Combine` progress publisher methods | No change | Yes |
| `CloudStorageUploadTaskProtocol.cancel()` | No change | Yes |
| `CloudStorageUploadTaskProtocol` requirements | +`pause()` / +`resume()` with default no-op impls | Yes — defaults cover existing conformers |
| `CloudStorageUploadEvent.progress(...)` case | No change | Yes |
| `CloudStorageUploadEvent` cases | +`.paused` / +`.resumed` | Yes — Wave 1 documented `@unknown default` requirement |
| Combine return type `AnyPublisher<CloudStorageUploadEvent, Error>` | No change | Yes |
| `CloudFileStoring` non-progress upload methods (pre-existing) | No change | Yes |

Wave 2 **adds** the following net-new public surface (no conflict with Wave 1):

- `CloudFileStoring.createResumableUploadSession(...)` and Combine variant.
- `CloudFileStoring.resumableUploadStatus(...)` and Combine variant.
- `CloudStorageResumableUploadSession` (Codable struct).
- `CloudStorageError.resumableSessionExpired`.

If any concrete Wave 2 implementation step would force breaking a Wave 1 signature, that's a signal Wave 1's types need another revision before Wave 1 ships.

---

# Followups (out of scope for this PR)

1. **Threading documentation rollout across the rest of the wrappers.** Wave 1 added an explicit **Threading.** note to the new `CloudFileStoring` progress methods and `…WithProgress(…)` publishers (callbacks delivered on `Storage.callbackQueue`, default `DispatchQueue.main`). The pre-existing wrapper APIs — `ModaalFirebaseAuth`, `ModaalFirestore` (including `snapshotPublisher` family), `ModaalFirebaseRemoteConfig`, `ModaalFirebaseMessaging`, the non-progress `CloudFileStoring` overloads — don't document their callback queue. Consumers wiring callbacks straight to UI have to infer the queue from the SDK. Apply the same `**Threading.**` note convention across these surfaces in a follow-up PR; pull `Auth.auth().callbackQueue`, `Firestore.firestore().settings.dispatchQueue`, etc. into the doc comments.
2. **Single-subscription contract.** The same single-subscription footgun applies to `DocumentReference+Combine.snapshotPublisher`, `Query+Combine.snapshotPublisher`, `RemoteConfig+Combine.configUpdates`, and `FirebaseAuth+Combine.authStateChanges`. Either document it consistently on each, or refactor the helpers to use `Deferred { Future { ... } }` / a shared streaming helper that's safe to re-subscribe.
3. **Wave 2b — resumable upload session URL + status + persistence.** Stays on a separate branch until a real consumer asks for it. Plan is captured above; the first concrete step is the feasibility spike (`Docs/spike/resumable-upload-url.md`) before any production code.

---

# Polish round — pre-release feedback from first beta consumer

First production-side integration (`modaal-vibereef`, [`specs/025-video-export-upload`](https://github.com/modaal-agent/modaal-vibereef-mv6v2/blob/main/specs/025-video-export-upload/spec.md), §"Wrapper-library wishlist") landed in one sitting without consulting the wrapper authors. The consumer explicitly confirmed:

- Non-frozen enum + `@unknown default` doc directive in BOTH the enum and the Tier-2 method docs (the deliberate redundancy from earlier review).
- `totalBytes == 0` divide-by-zero warning on `.progress`.
- Single-subscription footgun documentation (why-not, not just the rule).
- Threading note on every progress-aware method.
- Pause/resume forward-compat via protocol-extension default no-ops.

The consumer also walked back two API-shape suggestions from an earlier draft (a "Tier-3" `AnyPublisher<UploadProgress, Error>` with terminal `.completed(URL)` element, and a `.append(Just(...))` worked example). Both were correctly rejected on grounds the wrapper doesn't pick a URL shape (consumer policy) and a terminal element conflicts with cancellation semantics. **Reasoning recorded** so the same suggestions don't re-surface.

The four remaining items below are doc-only / additive. Each is evaluated on its own merits — not all are worth shipping.

### 1. Canonical consumer snippet — ACCEPT

**The feedback.** Add a worked example showing the idiomatic `…WithProgress(…) → .compactMap → .removeDuplicates → .handleEvents → .reduce((), { _, _ in () })` pipeline. Two non-obvious moves: (a) `.reduce((), { _, _ in () })` as the canonical "wait for `.finished`, emit single `Void`" bridge, and (b) the explicit no-payload-on-completion design — consumers recompose any URL they need from their own state.

**Challenge.**
- Doc comments shouldn't carry multi-line code examples (they bloat hover-docs in Xcode and rot when surrounding code changes).
- The Vibereef snippet is opinionated about UI architecture (`presenter` pattern, `removeDuplicates` cadence policy). Need to generalize.
- *But:* the consumer explicitly named this "the single highest-ROI addition," and the `.reduce((), { _, _ in () })` bridge IS the one canonical idiom on a `Publisher<Event, Error> → AnyPublisher<Void, Error>` conversion — exactly the question the next integrator will hit when they ask "what's the success value on the streaming variant?" The answer ("there isn't one — completion via `.finished` is the signal, recompose any URL where you need it") is content that doesn't fit a one-liner.

**Action.** Add a "Consuming the upload-progress publisher" section to `Docs/agent/patterns.md` under the existing Combine-layer subsection. Show:
- The 8-line `.compactMap → .removeDuplicates → .reduce` pipeline.
- A one-line explanation per non-obvious operator (why `compactMap` returns `Double?`, why `reduce` collapses to `Void`).
- Explicit statement of the no-URL-on-completion design and why (URL shape is consumer policy).
- Cross-reference from each `…WithProgress(_:)` doc comment as a single trailing line: `/// Consumer pattern: see Docs/agent/patterns.md § "Consuming the upload-progress publisher".`

**Scope guardrails.** Do NOT include a SwiftUI / UIKit binding example — UI integration is consumer policy. Stop at the pipeline shape.

### 2. Cadence note — ACCEPT in calibrated form

**The feedback.** Add one sentence noting Firebase emits "tens to hundreds of events per upload" and consumers should quantize / `.removeDuplicates()`. The consumer reports they burned a design round on time-based `.throttle(...)` which collapsed synchronous test sequences.

**Challenge.**
- "Tens to hundreds" is anecdotal — it varies with payload size, chunk size, and network. Promising a specific cadence and then having Firebase change `GTMSessionUploadFetcher` defaults would make the doc wrong.
- Recommending `.removeDuplicates()` over `.throttle(...)` is *cadence policy*, leaking into UI domain. The wrapper shouldn't legislate which Combine operator the consumer reaches for.
- *But:* the failure mode the consumer describes is real and non-obvious — `.throttle(...)` interacts badly with `PassthroughSubject` test sequences because of `RunLoop` scheduling. Calling out that fact in one sentence prevents a guaranteed test-flakiness incident.

**Action.** Add a one-sentence "Event cadence" note to `putDataWithProgress(_:)`'s doc comment (the canonical Combine variant). Suggested wording:

> **Event cadence.** Firebase emits `.progress(...)` at the underlying byte-transfer granularity — high-frequency for large uploads. Quantize (e.g., to 1% buckets via `.removeDuplicates(by:)`) before driving UI; time-based throttling (`.throttle(...)`) is dependency-aware and may collapse synchronous test sequences.

Other three Combine variants reference it via the existing "See `putDataWithProgress(_:)` for …" line — extend that line to mention cadence too.

**Scope guardrails.** Do NOT add a similar note to the Tier-1 protocol methods — cadence is a Combine-consumer concern. Tier-1 callback consumers control their own batching.

### 3. Mock helper for fake progress sequences — DEFER

**The feedback.** Add `CloudFileStoringMock.stubUploadWithProgress(_ ticks:)` to eliminate hand-built `events`/`completion` dispatch in test boilerplate. The Sourcery-generated handler names (`uploadFromFileLocalURLMetadataEventsCompletionHandler`) are verbose.

**Challenge.**
- Net-new code, not doc-only. Hand-written extensions sitting alongside Sourcery-generated code in `ModaalFirebaseMocks` would be the first instance of that pattern in the repo (the existing mock module is generated-only). Setting a precedent here means other surfaces will request the same helper for their generated mocks; we'd be growing a parallel hand-written test-helper API alongside every Sourcery output.
- The saved boilerplate is ~4 lines per test. The handler-naming verbosity is a Sourcery-template concern (repo-wide), not something to paper over per-surface.
- *But:* the codified "emit-then-complete" shape IS the canonical mock dispatch pattern, and naming it explicitly would help readers.

**Action.** Document the testing pattern in `Docs/agent/patterns.md` alongside the consumer snippet (item 1). A ~6-line snippet showing how to stub a mock handler to emit a progress sequence and then call completion. Same DX win as a helper function without growing the mock module surface or setting a "hand-written helpers in ModaalFirebaseMocks" precedent.

**Revisit if.** A second consumer asks for the actual helper function, OR similar requests land for two other surfaces (Auth, Firestore). At that point the cross-cutting pattern justifies a shared `Test-helpers` module separate from `ModaalFirebaseMocks`.

### 4. `cancel()` ordering clarification — ACCEPT

**The feedback.** The doc says `completion` fires with `-13040` on cancel but doesn't say whether `.progress` events can still arrive *after* `cancel()` is called but before completion.

**Challenge.**
- We haven't formally verified Firebase's ordering guarantees here. Promising "no events after cancel" would be a contract we'd have to hold; if Firebase has a tick already enqueued on `callbackQueue` when `cancel()` is called, that tick will be delivered before the cancel-induced `.failure` because callbacks are serialized on that queue.
- *But:* the question is real and a calibrated answer is short.

**Action.** One sentence appended to the `cancel()` doc comment on `CloudStorageUploadTaskProtocol`:

> Event delivery is best-effort once `cancel()` has been requested — a `.progress(...)` tick already enqueued on `Storage.callbackQueue` may still fire before `completion(.failure(...))`. UI teardown that observes events should be idempotent.

No matching change to the Tier-1 protocol methods or Combine docs needed — `cancel()` is on the task protocol and `Combine`-side cancellation is already documented as "no terminal event delivered" elsewhere.

### Polish-round scope summary

| Item | Verdict | Touchpoint |
|---|---|---|
| 1 — Canonical consumer snippet | Accept | New section in `Docs/agent/patterns.md` + one-line cross-ref from each `…WithProgress(_:)` doc |
| 2 — Cadence note | Accept (calibrated) | One paragraph on `putDataWithProgress(_:)` Combine doc |
| 3 — Mock helper | Defer; document the pattern instead | Inline in the new `patterns.md` section |
| 4 — `cancel()` ordering | Accept | One sentence on `CloudStorageUploadTaskProtocol.cancel()` doc |

**Not changing as part of this polish round** (already discussed in feedback, no action needed):
- The non-frozen-enum + `@unknown default` policy.
- The `totalBytes == 0` warning on `.progress`.
- Single-subscription footgun doc.
- Threading note placement / wording.
- Pause/resume forward-compat design.
- API shape (no Tier-3 helper, no terminal `.completed(URL)` element — both explicitly walked back by the consumer).

Estimated net change: ~40-60 lines of new prose in `patterns.md`, ~4 doc-comment lines in `CloudFileStoring+Combine.swift` and `CloudStorageUploadTaskProtocol.swift`. No new types, no new methods, no test changes.
