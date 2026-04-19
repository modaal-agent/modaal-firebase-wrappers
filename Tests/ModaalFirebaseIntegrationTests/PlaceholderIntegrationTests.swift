// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest

final class PlaceholderIntegrationTests: XCTestCase {
  func testHarnessGatesOnEnvVar() throws {
    if EmulatorHarness.isEnabled {
      XCTAssertFalse(EmulatorHarness.host.isEmpty)
    } else {
      XCTAssertThrowsError(try EmulatorHarness.skipIfDisabled())
    }
  }
}
