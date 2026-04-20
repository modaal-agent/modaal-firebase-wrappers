// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import UIKit
import FirebaseAuth
import FirebaseCore

public final class FirebaseAuthWrapper: FirebaseAuthProtocol {
  /// The underlying `Auth` instance. Use for APIs not yet covered by this wrapper.
  /// Requires `import FirebaseAuth` at the call site.
  public let auth: Auth

  public init(auth: Auth) {
    self.auth = auth
  }

  /// Build a wrapper around the default `Auth.auth()` instance, optionally
  /// pointing it at the local Firebase Emulator.
  ///
  /// Saves consumers from having to `import FirebaseAuth` just to run
  /// against the emulator — parallels `FirestoreWrapper.makeDefault`.
  public static func makeDefault(emulator: (host: String, port: Int)? = nil) -> FirebaseAuthWrapper {
    let auth = Auth.auth()
    if let emulator {
      auth.useEmulator(withHost: emulator.host, port: emulator.port)
    }
    return FirebaseAuthWrapper(auth: auth)
  }

  // MARK: - FirebaseAuthProtocol

  public var shareAuthStateAcrossDevices: Bool {
    get { auth.shareAuthStateAcrossDevices }
    set { auth.shareAuthStateAcrossDevices = newValue }
  }

  public func useUserAccessGroup(_ userAccessGroup: String?) throws {
    try auth.useUserAccessGroup(userAccessGroup)
  }

  public var currentUser: FirebaseUserProtocol? { FirebaseUserWrapper.from(user: auth.currentUser) }

  public func addStateDidChangeListener(_ listener: @escaping (FirebaseAuthProtocol, FirebaseUserProtocol?) -> Void) -> FirebaseAuthStateDidChangeListenerHandle {
    return auth.addStateDidChangeListener { auth, user in
      listener(FirebaseAuthWrapper(auth: auth), FirebaseUserWrapper.from(user: user))
    }
  }

  public func removeStateDidChangeListener(_ handle: FirebaseAuthStateDidChangeListenerHandle) {
    auth.removeStateDidChangeListener(handle)
  }

  public func signInAnonymously(completion: @escaping (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) {
    auth.signInAnonymously { result, error in
      if let result {
        completion(.success(FirebaseAuthDataResultWrapper(result: result)))
      } else {
        let error = error ?? NSError(domain: "Unknown error", code: -1)
        completion(.failure(error))
      }
    }
  }

  public func signIn(with credential: FirebaseAuthCredentialProtocol, completion: @escaping (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) {
    auth.signIn(with: credential as! AuthCredential) { result, error in
      if let result {
        completion(.success(FirebaseAuthDataResultWrapper(result: result)))
      } else {
        let error = error ?? NSError(domain: "Unknown error", code: -1)
        completion(.failure(error))
      }
    }
  }

  public func signIn(withEmail email: String, password: String, completion: @escaping (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) {
    auth.signIn(withEmail: email, password: password) { result, error in
      if let result {
        completion(.success(FirebaseAuthDataResultWrapper(result: result)))
      } else {
        let error = error ?? NSError(domain: "Unknown error", code: -1)
        completion(.failure(error))
      }
    }
  }

  public func signOut() throws {
    try auth.signOut()
  }

  public func createUser(withEmail email: String, password: String, completion: @escaping (Result<FirebaseAuthDataResultProtocol, Error>) -> ()) {
    auth.createUser(withEmail: email, password: password) { result, error in
      if let result {
        completion(.success(FirebaseAuthDataResultWrapper(result: result)))
      } else {
        let error = error ?? NSError(domain: "Unknown error", code: -1)
        completion(.failure(error))
      }
    }
  }

  public func sendPasswordReset(withEmail email: String, completion: @escaping (Result<Void, Error>) -> ()) {
    auth.sendPasswordReset(withEmail: email) { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  public func deleteUser(_ user: FirebaseUserProtocol, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let user = user as? FirebaseUserWrapper else { return }

    user.user.delete { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  public func revokeToken(withAuthorizationCode authorizationCode: String, completion: @escaping (Result<Void, Error>) -> Void) {
    Task {
      do {
        try await auth.revokeToken(withAuthorizationCode: authorizationCode)
        completion(.success(()))
      } catch {
        completion(.failure(error))
      }
    }
  }

  public func canHandleOpenUrl(_ url: URL) -> Bool {
    return auth.canHandle(url)
  }

  public func canHandleRemoteNotification(_ notification: [AnyHashable: Any]) -> Bool {
    return auth.canHandleNotification(notification)
  }

  public func setAPNSToken(_ deviceToken: Data, type: FirebaseAuthAPNSTokenType) {
    auth.setAPNSToken(deviceToken, type: type.asFirebaseType)
  }
}

extension FirebaseAuthAPNSTokenType {
  var asFirebaseType: AuthAPNSTokenType {
    switch self {
    case .unknown: return .unknown
    case .sandbox: return .sandbox
    case .prod: return .prod
    }
  }
}
