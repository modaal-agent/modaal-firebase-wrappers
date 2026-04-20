// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.
//
// Remote Config has no Firebase Emulator. We still exercise the wrapper
// surface here (defaults-only) to keep the protocol-only contract symmetric
// with the other integration tests. `fetchAndActivate` is intentionally out
// of scope until there's an emulator for it.

import XCTest
import FirebaseRemoteConfig
import ModaalFirebaseRemoteConfig
final class RemoteConfigIntegrationTests: XCTestCase {
  private var remoteConfig: FirebaseRemoteConfigProtocol!

  override func setUp() {
    super.setUp()
    EmulatorHarness.configureFirebaseForEmulatorIfNeeded()
    remoteConfig = FirebaseRemoteConfigWrapper(remoteConfig: RemoteConfig.remoteConfig())
  }

  func testSetDefaultsIsReadableViaConfigValue() {
    remoteConfig.setDefaults([
      "welcome_text": "hi" as NSString,
      "retry_count": 5 as NSNumber,
      "feature_on": true as NSNumber,
    ])

    let welcome: RemoteConfigValueProtocol = remoteConfig.configValue(forKey: "welcome_text")
    XCTAssertEqual(welcome.stringValue, "hi")
    XCTAssertEqual(welcome.source, .default)

    let retry: RemoteConfigValueProtocol = remoteConfig.configValue(forKey: "retry_count")
    XCTAssertEqual(retry.numberValue.intValue, 5)

    let feature: RemoteConfigValueProtocol = remoteConfig.configValue(forKey: "feature_on")
    XCTAssertTrue(feature.boolValue)
  }

  func testAllKeysReturnsDefaults() {
    remoteConfig.setDefaults(["a": "1" as NSString, "b": "2" as NSString])
    let keys = Set(remoteConfig.allKeys(from: .default))
    XCTAssertTrue(keys.isSuperset(of: ["a", "b"]))
  }
}
