// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public extension CloudFileStoring {

  // MARK: - Download

  func getData(maxSize: Int64) -> Future<Data, Error> {
    Future { promise in self.getData(maxSize: maxSize) { promise($0) } }
  }

  func downloadToFile(localURL: URL) -> Future<URL, Error> {
    Future { promise in self.downloadToFile(localURL: localURL) { promise($0) } }
  }

  // Canonical Firebase iOS SDK signature (Combine variant).
  func downloadURL() -> Future<URL, Error> {
    Future { promise in self.downloadURL { promise($0) } }
  }

  // Swift-idiomatic alias — preserved for ergonomics; delegates to canonical.
  // See Extensions/CloudFileStoring+Idioms.swift.
  func getDownloadURL() -> Future<URL, Error> {
    Future { promise in self.getDownloadURL { promise($0) } }
  }

  // MARK: - Metadata

  func getMetadata() -> Future<CloudStorageMetadata, Error> {
    Future { promise in self.getMetadata { promise($0) } }
  }

  func updateMetadata(_ metadata: CloudStorageMetadata) -> Future<CloudStorageMetadata, Error> {
    Future { promise in self.updateMetadata(metadata) { promise($0) } }
  }

  // MARK: - Upload

  func putData(_ data: Data) -> Future<Void, Error> {
    Future { promise in self.putData(data) { promise($0) } }
  }

  func putData(_ data: Data, metadata: CloudStorageMetadata) -> Future<Void, Error> {
    Future { promise in self.putData(data, metadata: metadata) { promise($0) } }
  }

  func uploadFromFile(localURL: URL) -> Future<Void, Error> {
    Future { promise in self.uploadFromFile(localURL: localURL) { promise($0) } }
  }

  func uploadFromFile(localURL: URL, metadata: CloudStorageMetadata) -> Future<Void, Error> {
    Future { promise in self.uploadFromFile(localURL: localURL, metadata: metadata) { promise($0) } }
  }

  // MARK: - Delete

  func delete() -> Future<Void, Error> {
    Future { promise in self.delete { promise($0) } }
  }
}
