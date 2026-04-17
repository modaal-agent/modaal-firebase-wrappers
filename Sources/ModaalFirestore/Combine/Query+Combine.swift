// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public extension QueryProtocol {

  // MARK: - One-shot

  func getDocuments(source: FirestoreSource = .default) -> Future<QuerySnapshotProtocol, Error> {
    Future { promise in self.getDocuments(source: source) { promise($0) } }
  }

  // MARK: - Streaming

  func snapshotPublisher(includeMetadataChanges: Bool = false) -> AnyPublisher<QuerySnapshotProtocol, Error> {
    let subject = PassthroughSubject<QuerySnapshotProtocol, Error>()
    var registration: ListenerRegistrationProtocol?
    return subject
      .handleEvents(
        receiveSubscription: { _ in
          registration = self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { result in
            switch result {
            case .success(let snapshot): subject.send(snapshot)
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
