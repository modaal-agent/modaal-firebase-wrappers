// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
@testable import ModaalCloudStorage

// MARK: - CloudCollectionStoring
class CloudCollectionStoringMock: CloudCollectionStoring {

    // MARK: - Methods
    func listAll(completion: @escaping (Result<CloudStorageListResultProtocol, Error>) -> Void) {
        listAllCallCount += 1
        if let __listAllHandler = self.listAllHandler {
            __listAllHandler(completion)
        }
    }
    var listAllCallCount: Int = 0
    var listAllHandler: ((_ completion: @escaping (Result<CloudStorageListResultProtocol, Error>) -> Void) -> ())? = nil
}

// MARK: - CloudFileStoring
class CloudFileStoringMock: CloudFileStoring {

    // MARK: - Methods
    func delete(completion: @escaping (Result<Void, Error>) -> Void) {
        deleteCallCount += 1
        if let __deleteHandler = self.deleteHandler {
            __deleteHandler(completion)
        }
    }
    var deleteCallCount: Int = 0
    var deleteHandler: ((_ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
    func downloadToFile(localURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        downloadToFileCallCount += 1
        if let __downloadToFileHandler = self.downloadToFileHandler {
            __downloadToFileHandler(localURL, completion)
        }
    }
    var downloadToFileCallCount: Int = 0
    var downloadToFileHandler: ((_ localURL: URL, _ completion: @escaping (Result<URL, Error>) -> Void) -> ())? = nil
    func getData(maxSize: Int64, completion: @escaping (Result<Data, Error>) -> Void) {
        getDataCallCount += 1
        if let __getDataHandler = self.getDataHandler {
            __getDataHandler(maxSize, completion)
        }
    }
    var getDataCallCount: Int = 0
    var getDataHandler: ((_ maxSize: Int64, _ completion: @escaping (Result<Data, Error>) -> Void) -> ())? = nil
    func getDownloadURL(completion: @escaping (Result<URL, Error>) -> Void) {
        getDownloadURLCallCount += 1
        if let __getDownloadURLHandler = self.getDownloadURLHandler {
            __getDownloadURLHandler(completion)
        }
    }
    var getDownloadURLCallCount: Int = 0
    var getDownloadURLHandler: ((_ completion: @escaping (Result<URL, Error>) -> Void) -> ())? = nil
    func getMetadata(completion: @escaping (Result<CloudStorageMetadata, Error>) -> Void) {
        getMetadataCallCount += 1
        if let __getMetadataHandler = self.getMetadataHandler {
            __getMetadataHandler(completion)
        }
    }
    var getMetadataCallCount: Int = 0
    var getMetadataHandler: ((_ completion: @escaping (Result<CloudStorageMetadata, Error>) -> Void) -> ())? = nil
    func putData(_ data: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        putDataCallCount += 1
        if let __putDataHandler = self.putDataHandler {
            __putDataHandler(data, completion)
        }
    }
    var putDataCallCount: Int = 0
    var putDataHandler: ((_ data: Data, _ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
    func putData(_ data: Data, metadata: CloudStorageMetadata, completion: @escaping (Result<Void, Error>) -> Void) {
        putDataDataMetadataCompletionCallCount += 1
        if let __putDataDataMetadataCompletionHandler = self.putDataDataMetadataCompletionHandler {
            __putDataDataMetadataCompletionHandler(data, metadata, completion)
        }
    }
    var putDataDataMetadataCompletionCallCount: Int = 0
    var putDataDataMetadataCompletionHandler: ((_ data: Data, _ metadata: CloudStorageMetadata, _ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
    func updateMetadata(_ metadata: CloudStorageMetadata, completion: @escaping (Result<CloudStorageMetadata, Error>) -> Void) {
        updateMetadataCallCount += 1
        if let __updateMetadataHandler = self.updateMetadataHandler {
            __updateMetadataHandler(metadata, completion)
        }
    }
    var updateMetadataCallCount: Int = 0
    var updateMetadataHandler: ((_ metadata: CloudStorageMetadata, _ completion: @escaping (Result<CloudStorageMetadata, Error>) -> Void) -> ())? = nil
    func uploadFromFile(localURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        uploadFromFileCallCount += 1
        if let __uploadFromFileHandler = self.uploadFromFileHandler {
            __uploadFromFileHandler(localURL, completion)
        }
    }
    var uploadFromFileCallCount: Int = 0
    var uploadFromFileHandler: ((_ localURL: URL, _ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
    func uploadFromFile(localURL: URL, metadata: CloudStorageMetadata, completion: @escaping (Result<Void, Error>) -> Void) {
        uploadFromFileLocalURLMetadataCompletionCallCount += 1
        if let __uploadFromFileLocalURLMetadataCompletionHandler = self.uploadFromFileLocalURLMetadataCompletionHandler {
            __uploadFromFileLocalURLMetadataCompletionHandler(localURL, metadata, completion)
        }
    }
    var uploadFromFileLocalURLMetadataCompletionCallCount: Int = 0
    var uploadFromFileLocalURLMetadataCompletionHandler: ((_ localURL: URL, _ metadata: CloudStorageMetadata, _ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
}

// MARK: - CloudStorageListResultProtocol
class CloudStorageListResultProtocolMock: CloudStorageListResultProtocol {

    // MARK: - Methods
    func items() -> [CloudStorageReferencing] {
        itemsCallCount += 1
        if let __itemsHandler = self.itemsHandler {
            return __itemsHandler()
        }
        return []
    }
    var itemsCallCount: Int = 0
    var itemsHandler: (() -> ([CloudStorageReferencing]))? = nil
    func prefixes() -> [CloudStorageReferencing] {
        prefixesCallCount += 1
        if let __prefixesHandler = self.prefixesHandler {
            return __prefixesHandler()
        }
        return []
    }
    var prefixesCallCount: Int = 0
    var prefixesHandler: (() -> ([CloudStorageReferencing]))? = nil
}

// MARK: - CloudStorageProtocol
class CloudStorageProtocolMock: CloudStorageProtocol {

    // MARK: - Methods
    func reference() -> CloudStorageReferencing {
        referenceCallCount += 1
        if let __referenceHandler = self.referenceHandler {
            return __referenceHandler()
        }
        fatalError("referenceHandler expected to be set.")
    }
    var referenceCallCount: Int = 0
    var referenceHandler: (() -> (CloudStorageReferencing))? = nil
    func reference(forURL url: String) -> CloudStorageReferencing {
        referenceForURLUrlCallCount += 1
        if let __referenceForURLUrlHandler = self.referenceForURLUrlHandler {
            return __referenceForURLUrlHandler(url)
        }
        fatalError("referenceForURLUrlHandler expected to be set.")
    }
    var referenceForURLUrlCallCount: Int = 0
    var referenceForURLUrlHandler: ((_ url: String) -> (CloudStorageReferencing))? = nil
    func reference(withPath path: String) -> CloudStorageReferencing {
        referenceWithPathPathCallCount += 1
        if let __referenceWithPathPathHandler = self.referenceWithPathPathHandler {
            return __referenceWithPathPathHandler(path)
        }
        fatalError("referenceWithPathPathHandler expected to be set.")
    }
    var referenceWithPathPathCallCount: Int = 0
    var referenceWithPathPathHandler: ((_ path: String) -> (CloudStorageReferencing))? = nil
}

// MARK: - CloudStorageReferencing
class CloudStorageReferencingMock: CloudStorageReferencing {

    // MARK: - Variables
    var bucket: String = ""
    var fullPath: String = ""
    var name: String = ""

    // MARK: - Methods
    func child(path: String) -> CloudStorageReferencing {
        childCallCount += 1
        if let __childHandler = self.childHandler {
            return __childHandler(path)
        }
        fatalError("childHandler expected to be set.")
    }
    var childCallCount: Int = 0
    var childHandler: ((_ path: String) -> (CloudStorageReferencing))? = nil
    func delete(completion: @escaping (Result<Void, Error>) -> Void) {
        deleteCallCount += 1
        if let __deleteHandler = self.deleteHandler {
            __deleteHandler(completion)
        }
    }
    var deleteCallCount: Int = 0
    var deleteHandler: ((_ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
    func downloadToFile(localURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        downloadToFileCallCount += 1
        if let __downloadToFileHandler = self.downloadToFileHandler {
            __downloadToFileHandler(localURL, completion)
        }
    }
    var downloadToFileCallCount: Int = 0
    var downloadToFileHandler: ((_ localURL: URL, _ completion: @escaping (Result<URL, Error>) -> Void) -> ())? = nil
    func getData(maxSize: Int64, completion: @escaping (Result<Data, Error>) -> Void) {
        getDataCallCount += 1
        if let __getDataHandler = self.getDataHandler {
            __getDataHandler(maxSize, completion)
        }
    }
    var getDataCallCount: Int = 0
    var getDataHandler: ((_ maxSize: Int64, _ completion: @escaping (Result<Data, Error>) -> Void) -> ())? = nil
    func getDownloadURL(completion: @escaping (Result<URL, Error>) -> Void) {
        getDownloadURLCallCount += 1
        if let __getDownloadURLHandler = self.getDownloadURLHandler {
            __getDownloadURLHandler(completion)
        }
    }
    var getDownloadURLCallCount: Int = 0
    var getDownloadURLHandler: ((_ completion: @escaping (Result<URL, Error>) -> Void) -> ())? = nil
    func getMetadata(completion: @escaping (Result<CloudStorageMetadata, Error>) -> Void) {
        getMetadataCallCount += 1
        if let __getMetadataHandler = self.getMetadataHandler {
            __getMetadataHandler(completion)
        }
    }
    var getMetadataCallCount: Int = 0
    var getMetadataHandler: ((_ completion: @escaping (Result<CloudStorageMetadata, Error>) -> Void) -> ())? = nil
    func listAll(completion: @escaping (Result<CloudStorageListResultProtocol, Error>) -> Void) {
        listAllCallCount += 1
        if let __listAllHandler = self.listAllHandler {
            __listAllHandler(completion)
        }
    }
    var listAllCallCount: Int = 0
    var listAllHandler: ((_ completion: @escaping (Result<CloudStorageListResultProtocol, Error>) -> Void) -> ())? = nil
    func parent() -> CloudStorageReferencing? {
        parentCallCount += 1
        if let __parentHandler = self.parentHandler {
            return __parentHandler()
        }
        return nil
    }
    var parentCallCount: Int = 0
    var parentHandler: (() -> (CloudStorageReferencing?))? = nil
    func putData(_ data: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        putDataCallCount += 1
        if let __putDataHandler = self.putDataHandler {
            __putDataHandler(data, completion)
        }
    }
    var putDataCallCount: Int = 0
    var putDataHandler: ((_ data: Data, _ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
    func putData(_ data: Data, metadata: CloudStorageMetadata, completion: @escaping (Result<Void, Error>) -> Void) {
        putDataDataMetadataCompletionCallCount += 1
        if let __putDataDataMetadataCompletionHandler = self.putDataDataMetadataCompletionHandler {
            __putDataDataMetadataCompletionHandler(data, metadata, completion)
        }
    }
    var putDataDataMetadataCompletionCallCount: Int = 0
    var putDataDataMetadataCompletionHandler: ((_ data: Data, _ metadata: CloudStorageMetadata, _ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
    func root() -> CloudStorageReferencing {
        rootCallCount += 1
        if let __rootHandler = self.rootHandler {
            return __rootHandler()
        }
        fatalError("rootHandler expected to be set.")
    }
    var rootCallCount: Int = 0
    var rootHandler: (() -> (CloudStorageReferencing))? = nil
    func updateMetadata(_ metadata: CloudStorageMetadata, completion: @escaping (Result<CloudStorageMetadata, Error>) -> Void) {
        updateMetadataCallCount += 1
        if let __updateMetadataHandler = self.updateMetadataHandler {
            __updateMetadataHandler(metadata, completion)
        }
    }
    var updateMetadataCallCount: Int = 0
    var updateMetadataHandler: ((_ metadata: CloudStorageMetadata, _ completion: @escaping (Result<CloudStorageMetadata, Error>) -> Void) -> ())? = nil
    func uploadFromFile(localURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        uploadFromFileCallCount += 1
        if let __uploadFromFileHandler = self.uploadFromFileHandler {
            __uploadFromFileHandler(localURL, completion)
        }
    }
    var uploadFromFileCallCount: Int = 0
    var uploadFromFileHandler: ((_ localURL: URL, _ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
    func uploadFromFile(localURL: URL, metadata: CloudStorageMetadata, completion: @escaping (Result<Void, Error>) -> Void) {
        uploadFromFileLocalURLMetadataCompletionCallCount += 1
        if let __uploadFromFileLocalURLMetadataCompletionHandler = self.uploadFromFileLocalURLMetadataCompletionHandler {
            __uploadFromFileLocalURLMetadataCompletionHandler(localURL, metadata, completion)
        }
    }
    var uploadFromFileLocalURLMetadataCompletionCallCount: Int = 0
    var uploadFromFileLocalURLMetadataCompletionHandler: ((_ localURL: URL, _ metadata: CloudStorageMetadata, _ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
}

// MARK: - FileStoring
class FileStoringMock: FileStoring {

    // MARK: - Methods
    func file(path: String) -> FileStoring {
        fileCallCount += 1
        if let __fileHandler = self.fileHandler {
            return __fileHandler(path)
        }
        fatalError("fileHandler expected to be set.")
    }
    var fileCallCount: Int = 0
    var fileHandler: ((_ path: String) -> (FileStoring))? = nil
}
