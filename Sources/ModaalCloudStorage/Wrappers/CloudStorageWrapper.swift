// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseStorage

public final class CloudStorageWrapper: CloudStorageProtocol {
  let storage: Storage

  public init(storage: Storage) {
    self.storage = storage
  }

  // MARK: - CloudStorageProtocol

  public func reference() -> CloudStorageReferencing {
    CloudStorageReference(reference: storage.reference())
  }

  public func reference(forURL url: String) -> CloudStorageReferencing {
    CloudStorageReference(reference: storage.reference(forURL: url))
  }

  public func reference(withPath path: String) -> CloudStorageReferencing {
    CloudStorageReference(reference: storage.reference(withPath: path))
  }
}
