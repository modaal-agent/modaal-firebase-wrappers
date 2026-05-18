// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

/// Events emitted during an upload.
///
/// This enum is intentionally non-frozen. Wave 2 will add `.paused` and
/// `.resumed` cases. Consumers MUST use `@unknown default` in switches over
/// this enum to remain source-compatible across versions.
public enum CloudStorageUploadEvent {

  /// Determinate progress tick. `totalBytes` may be `0` briefly at the start
  /// of an upload before the underlying `Progress` reports the expected total;
  /// guard against divide-by-zero when computing fractions.
  case progress(bytesTransferred: Int64, totalBytes: Int64)
}
