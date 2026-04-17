// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseStorage

public final class CloudStorageWrapper: CloudStorageProtocol {
  /// The underlying `Storage` instance. Use for APIs not yet covered by this wrapper.
  /// Requires `import FirebaseStorage` at the call site.
  public let storage: Storage

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
