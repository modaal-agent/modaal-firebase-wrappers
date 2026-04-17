// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseAuth

class FirebaseUserInfoWrapper: FirebaseUserInfoProtocol {
  let userInfo: FirebaseAuth.UserInfo

  init(userInfo: FirebaseAuth.UserInfo) {
    self.userInfo = userInfo
  }

  // MARK: - FirebaseUserInfoProtocol
  var providerID: String { userInfo.providerID }
  var uid: String { userInfo.uid }
  var displayName: String? { userInfo.displayName }
  var photoURL: URL? { userInfo.photoURL }
  var email: String? { userInfo.email }
  var phoneNumber: String? { userInfo.phoneNumber }
}

final class FirebaseUserWrapper: FirebaseUserInfoWrapper, FirebaseUserProtocol {
  let user: FirebaseAuth.User

  init(user: FirebaseAuth.User) {
    self.user = user
    super.init(userInfo: user)
  }

  // MARK: - FirebaseUserProtocol
  var isAnonymous: Bool { user.isAnonymous }
  var isEmailVerified: Bool { user.isEmailVerified }
  var refreshToken: String? { user.refreshToken }
  var metadata: FirebaseUserMetadataProtocol { user.metadata }
  var providerData: [FirebaseUserInfoProtocol] { user.providerData.map { FirebaseUserInfoWrapper(userInfo: $0) } }

  func link(with credential: FirebaseAuthCredentialProtocol, completion: @escaping (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) {
    user.link(with: credential as! AuthCredential) { result, error in
      if let result {
        completion(.success(FirebaseAuthDataResultWrapper(result: result)))
      } else {
        completion(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
  }

  func unlink(fromProvider provider: String, completion: @escaping (Result<FirebaseUserProtocol, Error>) -> Void) {
    user.unlink(fromProvider: provider) { user, error in
      if let user {
        completion(.success(FirebaseUserWrapper(user: user)))
      } else {
        completion(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
  }

  func reauthenticate(with credential: FirebaseAuthCredentialProtocol, completion: @escaping (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) {
    user.reauthenticate(with: credential as! AuthCredential) { result, error in
      if let result {
        completion(.success(FirebaseAuthDataResultWrapper(result: result)))
      } else {
        completion(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
  }

  func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void) {
    user.sendEmailVerification { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func updateUserProfile(displayName: String?, photoURL: URL?, completion: @escaping (Result<Void, Error>) -> ()) {
    let profileChangeRequest = user.createProfileChangeRequest()
    profileChangeRequest.displayName = displayName
    profileChangeRequest.photoURL = photoURL
    profileChangeRequest.commitChanges { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func updatePassword(to password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    user.updatePassword(to: password) { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func reload(completion: @escaping (Result<Void, Error>) -> Void) {
    user.reload { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func getIDToken(completion: @escaping (Result<String, Error>) -> Void) {
    user.getIDToken { token, error in
      if let token {
        completion(.success(token))
      } else {
        completion(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
  }

  func getIDTokenResult(completion: @escaping (Result<FirebaseAuthTokenResultProtocol, Error>) -> Void) {
    user.getIDTokenResult { result, error in
      if let result {
        completion(.success(FirebaseAuthTokenResultWrapper(result: result)))
      } else {
        completion(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
  }
}

extension FirebaseUserWrapper {
  static func from(user: User?) -> FirebaseUserWrapper? {
    guard let user else {
      return nil
    }
    return FirebaseUserWrapper(user: user)
  }
}
