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

  // MARK: - Upload with progress

  /// Combine projection of `putData(_:events:completion:)`. The returned
  /// publisher emits `CloudStorageUploadEvent.progress(...)` values during
  /// the upload and finishes on success. Cancelling the subscription
  /// cancels the underlying upload; no terminal event is emitted in that
  /// case (canonical Combine semantic).
  ///
  /// **Threading.** Events and completion are delivered on Firebase's
  /// `Storage.callbackQueue` (default: `DispatchQueue.main`). Chain
  /// `.receive(on:)` if a different queue is required.
  ///
  /// **Single subscription.** The returned publisher is **not** multicast.
  /// Each subscription starts a new upload, and subscribing twice to the
  /// same publisher value leaks the first upload (the second subscription
  /// overwrites the captured task handle, so the first can no longer be
  /// cancelled). Use `.share()` / `.multicast(...)` only if the upstream
  /// is intentionally re-broadcast to multiple sinks; otherwise call the
  /// `…WithProgress(…)` method afresh per consumer.
  ///
  /// Switches over the emitted events MUST include `@unknown default` since
  /// `CloudStorageUploadEvent` is non-frozen.
  func putDataWithProgress(_ data: Data) -> AnyPublisher<CloudStorageUploadEvent, Error> {
    makeUploadPublisher { events, completion in
      self.putData(data, events: events, completion: completion)
    }
  }

  /// Combine projection of `putData(_:metadata:events:completion:)`.
  /// See `putDataWithProgress(_:)` for threading, cancellation, and
  /// single-subscription semantics.
  func putDataWithProgress(
    _ data: Data,
    metadata: CloudStorageMetadata
  ) -> AnyPublisher<CloudStorageUploadEvent, Error> {
    makeUploadPublisher { events, completion in
      self.putData(data, metadata: metadata, events: events, completion: completion)
    }
  }

  /// Combine projection of `uploadFromFile(localURL:events:completion:)`.
  /// See `putDataWithProgress(_:)` for threading, cancellation, and
  /// single-subscription semantics.
  func uploadFromFileWithProgress(localURL: URL) -> AnyPublisher<CloudStorageUploadEvent, Error> {
    makeUploadPublisher { events, completion in
      self.uploadFromFile(localURL: localURL, events: events, completion: completion)
    }
  }

  /// Combine projection of `uploadFromFile(localURL:metadata:events:completion:)`.
  /// See `putDataWithProgress(_:)` for threading, cancellation, and
  /// single-subscription semantics.
  func uploadFromFileWithProgress(
    localURL: URL,
    metadata: CloudStorageMetadata
  ) -> AnyPublisher<CloudStorageUploadEvent, Error> {
    makeUploadPublisher { events, completion in
      self.uploadFromFile(localURL: localURL, metadata: metadata, events: events, completion: completion)
    }
  }

  /// Wraps an upload-task-returning Tier-1 method as a Combine publisher.
  ///
  /// Single-subscription only: `subject` and `task` are captured per
  /// publisher instance, and a second subscription would overwrite the
  /// captured task and leak the first. Same shape as the snapshot
  /// publishers in `DocumentReference+Combine` / `Query+Combine` — see the
  /// public `…WithProgress` docs for the contract surfaced to consumers.
  private func makeUploadPublisher(
    start: @escaping (
      _ events: @escaping (CloudStorageUploadEvent) -> Void,
      _ completion: @escaping (Result<Void, Error>) -> Void
    ) -> CloudStorageUploadTaskProtocol
  ) -> AnyPublisher<CloudStorageUploadEvent, Error> {
    let subject = PassthroughSubject<CloudStorageUploadEvent, Error>()
    var task: CloudStorageUploadTaskProtocol?
    return subject
      .handleEvents(
        receiveSubscription: { _ in
          task = start(
            { event in subject.send(event) },
            { result in
              switch result {
              case .success: subject.send(completion: .finished)
              case .failure(let error): subject.send(completion: .failure(error))
              }
            }
          )
        },
        receiveCancel: { task?.cancel() }
      )
      .eraseToAnyPublisher()
  }

  // MARK: - Delete

  func delete() -> Future<Void, Error> {
    Future { promise in self.delete { promise($0) } }
  }
}
