// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import FirebaseStorage
import Foundation

public final class CloudStorageReference: CloudStorageReferencing {

  private let reference: StorageReference

  init(reference: StorageReference) {
    self.reference = reference
  }

  // MARK: - CloudStorageReferencing

  public var fullPath: String { reference.fullPath }
  public var name: String { reference.name }
  public var bucket: String { reference.bucket }

  public func child(path: String) -> CloudStorageReferencing {
    CloudStorageReference(reference: reference.child(path))
  }

  public func parent() -> CloudStorageReferencing? {
    guard let parent = reference.parent() else {
      return nil
    }
    return CloudStorageReference(reference: parent)
  }

  public func root() -> CloudStorageReferencing {
    CloudStorageReference(reference: reference.root())
  }

  // MARK: - CloudCollectionStoring

  public func listAll() -> AnyPublisher<CloudStorageListResultProtocol, Error> {
    Future { promise in
      self.reference.listAll { result in
        promise(result.map { CloudStorageListResult(result: $0) })
      }
    }
    .eraseToAnyPublisher()
  }

  // MARK: - CloudFileStoring

  public func getData(maxSize: Int64) -> AnyPublisher<Data, Error> {
    var task: StorageDownloadTask?

    return Deferred {
      Future { promise in
        task = self.reference.getData(maxSize: maxSize) { result in
          promise(result)
        }
      }
    }
    .handleEvents(receiveCancel: {
      task?.cancel()
    })
    .eraseToAnyPublisher()
  }

  public func downloadToFile(localURL: URL) -> AnyPublisher<URL, Error> {
    var task: StorageDownloadTask?

    return Deferred {
      Future { promise in
        task = self.reference.write(toFile: localURL) { result in
          promise(result)
        }
      }
    }
    .handleEvents(receiveCancel: {
      task?.cancel()
    })
    .eraseToAnyPublisher()
  }

  public func getDownloadURL() -> AnyPublisher<URL, Error> {
    Future { promise in
      self.reference.downloadURL { result in
        promise(result)
      }
    }
    .eraseToAnyPublisher()
  }

  public func putData(_ data: Data) -> AnyPublisher<Void, Error> {
    var task: StorageUploadTask?

    return Deferred {
      Future { promise in
        task = self.reference.putData(data) { result in
          promise(result.map { _ in () })
        }
      }
    }
    .handleEvents(receiveCancel: {
      task?.cancel()
    })
    .eraseToAnyPublisher()
  }

  public func uploadFromFile(localURL: URL) -> AnyPublisher<Void, Error> {
    var task: StorageUploadTask?

    return Deferred {
      Future { promise in
        task = self.reference.putFile(from: localURL) { result in
          promise(result.map { _ in () })
        }
      }
    }
    .handleEvents(receiveCancel: {
      task?.cancel()
    })
    .eraseToAnyPublisher()
  }

  public func delete() -> AnyPublisher<Void, Error> {
    Future { promise in
      self.reference.delete { error in
        if let error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
