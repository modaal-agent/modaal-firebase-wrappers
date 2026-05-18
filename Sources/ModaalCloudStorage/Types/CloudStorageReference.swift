// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseStorage
import Foundation

public final class CloudStorageReference: CloudStorageReferencing {

  /// The underlying `StorageReference`. Use for APIs not yet covered by this wrapper.
  /// Requires `import FirebaseStorage` at the call site.
  public let reference: StorageReference

  init(reference: StorageReference) {
    self.reference = reference
  }

  // MARK: - CloudStorageReferencing

  public var fullPath: String { reference.fullPath }
  public var name: String { reference.name }
  public var bucket: String { reference.bucket }

  public func child(_ pathString: String) -> CloudStorageReferencing {
    CloudStorageReference(reference: reference.child(pathString))
  }

  public func parent() -> CloudStorageReferencing? {
    guard let parent = reference.parent() else {
      return nil
    }
    return CloudStorageReference(reference: parent)
  }

  public func root() -> CloudStorageReferencing {
    CloudStorageReference(reference: reference.root())
  }

  // MARK: - CloudCollectionStoring

  public func listAll(completion: @escaping (Result<CloudStorageListResultProtocol, Error>) -> Void) {
    reference.listAll { result in
      completion(result.map { CloudStorageListResult(result: $0) })
    }
  }

  // MARK: - Metadata

  public func getMetadata(completion: @escaping (Result<CloudStorageMetadata, Error>) -> Void) {
    reference.getMetadata { metadata, error in
      if let metadata {
        completion(.success(CloudStorageMetadata.from(metadata)))
      } else {
        completion(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
  }

  public func updateMetadata(_ metadata: CloudStorageMetadata, completion: @escaping (Result<CloudStorageMetadata, Error>) -> Void) {
    reference.updateMetadata(metadata.toStorageMetadata()) { updated, error in
      if let updated {
        completion(.success(CloudStorageMetadata.from(updated)))
      } else {
        completion(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
  }

  // MARK: - CloudFileStoring (downloads)

  public func getData(maxSize: Int64, completion: @escaping (Result<Data, Error>) -> Void) {
    reference.getData(maxSize: maxSize) { result in
      completion(result)
    }
  }

  public func downloadToFile(localURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
    reference.write(toFile: localURL) { result in
      completion(result)
    }
  }

  public func downloadURL(completion: @escaping (Result<URL, Error>) -> Void) {
    reference.downloadURL { result in
      completion(result)
    }
  }

  // MARK: - CloudFileStoring (uploads)

  public func putData(_ data: Data, completion: @escaping (Result<Void, Error>) -> Void) {
    reference.putData(data) { result in
      completion(result.map { _ in () })
    }
  }

  public func putData(_ data: Data, metadata: CloudStorageMetadata, completion: @escaping (Result<Void, Error>) -> Void) {
    reference.putData(data, metadata: metadata.toStorageMetadata()) { result in
      completion(result.map { _ in () })
    }
  }

  public func uploadFromFile(localURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
    reference.putFile(from: localURL) { result in
      completion(result.map { _ in () })
    }
  }

  public func uploadFromFile(localURL: URL, metadata: CloudStorageMetadata, completion: @escaping (Result<Void, Error>) -> Void) {
    reference.putFile(from: localURL, metadata: metadata.toStorageMetadata()) { result in
      completion(result.map { _ in () })
    }
  }

  // MARK: - CloudFileStoring (uploads with progress)

  @discardableResult
  public func putData(
    _ data: Data,
    events: @escaping (CloudStorageUploadEvent) -> Void,
    completion: @escaping (Result<Void, Error>) -> Void
  ) -> CloudStorageUploadTaskProtocol {
    observe(reference.putData(data), events: events, completion: completion)
  }

  @discardableResult
  public func putData(
    _ data: Data,
    metadata: CloudStorageMetadata,
    events: @escaping (CloudStorageUploadEvent) -> Void,
    completion: @escaping (Result<Void, Error>) -> Void
  ) -> CloudStorageUploadTaskProtocol {
    observe(
      reference.putData(data, metadata: metadata.toStorageMetadata()),
      events: events,
      completion: completion
    )
  }

  @discardableResult
  public func uploadFromFile(
    localURL: URL,
    events: @escaping (CloudStorageUploadEvent) -> Void,
    completion: @escaping (Result<Void, Error>) -> Void
  ) -> CloudStorageUploadTaskProtocol {
    observe(reference.putFile(from: localURL), events: events, completion: completion)
  }

  @discardableResult
  public func uploadFromFile(
    localURL: URL,
    metadata: CloudStorageMetadata,
    events: @escaping (CloudStorageUploadEvent) -> Void,
    completion: @escaping (Result<Void, Error>) -> Void
  ) -> CloudStorageUploadTaskProtocol {
    observe(
      reference.putFile(from: localURL, metadata: metadata.toStorageMetadata()),
      events: events,
      completion: completion
    )
  }

  /// Attaches `.progress`, `.success`, and `.failure` observers to a
  /// Firebase `StorageUploadTask` and returns a typed cancel handle.
  /// Firebase clears observers in `finishTaskWithStatus` on terminal states,
  /// so no manual observer removal is required.
  private func observe(
    _ task: StorageUploadTask,
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
    task.observe(.success) { _ in
      completion(.success(()))
    }
    task.observe(.failure) { snapshot in
      completion(.failure(snapshot.error ?? NSError(domain: "Unknown error", code: -1)))
    }
    return CloudStorageUploadTask(task: task)
  }

  // MARK: - CloudFileStoring (delete)

  public func delete(completion: @escaping (Result<Void, Error>) -> Void) {
    reference.delete { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }
}

// MARK: - CloudStorageMetadata bridging

extension CloudStorageMetadata {
  static func from(_ metadata: StorageMetadata) -> CloudStorageMetadata {
    CloudStorageMetadata(
      contentType: metadata.contentType,
      cacheControl: metadata.cacheControl,
      customMetadata: metadata.customMetadata,
      size: metadata.size,
      name: metadata.name,
      path: metadata.path,
      timeCreated: metadata.timeCreated,
      updated: metadata.updated,
      md5Hash: metadata.md5Hash
    )
  }

  func toStorageMetadata() -> StorageMetadata {
    let meta = StorageMetadata()
    meta.contentType = contentType
    meta.cacheControl = cacheControl
    meta.customMetadata = customMetadata
    return meta
  }
}
