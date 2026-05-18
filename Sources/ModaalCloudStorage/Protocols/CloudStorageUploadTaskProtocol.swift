// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

/// Opaque handle to an in-flight upload, returned by the progress-aware
/// upload methods on `CloudFileStoring`.
///
/// Wave 2 will add `pause()` and `resume()` requirements with default
/// implementations on a protocol extension, so existing conformers remain
/// source-compatible.
public protocol CloudStorageUploadTaskProtocol: AnyObject {

  /// Cancels the in-flight upload. Idempotent — safe to call after completion.
  ///
  /// On cancellation, the original completion handler fires with
  /// `.failure(NSError)` where `code == -13040` (`StorageErrorCode.cancelled`).
  func cancel()
}
