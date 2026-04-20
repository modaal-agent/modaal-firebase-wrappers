// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest
import ModaalCloudStorage
final class CloudStorageWrapperSmokeTests: XCTestCase {
  override func setUp() async throws {
    try await super.setUp()
    try EmulatorHarness.skipIfDisabled()
    EmulatorHarness.configureFirebaseForEmulatorIfNeeded()
  }

  func testReferenceRootPathThroughProtocol() {
    let storage: CloudStorageProtocol = EmulatorHarness.makeStorage()
    let root: CloudStorageReferencing = storage.reference()
    XCTAssertEqual(root.fullPath, "")
    XCTAssertFalse(root.bucket.isEmpty)
  }

  func testReferenceWithPathThroughProtocol() {
    let storage: CloudStorageProtocol = EmulatorHarness.makeStorage()
    let ref: CloudStorageReferencing = storage.reference(withPath: "smoke/file.txt")
    XCTAssertEqual(ref.fullPath, "smoke/file.txt")
    XCTAssertEqual(ref.name, "file.txt")
  }
}
