// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public protocol CloudFileStoring {

  // MARK: - Download data

  /// Asynchronously downloads the object at the storage reference to a `Data` object.
  ///
  /// A `Data` of the provided max size will be allocated, so ensure that the device has enough
  /// memory to complete. For downloading large files, the `downloadToFile` API may be a better option.
  func getData(maxSize: Int64) -> AnyPublisher<Data, Error>

  /// Asynchronously downloads the object at the current path to a specified system filepath.
  func downloadToFile(localURL: URL) -> AnyPublisher<URL, Error>

  /// Asynchronously retrieves a long lived download URL with a revokable token.
  ///
  /// This can be used to share the file with others, but can be revoked by a developer
  /// in the Firebase Console.
  func getDownloadURL() -> AnyPublisher<URL, Error>

  // MARK: - Upload data

  /// Asynchronously uploads data to the currently specified storage reference.
  /// This is not recommended for large files, and one should instead upload a file from disk.
  func putData(_ data: Data) -> AnyPublisher<Void, Error>

  /// Asynchronously uploads a file to the currently specified storage reference.
  func uploadFromFile(localURL: URL) -> AnyPublisher<Void, Error>

  /// Asynchronously delete the object at the current path.
  func delete() -> AnyPublisher<Void, Error>
}
