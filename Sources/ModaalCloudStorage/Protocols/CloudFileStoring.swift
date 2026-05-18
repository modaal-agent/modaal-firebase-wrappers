// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol CloudFileStoring {

  // MARK: - Download data

  /// Asynchronously downloads the object at the storage reference to a `Data` object.
  ///
  /// A `Data` of the provided max size will be allocated, so ensure that the device has enough
  /// memory to complete. For downloading large files, the `downloadToFile` API may be a better option.
  func getData(maxSize: Int64, completion: @escaping (Result<Data, Error>) -> Void)

  /// Asynchronously downloads the object at the current path to a specified system filepath.
  func downloadToFile(localURL: URL, completion: @escaping (Result<URL, Error>) -> Void)

  /// Asynchronously retrieves a long lived download URL with a revokable token.
  ///
  /// This can be used to share the file with others, but can be revoked by a developer
  /// in the Firebase Console.
  ///
  /// Canonical Firebase iOS SDK name. The `getDownloadURL(completion:)` form is
  /// available as a Swift-idiomatic alias in `Extensions/CloudFileStoring+Idioms.swift`.
  func downloadURL(completion: @escaping (Result<URL, Error>) -> Void)

  // MARK: - Metadata

  /// Asynchronously retrieves metadata for the object at the current path.
  func getMetadata(completion: @escaping (Result<CloudStorageMetadata, Error>) -> Void)

  /// Asynchronously updates metadata for the object at the current path.
  func updateMetadata(_ metadata: CloudStorageMetadata, completion: @escaping (Result<CloudStorageMetadata, Error>) -> Void)

  // MARK: - Upload data

  /// Asynchronously uploads data to the currently specified storage reference.
  /// This is not recommended for large files, and one should instead upload a file from disk.
  func putData(_ data: Data, completion: @escaping (Result<Void, Error>) -> Void)

  /// Asynchronously uploads data with metadata (e.g., content type).
  func putData(_ data: Data, metadata: CloudStorageMetadata, completion: @escaping (Result<Void, Error>) -> Void)

  /// Asynchronously uploads a file to the currently specified storage reference.
  func uploadFromFile(localURL: URL, completion: @escaping (Result<Void, Error>) -> Void)

  /// Asynchronously uploads a file with metadata (e.g., content type).
  func uploadFromFile(localURL: URL, metadata: CloudStorageMetadata, completion: @escaping (Result<Void, Error>) -> Void)

  // MARK: - Upload with progress

  /// Asynchronously uploads data while reporting determinate progress events
  /// to `events`, and returns a handle that can cancel the in-flight upload.
  ///
  /// `events` is invoked one or more times with `.progress(...)` ticks until
  /// the upload finishes via `completion` (success or failure). The handle
  /// remains valid after completion; `cancel()` is idempotent.
  ///
  /// `CloudStorageUploadEvent` is non-frozen — switches over it MUST include
  /// an `@unknown default` case to remain source-compatible with future
  /// versions that may add new event cases.
  @discardableResult
  func putData(
    _ data: Data,
    events: @escaping (CloudStorageUploadEvent) -> Void,
    completion: @escaping (Result<Void, Error>) -> Void
  ) -> CloudStorageUploadTaskProtocol

  /// Asynchronously uploads data with metadata while reporting determinate
  /// progress events. See `putData(_:events:completion:)` for details.
  @discardableResult
  func putData(
    _ data: Data,
    metadata: CloudStorageMetadata,
    events: @escaping (CloudStorageUploadEvent) -> Void,
    completion: @escaping (Result<Void, Error>) -> Void
  ) -> CloudStorageUploadTaskProtocol

  /// Asynchronously uploads a file from disk while reporting determinate
  /// progress events. See `putData(_:events:completion:)` for details.
  @discardableResult
  func uploadFromFile(
    localURL: URL,
    events: @escaping (CloudStorageUploadEvent) -> Void,
    completion: @escaping (Result<Void, Error>) -> Void
  ) -> CloudStorageUploadTaskProtocol

  /// Asynchronously uploads a file from disk with metadata while reporting
  /// determinate progress events. See `putData(_:events:completion:)` for details.
  @discardableResult
  func uploadFromFile(
    localURL: URL,
    metadata: CloudStorageMetadata,
    events: @escaping (CloudStorageUploadEvent) -> Void,
    completion: @escaping (Result<Void, Error>) -> Void
  ) -> CloudStorageUploadTaskProtocol

  /// Asynchronously delete the object at the current path.
  func delete(completion: @escaping (Result<Void, Error>) -> Void)
}
