// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseMessaging

public final class FirebaseMessagingWrapper: FirebaseMessagingProtocol {
  let messaging: Messaging

  public init(messaging: Messaging) {
    self.messaging = messaging
  }

  // MARK: - FirebaseMessagingProtocol

  public var fcmToken: String? { messaging.fcmToken }

  public var apnsToken: Data? {
    get { messaging.apnsToken }
    set { messaging.apnsToken = newValue }
  }

  public var isAutoInitEnabled: Bool {
    get { messaging.isAutoInitEnabled }
    set { messaging.isAutoInitEnabled = newValue }
  }

  public func token(completion: @escaping (Result<String, Error>) -> Void) {
    messaging.token { token, error in
      if let token {
        completion(.success(token))
      } else {
        completion(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
  }

  public func deleteToken(completion: @escaping (Result<Void, Error>) -> Void) {
    messaging.deleteToken { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  public func subscribe(toTopic topic: String, completion: @escaping (Result<Void, Error>) -> Void) {
    messaging.subscribe(toTopic: topic) { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  public func unsubscribe(fromTopic topic: String, completion: @escaping (Result<Void, Error>) -> Void) {
    messaging.unsubscribe(fromTopic: topic) { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }
}
