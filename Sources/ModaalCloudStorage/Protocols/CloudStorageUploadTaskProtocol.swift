// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

/// Opaque handle to an in-flight upload, returned by the progress-aware
/// upload methods on `CloudFileStoring`.
///
/// `pause()` and `resume()` ship with default no-op implementations on a
/// protocol extension so external conformers (custom mocks, user-written
/// stubs) that only implement `cancel()` remain source-compatible.
public protocol CloudStorageUploadTaskProtocol: AnyObject {

  /// Cancels the in-flight upload. Idempotent — safe to call after completion.
  ///
  /// On cancellation, the original completion handler fires with
  /// `.failure(NSError)` where `code == -13040` (`StorageErrorCode.cancelled`).
  func cancel()

  /// Pauses the in-flight upload. Idempotent — safe to call when already paused
  /// or after the upload has completed.
  ///
  /// While paused, no `.progress` events are emitted. A `.paused` event is
  /// emitted once the pause takes effect. This is a programmatic pause inside
  /// the Firebase Storage SDK — it does **not** survive app suspension.
  func pause()

  /// Resumes a previously paused upload. Idempotent.
  ///
  /// A `.resumed` event is emitted once the upload resumes; `.progress`
  /// events then continue until success or failure.
  func resume()
}

public extension CloudStorageUploadTaskProtocol {

  /// No-op default for conformers that don't override. The production wrapper
  /// overrides this to call `FirebaseStorage.StorageUploadTask.pause()`.
  func pause() {}

  /// No-op default — see `pause()` for rationale.
  func resume() {}
}
