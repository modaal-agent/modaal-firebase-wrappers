// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

/// Events emitted during an upload.
///
/// This enum is intentionally non-frozen — future versions may add cases.
/// Consumers MUST use `@unknown default` in switches over this enum to
/// remain source-compatible across versions.
public enum CloudStorageUploadEvent {

  /// Determinate progress tick. `totalBytes` may be `0` briefly at the start
  /// of an upload before the underlying `Progress` reports the expected total;
  /// guard against divide-by-zero when computing fractions.
  case progress(bytesTransferred: Int64, totalBytes: Int64)

  /// The upload has been paused (in response to `pause()` on the task handle).
  /// No further `.progress` events are emitted until the upload is resumed.
  case paused

  /// The upload has resumed (in response to `resume()` on the task handle).
  /// `.progress` events will continue until success or failure.
  case resumed
}
