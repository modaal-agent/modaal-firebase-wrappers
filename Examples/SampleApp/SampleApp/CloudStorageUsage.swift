// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation
import ModaalCloudStorage

// MARK: - CloudStorageProtocol

/// Exercises every method on CloudStorageProtocol.
/// This function is never called — it only needs to compile.
func exerciseCloudStorage(_ storage: CloudStorageProtocol) {
  let _: CloudStorageReferencing = storage.reference()
  let _: CloudStorageReferencing = storage.reference(forURL: "gs://bucket/path")
  let _: CloudStorageReferencing = storage.reference(withPath: "images/photo.jpg")
}

// MARK: - CloudStorageReferencing

/// Exercises every property/method on CloudStorageReferencing
/// (including inherited CloudCollectionStoring and CloudFileStoring).
func exerciseStorageRef(_ ref: CloudStorageReferencing) {
  // Properties
  _ = ref.fullPath
  _ = ref.name
  _ = ref.bucket

  // Navigation
  let _: CloudStorageReferencing = ref.child(path: "subfolder/file.png")
  let _: CloudStorageReferencing? = ref.parent()
  let _: CloudStorageReferencing = ref.root()

  // Navigation chain
  let nested = ref.child(path: "a").child(path: "b")
  _ = nested.parent()
  _ = nested.root()

  // Inherited CloudFileStoring
  exerciseFileStoring(ref)

  // Inherited CloudCollectionStoring
  exerciseCollectionStoring(ref)
}

// MARK: - CloudFileStoring

/// Exercises every method on CloudFileStoring.
func exerciseFileStoring(_ file: CloudFileStoring) {
  // Downloads
  file.getData(maxSize: 10 * 1024 * 1024) { result in
    switch result {
    case .success(let data): _ = data.count
    case .failure: break
    }
  }

  file.downloadToFile(localURL: URL(fileURLWithPath: "/tmp/file")) { result in
    switch result {
    case .success(let url): _ = url.path
    case .failure: break
    }
  }

  file.getDownloadURL { result in
    switch result {
    case .success(let url): _ = url.absoluteString
    case .failure: break
    }
  }

  // Metadata
  file.getMetadata { result in
    switch result {
    case .success(let metadata):
      _ = metadata.contentType
      _ = metadata.size
    case .failure: break
    }
  }

  file.updateMetadata(CloudStorageMetadata(contentType: "image/jpeg")) { result in
    switch result {
    case .success(let updated): _ = updated.contentType
    case .failure: break
    }
  }

  // Uploads (without metadata)
  file.putData(Data()) { _ in }
  file.uploadFromFile(localURL: URL(fileURLWithPath: "/tmp/file")) { _ in }

  // Uploads (with metadata)
  let meta = CloudStorageMetadata(contentType: "image/png", customMetadata: ["source": "camera"])
  file.putData(Data(), metadata: meta) { _ in }
  file.uploadFromFile(localURL: URL(fileURLWithPath: "/tmp/file"), metadata: meta) { _ in }

  // Delete
  file.delete { _ in }
}

// MARK: - CloudCollectionStoring

/// Exercises every method on CloudCollectionStoring.
func exerciseCollectionStoring(_ collection: CloudCollectionStoring) {
  collection.listAll { result in
    switch result {
    case .success(let listResult):
      _ = listResult.prefixes()
      _ = listResult.items()
    case .failure: break
    }
  }
}

// MARK: - CloudStorageListResultProtocol

/// Exercises every method on CloudStorageListResultProtocol.
func exerciseListResult(_ result: CloudStorageListResultProtocol) {
  let _: [CloudStorageReferencing] = result.prefixes()
  let _: [CloudStorageReferencing] = result.items()
}

// MARK: - CloudStorageMetadata

/// Exercises CloudStorageMetadata struct.
func exerciseCloudStorageMetadata() {
  // Upload metadata (settable properties)
  var meta = CloudStorageMetadata(contentType: "application/pdf")
  meta.contentType = "image/jpeg"
  meta.cacheControl = "max-age=3600"
  meta.customMetadata = ["author": "Alice"]

  // Read-only properties (populated from server response)
  _ = meta.size
  _ = meta.name
  _ = meta.path
  _ = meta.timeCreated
  _ = meta.updated
  _ = meta.md5Hash
}

// MARK: - FileStoring

/// Exercises FileStoring protocol.
func exerciseFileStoringProtocol(_ store: FileStoring) {
  let _: FileStoring = store.file(path: "documents/report.pdf")
}

// MARK: - Combine extensions

import Combine

/// Exercises Combine API on CloudFileStoring.
func exerciseFileStoringCombine(_ file: CloudFileStoring) {
  // Downloads
  let _: Future<Data, Error> = file.getData(maxSize: 10 * 1024 * 1024)
  let _: Future<URL, Error> = file.downloadToFile(localURL: URL(fileURLWithPath: "/tmp/file"))
  let _: Future<URL, Error> = file.getDownloadURL()

  // Metadata
  let _: Future<CloudStorageMetadata, Error> = file.getMetadata()
  let _: Future<CloudStorageMetadata, Error> = file.updateMetadata(CloudStorageMetadata(contentType: "image/jpeg"))

  // Uploads
  let _: Future<Void, Error> = file.putData(Data())
  let _: Future<Void, Error> = file.putData(Data(), metadata: CloudStorageMetadata(contentType: "image/png"))
  let _: Future<Void, Error> = file.uploadFromFile(localURL: URL(fileURLWithPath: "/tmp/file"))
  let _: Future<Void, Error> = file.uploadFromFile(localURL: URL(fileURLWithPath: "/tmp/file"), metadata: CloudStorageMetadata(contentType: "image/png"))

  // Delete
  let _: Future<Void, Error> = file.delete()
}

/// Exercises Combine API on CloudCollectionStoring.
func exerciseCollectionStoringCombine(_ collection: CloudCollectionStoring) {
  let _: Future<CloudStorageListResultProtocol, Error> = collection.listAll()
}

// MARK: - Wrapper instantiation

/// Exercises wrapper construction (proves the concrete type compiles).
func exerciseCloudStorageWrapperInstantiation() {
  let _: CloudStorageWrapper.Type = CloudStorageWrapper.self
}
