// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest
import ModaalCloudStorage
final class CloudStorageIntegrationTests: XCTestCase {
  private var storage: CloudStorageProtocol!

  override func setUp() async throws {
    try await super.setUp()
    try EmulatorHarness.skipIfDisabled()
    EmulatorHarness.configureFirebaseForEmulatorIfNeeded()
    storage = EmulatorHarness.makeStorage()
  }

  func testPutGetRoundTrip() async throws {
    let ref: CloudStorageReferencing = storage.reference(withPath: "integ/\(UUID().uuidString).txt")
    let payload = Data("hello cloud storage".utf8)

    try await put(ref, payload)
    let fetched = try await get(ref)
    XCTAssertEqual(fetched, payload)

    try await delete(ref)
  }

  func testMetadataIsReadableAfterUpload() async throws {
    let ref: CloudStorageReferencing = storage.reference(withPath: "integ/\(UUID().uuidString).txt")
    let payload = Data("m".utf8)

    try await put(ref, payload)
    let metadata: CloudStorageMetadata = try await metadata(ref)
    XCTAssertEqual(metadata.size, Int64(payload.count))
    XCTAssertEqual(metadata.path, ref.fullPath)

    try await delete(ref)
  }

  func testDeleteMakesGetFail() async throws {
    let ref: CloudStorageReferencing = storage.reference(withPath: "integ/\(UUID().uuidString).txt")
    try await put(ref, Data("x".utf8))
    try await delete(ref)

    do {
      _ = try await get(ref)
      XCTFail("Expected get to fail after delete")
    } catch {
      // Expected — object was deleted
    }
  }

  // MARK: - Upload with progress (Wave 1)

  func testPutDataReportsProgressAndCompletes() async throws {
    let ref: CloudStorageReferencing = storage.reference(withPath: "integ/\(UUID().uuidString).bin")
    // ~1 MiB so the emulator emits multiple progress ticks reliably.
    let payload = Data(repeating: 0x41, count: 1024 * 1024)

    let lock = NSLock()
    var progressTicks: [(Int64, Int64)] = []

    try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
      _ = ref.putData(
        payload,
        events: { event in
          if case .progress(let sent, let total) = event {
            lock.lock()
            progressTicks.append((sent, total))
            lock.unlock()
          }
        },
        completion: { cont.resume(with: $0) }
      )
    }

    XCTAssertFalse(progressTicks.isEmpty, "Expected at least one progress event")
    let last = progressTicks.last!
    XCTAssertEqual(last.0, Int64(payload.count), "Final bytesTransferred should equal payload size")
    XCTAssertEqual(last.1, Int64(payload.count), "Final totalBytes should equal payload size")

    try await delete(ref)
  }

  func testPutDataCancelSurfacesFailure() async throws {
    let ref: CloudStorageReferencing = storage.reference(withPath: "integ/\(UUID().uuidString).bin")
    // Large enough that the upload is unlikely to finish before we cancel.
    let payload = Data(repeating: 0x42, count: 8 * 1024 * 1024)

    let result = await withCheckedContinuation { (cont: CheckedContinuation<Result<Void, Error>, Never>) in
      let task = ref.putData(
        payload,
        events: { _ in },
        completion: { cont.resume(returning: $0) }
      )
      // Cancel on the next runloop tick — after the upload starts, before completion.
      DispatchQueue.main.async { task.cancel() }
    }

    switch result {
    case .success:
      XCTFail("Expected cancellation to surface as .failure")
    case .failure(let error):
      let ns = error as NSError
      // StorageErrorCode.cancelled == -13040
      XCTAssertEqual(ns.code, -13040, "Expected StorageErrorCode.cancelled, got \(ns)")
    }

    // Best-effort cleanup; the object may or may not exist depending on cancel timing.
    try? await delete(ref)
  }

  // MARK: - Protocol-only async helpers

  private func put(_ ref: CloudStorageReferencing, _ data: Data) async throws {
    try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
      ref.putData(data) { result in
        cont.resume(with: result)
      }
    }
  }

  private func get(_ ref: CloudStorageReferencing) async throws -> Data {
    try await withCheckedThrowingContinuation { cont in
      ref.getData(maxSize: 10 * 1024 * 1024) { result in
        cont.resume(with: result)
      }
    }
  }

  private func metadata(_ ref: CloudStorageReferencing) async throws -> CloudStorageMetadata {
    try await withCheckedThrowingContinuation { cont in
      ref.getMetadata { result in
        cont.resume(with: result)
      }
    }
  }

  private func delete(_ ref: CloudStorageReferencing) async throws {
    try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
      ref.delete { result in
        cont.resume(with: result)
      }
    }
  }
}
