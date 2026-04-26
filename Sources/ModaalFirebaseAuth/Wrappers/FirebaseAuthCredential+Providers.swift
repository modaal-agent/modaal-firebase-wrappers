// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseAuth

// Static factories on `FirebaseAuthCredentialProtocol` so consumers can
// construct Apple / Google / generic-OAuth credentials without an `import
// FirebaseAuth` at the credential-construction site. The returned
// `AuthCredential` already conforms to `FirebaseAuthCredentialProtocol` via
// `FirebaseAuthExtensions.swift` — these factories surface the well-known
// provider entry points behind the wrapper boundary.
//
// Pattern matches `FirebaseCrashlyticsProtocol.makeDefault()` (constrained
// extension where `Self` is the concrete Firebase class). Call via
// implicit-member syntax:
//
// ```swift
// let credential: FirebaseAuthCredentialProtocol = .apple(idToken: idToken,
//                                                          rawNonce: rawNonce,
//                                                          fullName: nil)
// _ = try await auth.signIn(with: credential)
// ```

public extension FirebaseAuthCredentialProtocol where Self == FirebaseAuth.AuthCredential {
  /// Construct an Apple Sign-In credential from the ID token + raw nonce
  /// returned by `ASAuthorizationAppleIDCredential`.
  ///
  /// Equivalent to
  /// `OAuthProvider.appleCredential(withIDToken:rawNonce:fullName:)` but
  /// requires no `import FirebaseAuth` at the call site.
  ///
  /// `provider` on the returned credential is `"apple.com"`.
  static func apple(
    idToken: String,
    rawNonce: String,
    fullName: PersonNameComponents? = nil
  ) -> Self {
    OAuthProvider.appleCredential(
      withIDToken: idToken,
      rawNonce: rawNonce,
      fullName: fullName,
    )
  }

  /// Construct a Google Sign-In credential from the ID token + access token
  /// returned by `GIDSignIn.sharedInstance.signIn(...)`.
  ///
  /// Equivalent to
  /// `GoogleAuthProvider.credential(withIDToken:accessToken:)` but requires
  /// no `import FirebaseAuth` at the call site.
  ///
  /// `provider` on the returned credential is `"google.com"`.
  static func google(idToken: String, accessToken: String) -> Self {
    GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
  }

  // Note: a generic `oauth(providerID:idToken:rawNonce:accessToken:)` factory
  // for Microsoft / Yahoo / custom OIDC providers is intentionally NOT
  // provided in this release. Firebase iOS SDK 12.x marked the
  // String-providerID `OAuthProvider.credential(withProviderID:...)`
  // overloads as `unavailable in Swift`; the replacement uses an
  // `AuthProviderID` enum, which would require importing `FirebaseAuth` at
  // the call site (defeating the purpose of this factory) or introducing a
  // wrapper enum (`ModaalAuthProviderID`) — design TBD. Until then, OIDC
  // remains escape-hatch territory:
  //
  // ```swift
  // import FirebaseAuth  // only at this call site
  // let credential: FirebaseAuthCredentialProtocol = OAuthProvider.credential(
  //   providerID: .custom("oidc.my-provider"),
  //   idToken: idToken,
  //   rawNonce: rawNonce,
  //   accessToken: accessToken,
  // )
  // ```
}
