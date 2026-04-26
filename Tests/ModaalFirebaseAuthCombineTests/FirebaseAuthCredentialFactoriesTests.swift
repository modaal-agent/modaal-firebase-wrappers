// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest
import ModaalFirebaseAuth

/// Verifies the static factory extensions in
/// `Wrappers/FirebaseAuthCredential+Providers.swift` — `FirebaseAuthCredentialProtocol.apple(...)`
/// and `.google(...)`. Asserts that:
///
/// 1. Each factory resolves under `import ModaalFirebaseAuth` alone (no
///    `import FirebaseAuth` required at the call site).
/// 2. Each returns a value typed as `FirebaseAuthCredentialProtocol`.
/// 3. The `provider` field on the returned credential matches the well-known
///    Firebase provider ID for each provider.
///
/// The tests do NOT perform a sign-in flow — they verify the construction
/// path. End-to-end provider flows live in `Tests/EmulatorTests/` (where the
/// emulator can issue and validate ID tokens).
///
/// Notably uses `import ModaalFirebaseAuth` *without* `@testable` and
/// *without* `import FirebaseAuth` — if either becomes necessary, the
/// factories have stopped serving their purpose.
final class FirebaseAuthCredentialFactoriesTests: XCTestCase {

  func testAppleFactoryResolvesAndCarriesAppleProviderID() {
    // Use a syntactically valid (but obviously non-cryptographic) JWT-shaped
    // token so the factory accepts it. Firebase does not validate token
    // contents at construction time.
    let credential: FirebaseAuthCredentialProtocol = .apple(
      idToken: "header.payload.signature",
      rawNonce: "test-nonce",
      fullName: nil,
    )
    XCTAssertEqual(credential.provider, "apple.com")
  }

  func testAppleFactoryAcceptsFullName() {
    var name = PersonNameComponents()
    name.givenName = "Ada"
    name.familyName = "Lovelace"
    let credential: FirebaseAuthCredentialProtocol = .apple(
      idToken: "header.payload.signature",
      rawNonce: "test-nonce",
      fullName: name,
    )
    XCTAssertEqual(credential.provider, "apple.com")
  }

  func testGoogleFactoryResolvesAndCarriesGoogleProviderID() {
    let credential: FirebaseAuthCredentialProtocol = .google(
      idToken: "google-id-token",
      accessToken: "google-access-token",
    )
    XCTAssertEqual(credential.provider, "google.com")
  }

}
