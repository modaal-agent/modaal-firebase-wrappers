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
