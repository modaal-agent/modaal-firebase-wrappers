// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.
//
// Firebase Emulator Suite has no Remote Config emulator. This smoke test
// exercises the defaults path: setDefaults → configValue(forKey:) round-trip.

import XCTest
import FirebaseRemoteConfig
import ModaalFirebaseRemoteConfig
final class FirebaseRemoteConfigWrapperSmokeTests: XCTestCase {
  override func setUp() {
    super.setUp()
    EmulatorHarness.configureFirebaseForEmulatorIfNeeded()
  }

  func testDefaultsRoundTripThroughProtocol() {
    let remoteConfig: FirebaseRemoteConfigProtocol =
      FirebaseRemoteConfigWrapper(remoteConfig: RemoteConfig.remoteConfig())
    remoteConfig.setDefaults(["smoke_flag": "on" as NSString])

    let value: RemoteConfigValueProtocol = remoteConfig.configValue(forKey: "smoke_flag")
    XCTAssertEqual(value.stringValue, "on")
    XCTAssertEqual(value.source, .default)
  }
}
