// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import UIKit

public typealias FirebaseAuthStateDidChangeListenerHandle = NSObjectProtocol

public enum FirebaseAuthAPNSTokenType {
  case unknown
  case sandbox
  case prod
}

public protocol FirebaseAuthProtocol: AnyObject {
  var shareAuthStateAcrossDevices: Bool { get set }
  func useUserAccessGroup(_ userAccessGroup: String?) throws

  var currentUser: FirebaseUserProtocol? { get }
  func addStateDidChangeListener(_ listener: @escaping (FirebaseAuthProtocol, FirebaseUserProtocol?) -> Void) -> FirebaseAuthStateDidChangeListenerHandle
  func removeStateDidChangeListener(_ handle: FirebaseAuthStateDidChangeListenerHandle)

  func signInAnonymously(completion: @escaping (Result<FirebaseAuthDataResultProtocol, Error>) -> Void)
  func signIn(with credential: FirebaseAuthCredentialProtocol, completion: @escaping (Result<FirebaseAuthDataResultProtocol, Error>) -> Void)
  func signOut() throws

  func createUser(withEmail email: String, password: String, completion: @escaping (Result<FirebaseAuthDataResultProtocol, Error>) -> ())
  func sendPasswordReset(withEmail: String, completion: @escaping (Result<Void, Error>) -> ())

  func deleteUser(_ user: FirebaseUserProtocol, completion: @escaping (Result<Void, Error>) -> Void)

  func canHandleOpenUrl(_ url: URL) -> Bool
  func setAPNSToken(_ deviceToken: Data, type: FirebaseAuthAPNSTokenType)
  func canHandleRemoteNotification(_ notification: [AnyHashable: Any]) -> Bool
}

public protocol FirebaseUserInfoProtocol: AnyObject {
  var providerID: String { get }
  var uid: String { get }
  var displayName: String? { get }
  var photoURL: URL? { get }
  var email: String? { get }
  var phoneNumber: String? { get }
}

public protocol FirebaseUserProtocol: FirebaseUserInfoProtocol {
  var isAnonymous: Bool { get }
  var isEmailVerified: Bool { get }
  var refreshToken: String? { get }
  var metadata: FirebaseUserMetadataProtocol { get }
  var providerData: [FirebaseUserInfoProtocol] { get }

  func link(with credential: FirebaseAuthCredentialProtocol, completion: @escaping (Result<FirebaseAuthDataResultProtocol, Error>) -> Void)
  func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void)
  func updateUserProfile(displayName: String?, photoURL: URL?, completion: @escaping (Result<Void, Error>) -> ())
}

public protocol FirebaseAuthCredentialProtocol: AnyObject {
  var provider: String { get }
}

public protocol FirebaseAuthDataResultProtocol: AnyObject {
  var user: FirebaseUserProtocol { get }
  var credential: FirebaseAuthCredentialProtocol? { get }
}

public protocol FirebaseUserMetadataProtocol: AnyObject {
  var lastSignInDate: Date? { get }
  var creationDate: Date? { get }
}
