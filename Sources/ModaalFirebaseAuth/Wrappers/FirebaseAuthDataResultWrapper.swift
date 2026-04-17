// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseAuth

final class FirebaseAuthDataResultWrapper: FirebaseAuthDataResultProtocol {
  let result: FirebaseAuth.AuthDataResult

  init(result: FirebaseAuth.AuthDataResult) {
    self.result = result
  }

  // MARK: - FirebaseAuthDataResultProtocol
  var user: FirebaseUserProtocol { FirebaseUserWrapper(user: result.user) }
  var credential: FirebaseAuthCredentialProtocol? { result.credential }
}
