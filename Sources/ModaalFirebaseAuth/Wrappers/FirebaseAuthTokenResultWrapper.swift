// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseAuth

final class FirebaseAuthTokenResultWrapper: FirebaseAuthTokenResultProtocol {
  let result: AuthTokenResult

  init(result: AuthTokenResult) {
    self.result = result
  }

  // MARK: - FirebaseAuthTokenResultProtocol
  var token: String { result.token }
  var expirationDate: Date { result.expirationDate }
  var authDate: Date { result.authDate }
  var issuedAtDate: Date { result.issuedAtDate }
  var signInProvider: String { result.signInProvider }
  var claims: [String: Any] { result.claims }
}
