// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public extension FirebaseAuthProtocol {

  // MARK: - One-shot operations

  func signInAnonymously() -> Future<FirebaseAuthDataResultProtocol, Error> {
    Future { promise in self.signInAnonymously { promise($0) } }
  }

  func signIn(with credential: FirebaseAuthCredentialProtocol) -> Future<FirebaseAuthDataResultProtocol, Error> {
    Future { promise in self.signIn(with: credential) { promise($0) } }
  }

  func signIn(withEmail email: String, password: String) -> Future<FirebaseAuthDataResultProtocol, Error> {
    Future { promise in self.signIn(withEmail: email, password: password) { promise($0) } }
  }

  func createUser(withEmail email: String, password: String) -> Future<FirebaseAuthDataResultProtocol, Error> {
    Future { promise in self.createUser(withEmail: email, password: password) { promise($0) } }
  }

  func sendPasswordReset(withEmail email: String) -> Future<Void, Error> {
    Future { promise in self.sendPasswordReset(withEmail: email) { promise($0) } }
  }

  func deleteUser(_ user: FirebaseUserProtocol) -> Future<Void, Error> {
    Future { promise in self.deleteUser(user) { promise($0) } }
  }

  func revokeToken(withAuthorizationCode authorizationCode: String) -> Future<Void, Error> {
    Future { promise in self.revokeToken(withAuthorizationCode: authorizationCode) { promise($0) } }
  }

  // MARK: - Streaming

  func authStateDidChangePublisher() -> AnyPublisher<FirebaseUserProtocol?, Never> {
    let subject = PassthroughSubject<FirebaseUserProtocol?, Never>()
    var handle: FirebaseAuthStateDidChangeListenerHandle?
    return subject
      .handleEvents(
        receiveSubscription: { _ in
          handle = self.addStateDidChangeListener { _, user in
            subject.send(user)
          }
        },
        receiveCancel: {
          if let handle { self.removeStateDidChangeListener(handle) }
        }
      )
      .eraseToAnyPublisher()
  }
}
