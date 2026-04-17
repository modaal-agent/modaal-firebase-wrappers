// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol FirebaseMessagingProtocol: AnyObject {
  var fcmToken: String? { get }
  var apnsToken: Data? { get set }
  var isAutoInitEnabled: Bool { get set }

  func token(completion: @escaping (Result<String, Error>) -> Void)
  func deleteToken(completion: @escaping (Result<Void, Error>) -> Void)

  func subscribe(toTopic topic: String, completion: @escaping (Result<Void, Error>) -> Void)
  func unsubscribe(fromTopic topic: String, completion: @escaping (Result<Void, Error>) -> Void)
}
