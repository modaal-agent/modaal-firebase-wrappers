// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
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
  let _: AnyPublisher<Data, Error> = file.getData(maxSize: 10 * 1024 * 1024)
  let _: AnyPublisher<URL, Error> = file.downloadToFile(localURL: URL(fileURLWithPath: "/tmp/file"))
  let _: AnyPublisher<URL, Error> = file.getDownloadURL()

  // Metadata
  let _: AnyPublisher<CloudStorageMetadata, Error> = file.getMetadata()
  let _: AnyPublisher<CloudStorageMetadata, Error> = file.updateMetadata(
    CloudStorageMetadata(contentType: "image/jpeg")
  )

  // Uploads (without metadata)
  let _: AnyPublisher<Void, Error> = file.putData(Data())
  let _: AnyPublisher<Void, Error> = file.uploadFromFile(localURL: URL(fileURLWithPath: "/tmp/file"))

  // Uploads (with metadata)
  let meta = CloudStorageMetadata(contentType: "image/png", customMetadata: ["source": "camera"])
  let _: AnyPublisher<Void, Error> = file.putData(Data(), metadata: meta)
  let _: AnyPublisher<Void, Error> = file.uploadFromFile(localURL: URL(fileURLWithPath: "/tmp/file"), metadata: meta)

  // Delete
  let _: AnyPublisher<Void, Error> = file.delete()
}

// MARK: - CloudCollectionStoring

/// Exercises every method on CloudCollectionStoring.
func exerciseCollectionStoring(_ collection: CloudCollectionStoring) {
  let _: AnyPublisher<CloudStorageListResultProtocol, Error> = collection.listAll()
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

// MARK: - Wrapper instantiation

/// Exercises wrapper construction (proves the concrete type compiles).
func exerciseCloudStorageWrapperInstantiation() {
  let _: CloudStorageWrapper.Type = CloudStorageWrapper.self
}
