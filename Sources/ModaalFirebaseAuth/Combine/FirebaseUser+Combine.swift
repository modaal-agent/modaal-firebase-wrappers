// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public extension FirebaseUserProtocol {

  func link(with credential: FirebaseAuthCredentialProtocol) -> Future<FirebaseAuthDataResultProtocol, Error> {
    Future { promise in self.link(with: credential) { promise($0) } }
  }

  func unlink(fromProvider provider: String) -> Future<FirebaseUserProtocol, Error> {
    Future { promise in self.unlink(fromProvider: provider) { promise($0) } }
  }

  func reauthenticate(with credential: FirebaseAuthCredentialProtocol) -> Future<FirebaseAuthDataResultProtocol, Error> {
    Future { promise in self.reauthenticate(with: credential) { promise($0) } }
  }

  func sendEmailVerification() -> Future<Void, Error> {
    Future { promise in self.sendEmailVerification { promise($0) } }
  }

  func updateUserProfile(displayName: String?, photoURL: URL?) -> Future<Void, Error> {
    Future { promise in self.updateUserProfile(displayName: displayName, photoURL: photoURL) { promise($0) } }
  }

  func updatePassword(to password: String) -> Future<Void, Error> {
    Future { promise in self.updatePassword(to: password) { promise($0) } }
  }

  func reload() -> Future<Void, Error> {
    Future { promise in self.reload { promise($0) } }
  }

  func getIDToken() -> Future<String, Error> {
    Future { promise in self.getIDToken { promise($0) } }
  }

  func getIDTokenResult() -> Future<FirebaseAuthTokenResultProtocol, Error> {
    Future { promise in self.getIDTokenResult { promise($0) } }
  }
}
