// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation
import ModaalFirebaseAuth

// MARK: - FirebaseAuthProtocol

/// Exercises every method on FirebaseAuthProtocol.
/// This function is never called — it only needs to compile.
func exerciseAuth(_ auth: FirebaseAuthProtocol) {
  // Properties
  _ = auth.currentUser
  auth.shareAuthStateAcrossDevices = true
  try? auth.useUserAccessGroup("group.example")

  // State listener
  let handle = auth.addStateDidChangeListener { auth, user in
    _ = auth.currentUser
    _ = user?.uid
  }
  auth.removeStateDidChangeListener(handle)

  // Sign-in methods
  auth.signInAnonymously { result in
    switch result {
    case .success(let data): _ = data.user.uid
    case .failure(let err): _ = err.localizedDescription
    }
  }

  auth.signIn(withEmail: "a@b.com", password: "pw") { result in
    switch result {
    case .success(let data): _ = data.user.uid
    case .failure: break
    }
  }

  try? auth.signOut()

  // User management
  auth.createUser(withEmail: "a@b.com", password: "pw") { _ in }
  auth.sendPasswordReset(withEmail: "a@b.com") { _ in }
  if let user = auth.currentUser {
    auth.deleteUser(user) { _ in }
  }

  // Token revocation (Apple Sign-In requirement)
  auth.revokeToken(withAuthorizationCode: "auth_code") { _ in }

  // signIn(with:) — exercised via exerciseAuthCredential
  // canHandleOpenUrl, setAPNSToken, canHandleRemoteNotification
  _ = auth.canHandleOpenUrl(URL(string: "https://example.com")!)
  auth.setAPNSToken(Data(), type: .sandbox)
  auth.setAPNSToken(Data(), type: .prod)
  auth.setAPNSToken(Data(), type: .unknown)
  _ = auth.canHandleRemoteNotification([:])
}

// MARK: - FirebaseUserProtocol (inherits FirebaseUserInfoProtocol)

/// Exercises every method/property on FirebaseUserProtocol and FirebaseUserInfoProtocol.
func exerciseUser(_ user: FirebaseUserProtocol) {
  // FirebaseUserInfoProtocol properties
  _ = user.providerID
  _ = user.uid
  _ = user.displayName
  _ = user.photoURL
  _ = user.email
  _ = user.phoneNumber

  // FirebaseUserProtocol properties
  _ = user.isAnonymous
  _ = user.isEmailVerified
  _ = user.refreshToken
  _ = user.providerData.map { $0.providerID }

  // Metadata
  exerciseUserMetadata(user.metadata)

  // Profile updates
  user.sendEmailVerification { _ in }
  user.updateUserProfile(displayName: "Name", photoURL: nil) { _ in }
  user.updateUserProfile(displayName: nil, photoURL: URL(string: "https://example.com/photo.jpg")) { _ in }
  user.updatePassword(to: "newPassword123") { _ in }
  user.reload { _ in }

  // ID tokens (for backend API authentication)
  user.getIDToken { result in
    switch result {
    case .success(let token): _ = token
    case .failure: break
    }
  }

  user.getIDTokenResult { result in
    switch result {
    case .success(let tokenResult):
      _ = tokenResult.token
      _ = tokenResult.expirationDate
      _ = tokenResult.authDate
      _ = tokenResult.issuedAtDate
      _ = tokenResult.signInProvider
      _ = tokenResult.claims
    case .failure: break
    }
  }
}

/// Exercises signIn(with:), link(with:), unlink, and reauthenticate which require a credential.
func exerciseAuthCredential(_ credential: FirebaseAuthCredentialProtocol,
                            auth: FirebaseAuthProtocol,
                            user: FirebaseUserProtocol) {
  _ = credential.provider

  auth.signIn(with: credential) { result in
    switch result {
    case .success(let data):
      _ = data.user
      _ = data.credential
    case .failure: break
    }
  }

  user.link(with: credential) { _ in }

  user.unlink(fromProvider: "google.com") { result in
    switch result {
    case .success(let updatedUser): _ = updatedUser.uid
    case .failure: break
    }
  }

  user.reauthenticate(with: credential) { result in
    switch result {
    case .success(let data): _ = data.user
    case .failure: break
    }
  }
}

// MARK: - FirebaseAuthDataResultProtocol

/// Exercises FirebaseAuthDataResultProtocol properties.
func exerciseAuthDataResult(_ result: FirebaseAuthDataResultProtocol) {
  let _: FirebaseUserProtocol = result.user
  let _: FirebaseAuthCredentialProtocol? = result.credential
}

// MARK: - FirebaseAuthTokenResultProtocol

/// Exercises FirebaseAuthTokenResultProtocol properties.
func exerciseAuthTokenResult(_ result: FirebaseAuthTokenResultProtocol) {
  _ = result.token
  _ = result.expirationDate
  _ = result.authDate
  _ = result.issuedAtDate
  _ = result.signInProvider
  _ = result.claims
}

// MARK: - FirebaseUserMetadataProtocol

/// Exercises FirebaseUserMetadataProtocol properties.
func exerciseUserMetadata(_ metadata: FirebaseUserMetadataProtocol) {
  _ = metadata.lastSignInDate
  _ = metadata.creationDate
}

// MARK: - Wrapper instantiation

/// Exercises wrapper construction (proves the concrete type compiles).
func exerciseAuthWrapperInstantiation() {
  // FirebaseAuthWrapper requires Auth.auth() which needs FirebaseApp.configure() —
  // can't call at compile-check time, but the type reference compiles.
  let _: FirebaseAuthWrapper.Type = FirebaseAuthWrapper.self
}
