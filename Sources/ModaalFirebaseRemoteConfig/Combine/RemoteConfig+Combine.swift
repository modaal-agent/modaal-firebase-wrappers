// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public extension FirebaseRemoteConfigProtocol {

  // MARK: - One-shot

  func fetch() -> Future<ModaalRemoteConfigFetchStatus, Error> {
    Future { promise in self.fetch { promise($0) } }
  }

  func fetchAndActivate() -> Future<ModaalRemoteConfigFetchAndActivateStatus, Error> {
    Future { promise in self.fetchAndActivate { promise($0) } }
  }

  func activate() -> Future<Bool, Error> {
    Future { promise in self.activate { promise($0) } }
  }

  // MARK: - Streaming

  func configUpdatePublisher() -> AnyPublisher<RemoteConfigUpdateProtocol, Error> {
    let subject = PassthroughSubject<RemoteConfigUpdateProtocol, Error>()
    var registration: RemoteConfigListenerRegistration?
    return subject
      .handleEvents(
        receiveSubscription: { _ in
          registration = self.addOnConfigUpdateListener { result in
            switch result {
            case .success(let update): subject.send(update)
            case .failure(let error): subject.send(completion: .failure(error))
            }
          }
        },
        receiveCancel: {
          registration?.remove()
        }
      )
      .eraseToAnyPublisher()
  }
}
