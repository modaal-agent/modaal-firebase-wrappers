// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseStorage
import Foundation

/// Concrete wrapper over `FirebaseStorage.StorageUploadTask` that conforms
/// to `CloudStorageUploadTaskProtocol`. Returned by the progress-aware
/// upload methods on `CloudStorageReference`.
final class CloudStorageUploadTask: CloudStorageUploadTaskProtocol {

  private let task: StorageUploadTask

  init(task: StorageUploadTask) {
    self.task = task
  }

  func cancel() {
    task.cancel()
  }

  func pause() {
    task.pause()
  }

  func resume() {
    task.resume()
  }
}
