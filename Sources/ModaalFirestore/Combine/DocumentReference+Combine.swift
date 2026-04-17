// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public extension DocumentReferenceProtocol {

  // MARK: - One-shot

  func getDocument(source: FirestoreSource = .default) -> Future<DocumentSnapshotProtocol, Error> {
    Future { promise in self.getDocument(source: source) { promise($0) } }
  }

  func setData(_ data: [String: Any], mergeOption: MergeOption = .overwrite) -> Future<Void, Error> {
    Future { promise in self.setData(data, mergeOption: mergeOption) { promise($0) } }
  }

  func updateData(_ fields: [String: Any]) -> Future<Void, Error> {
    Future { promise in self.updateData(fields) { promise($0) } }
  }

  func delete() -> Future<Void, Error> {
    Future { promise in self.delete { promise($0) } }
  }

  // MARK: - Streaming

  func snapshotPublisher(includeMetadataChanges: Bool = false) -> AnyPublisher<DocumentSnapshotProtocol, Error> {
    let subject = PassthroughSubject<DocumentSnapshotProtocol, Error>()
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
