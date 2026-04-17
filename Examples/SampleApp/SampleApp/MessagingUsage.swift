// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation
import ModaalFirebaseMessaging

// MARK: - FirebaseMessagingProtocol

/// Exercises every method/property on FirebaseMessagingProtocol.
/// This function is never called — it only needs to compile.
func exerciseMessaging(_ messaging: FirebaseMessagingProtocol) {
  // Read-only property
  _ = messaging.fcmToken

  // Read-write properties
  _ = messaging.apnsToken
  messaging.apnsToken = Data()
  messaging.apnsToken = nil

  _ = messaging.isAutoInitEnabled
  messaging.isAutoInitEnabled = true
  messaging.isAutoInitEnabled = false

  // Token management
  messaging.token { result in
    switch result {
    case .success(let token): _ = token
    case .failure(let error): _ = error.localizedDescription
    }
  }

  messaging.deleteToken { result in
    switch result {
    case .success: break
    case .failure: break
    }
  }

  // Topic subscription
  messaging.subscribe(toTopic: "news") { result in
    switch result {
    case .success: break
    case .failure: break
    }
  }

  messaging.unsubscribe(fromTopic: "news") { result in
    switch result {
    case .success: break
    case .failure: break
    }
  }
}

// MARK: - Combine extensions

import Combine

/// Exercises Combine API on FirebaseMessagingProtocol.
func exerciseMessagingCombine(_ messaging: FirebaseMessagingProtocol) {
  let _: Future<String, Error> = messaging.token()
  let _: Future<Void, Error> = messaging.deleteToken()
  let _: Future<Void, Error> = messaging.subscribe(toTopic: "news")
  let _: Future<Void, Error> = messaging.unsubscribe(fromTopic: "news")
}

// MARK: - Wrapper instantiation

/// Exercises wrapper construction (proves the concrete type compiles).
func exerciseMessagingWrapperInstantiation() {
  let _: FirebaseMessagingWrapper.Type = FirebaseMessagingWrapper.self
}
