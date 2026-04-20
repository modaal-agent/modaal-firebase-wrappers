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

  /// Build a wrapper around the default `Storage.storage()` instance,
  /// optionally pointing it at the local Firebase Emulator.
  ///
  /// Saves consumers from having to `import FirebaseStorage` just to run
  /// against the emulator — parallels `FirestoreWrapper.makeDefault`.
  public static func makeDefault(emulator: (host: String, port: Int)? = nil) -> CloudStorageWrapper {
    let storage = Storage.storage()
    if let emulator {
      storage.useEmulator(withHost: emulator.host, port: emulator.port)
    }
    return CloudStorageWrapper(storage: storage)
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
