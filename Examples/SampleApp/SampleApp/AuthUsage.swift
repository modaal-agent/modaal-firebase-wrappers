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
  try? auth.signOut()

  // User management
  auth.createUser(withEmail: "a@b.com", password: "pw") { _ in }
  auth.sendPasswordReset(withEmail: "a@b.com") { _ in }
  if let user = auth.currentUser {
    auth.deleteUser(user) { _ in }
  }

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

  // Methods
  user.sendEmailVerification { _ in }
  user.updateUserProfile(displayName: "Name", photoURL: nil) { _ in }
  user.updateUserProfile(displayName: nil, photoURL: URL(string: "https://example.com/photo.jpg")) { _ in }
}

/// Exercises signIn(with:) and link(with:) which require a credential.
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
}

// MARK: - FirebaseAuthDataResultProtocol

/// Exercises FirebaseAuthDataResultProtocol properties.
func exerciseAuthDataResult(_ result: FirebaseAuthDataResultProtocol) {
  let _: FirebaseUserProtocol = result.user
  let _: FirebaseAuthCredentialProtocol? = result.credential
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
