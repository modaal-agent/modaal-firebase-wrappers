// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
@testable import ModaalFirestore

// MARK: - AggregateQueryProtocol
class AggregateQueryProtocolMock: AggregateQueryProtocol {

    // MARK: - Methods
    func getAggregation(source: FirestoreAggregateSource, completion: (Result<Int, Error>) -> Void) {
        getAggregationCallCount += 1
        if let __getAggregationHandler = self.getAggregationHandler {
            __getAggregationHandler(source, completion)
        }
    }
    var getAggregationCallCount: Int = 0
    var getAggregationHandler: ((_ source: FirestoreAggregateSource, _ completion: (Result<Int, Error>) -> Void) -> ())? = nil
}

// MARK: - CollectionReferenceProtocol
class CollectionReferenceProtocolMock: CollectionReferenceProtocol {

    // MARK: - Variables
    var collectionID: String = ""
    var count: AggregateQueryProtocol
    var parent: DocumentReferenceProtocol? = nil
    var path: String = ""

    // MARK: - Initializer
    init(count: AggregateQueryProtocol) {
        self.count = count
    }

    // MARK: - Methods
    func addDocument(data: [String: Any], completion: (Result<DocumentReferenceProtocol, Error>) -> Void) {
        addDocumentCallCount += 1
        if let __addDocumentHandler = self.addDocumentHandler {
            __addDocumentHandler(data, completion)
        }
    }
    var addDocumentCallCount: Int = 0
    var addDocumentHandler: ((_ data: [String: Any], _ completion: (Result<DocumentReferenceProtocol, Error>) -> Void) -> ())? = nil
    func addSnapshotListener(includeMetadataChanges: Bool, _ listener: (Result<QuerySnapshotProtocol, Error>) -> Void) -> ListenerRegistrationProtocol {
        addSnapshotListenerCallCount += 1
        if let __addSnapshotListenerHandler = self.addSnapshotListenerHandler {
            return __addSnapshotListenerHandler(includeMetadataChanges, listener)
        }
        fatalError("addSnapshotListenerHandler expected to be set.")
    }
    var addSnapshotListenerCallCount: Int = 0
    var addSnapshotListenerHandler: ((_ includeMetadataChanges: Bool, _ listener: (Result<QuerySnapshotProtocol, Error>) -> Void) -> (ListenerRegistrationProtocol))? = nil
    func document() -> DocumentReferenceProtocol {
        documentCallCount += 1
        if let __documentHandler = self.documentHandler {
            return __documentHandler()
        }
        fatalError("documentHandler expected to be set.")
    }
    var documentCallCount: Int = 0
    var documentHandler: (() -> (DocumentReferenceProtocol))? = nil
    func document(_ path: String) -> DocumentReferenceProtocol {
        documentPathCallCount += 1
        if let __documentPathHandler = self.documentPathHandler {
            return __documentPathHandler(path)
        }
        fatalError("documentPathHandler expected to be set.")
    }
    var documentPathCallCount: Int = 0
    var documentPathHandler: ((_ path: String) -> (DocumentReferenceProtocol))? = nil
    func end(atDocument document: DocumentSnapshotProtocol) -> QueryProtocol {
        endAtDocumentDocumentCallCount += 1
        if let __endAtDocumentDocumentHandler = self.endAtDocumentDocumentHandler {
            return __endAtDocumentDocumentHandler(document)
        }
        fatalError("endAtDocumentDocumentHandler expected to be set.")
    }
    var endAtDocumentDocumentCallCount: Int = 0
    var endAtDocumentDocumentHandler: ((_ document: DocumentSnapshotProtocol) -> (QueryProtocol))? = nil
    func end(at fieldValues: [Any]) -> QueryProtocol {
        endAtFieldValuesCallCount += 1
        if let __endAtFieldValuesHandler = self.endAtFieldValuesHandler {
            return __endAtFieldValuesHandler(fieldValues)
        }
        fatalError("endAtFieldValuesHandler expected to be set.")
    }
    var endAtFieldValuesCallCount: Int = 0
    var endAtFieldValuesHandler: ((_ fieldValues: [Any]) -> (QueryProtocol))? = nil
    func end(beforeDocument document: DocumentSnapshotProtocol) -> QueryProtocol {
        endBeforeDocumentDocumentCallCount += 1
        if let __endBeforeDocumentDocumentHandler = self.endBeforeDocumentDocumentHandler {
            return __endBeforeDocumentDocumentHandler(document)
        }
        fatalError("endBeforeDocumentDocumentHandler expected to be set.")
    }
    var endBeforeDocumentDocumentCallCount: Int = 0
    var endBeforeDocumentDocumentHandler: ((_ document: DocumentSnapshotProtocol) -> (QueryProtocol))? = nil
    func end(before fieldValues: [Any]) -> QueryProtocol {
        endBeforeFieldValuesCallCount += 1
        if let __endBeforeFieldValuesHandler = self.endBeforeFieldValuesHandler {
            return __endBeforeFieldValuesHandler(fieldValues)
        }
        fatalError("endBeforeFieldValuesHandler expected to be set.")
    }
    var endBeforeFieldValuesCallCount: Int = 0
    var endBeforeFieldValuesHandler: ((_ fieldValues: [Any]) -> (QueryProtocol))? = nil
    func getDocuments(completion: (Result<QuerySnapshotProtocol, Error>) -> Void) {
        getDocumentsCallCount += 1
        if let __getDocumentsHandler = self.getDocumentsHandler {
            __getDocumentsHandler(completion)
        }
    }
    var getDocumentsCallCount: Int = 0
    var getDocumentsHandler: ((_ completion: (Result<QuerySnapshotProtocol, Error>) -> Void) -> ())? = nil
    func getDocuments(source: FirestoreSource, completion: (Result<QuerySnapshotProtocol, Error>) -> Void) {
        getDocumentsSourceCompletionCallCount += 1
        if let __getDocumentsSourceCompletionHandler = self.getDocumentsSourceCompletionHandler {
            __getDocumentsSourceCompletionHandler(source, completion)
        }
    }
    var getDocumentsSourceCompletionCallCount: Int = 0
    var getDocumentsSourceCompletionHandler: ((_ source: FirestoreSource, _ completion: (Result<QuerySnapshotProtocol, Error>) -> Void) -> ())? = nil
    func limit(toLast value: Int) -> QueryProtocol {
        limitToLastValueCallCount += 1
        if let __limitToLastValueHandler = self.limitToLastValueHandler {
            return __limitToLastValueHandler(value)
        }
        fatalError("limitToLastValueHandler expected to be set.")
    }
    var limitToLastValueCallCount: Int = 0
    var limitToLastValueHandler: ((_ value: Int) -> (QueryProtocol))? = nil
    func limit(to value: Int) -> QueryProtocol {
        limitToValueCallCount += 1
        if let __limitToValueHandler = self.limitToValueHandler {
            return __limitToValueHandler(value)
        }
        fatalError("limitToValueHandler expected to be set.")
    }
    var limitToValueCallCount: Int = 0
    var limitToValueHandler: ((_ value: Int) -> (QueryProtocol))? = nil
    func order(by field: FieldPath, descending: Bool) -> QueryProtocol {
        orderCallCount += 1
        if let __orderHandler = self.orderHandler {
            return __orderHandler(field, descending)
        }
        fatalError("orderHandler expected to be set.")
    }
    var orderCallCount: Int = 0
    var orderHandler: ((_ field: FieldPath, _ descending: Bool) -> (QueryProtocol))? = nil
    func start(afterDocument document: DocumentSnapshotProtocol) -> QueryProtocol {
        startAfterDocumentDocumentCallCount += 1
        if let __startAfterDocumentDocumentHandler = self.startAfterDocumentDocumentHandler {
            return __startAfterDocumentDocumentHandler(document)
        }
        fatalError("startAfterDocumentDocumentHandler expected to be set.")
    }
    var startAfterDocumentDocumentCallCount: Int = 0
    var startAfterDocumentDocumentHandler: ((_ document: DocumentSnapshotProtocol) -> (QueryProtocol))? = nil
    func start(after fieldValues: [Any]) -> QueryProtocol {
        startAfterFieldValuesCallCount += 1
        if let __startAfterFieldValuesHandler = self.startAfterFieldValuesHandler {
            return __startAfterFieldValuesHandler(fieldValues)
        }
        fatalError("startAfterFieldValuesHandler expected to be set.")
    }
    var startAfterFieldValuesCallCount: Int = 0
    var startAfterFieldValuesHandler: ((_ fieldValues: [Any]) -> (QueryProtocol))? = nil
    func start(atDocument document: DocumentSnapshotProtocol) -> QueryProtocol {
        startAtDocumentDocumentCallCount += 1
        if let __startAtDocumentDocumentHandler = self.startAtDocumentDocumentHandler {
            return __startAtDocumentDocumentHandler(document)
        }
        fatalError("startAtDocumentDocumentHandler expected to be set.")
    }
    var startAtDocumentDocumentCallCount: Int = 0
    var startAtDocumentDocumentHandler: ((_ document: DocumentSnapshotProtocol) -> (QueryProtocol))? = nil
    func start(at fieldValues: [Any]) -> QueryProtocol {
        startAtFieldValuesCallCount += 1
        if let __startAtFieldValuesHandler = self.startAtFieldValuesHandler {
            return __startAtFieldValuesHandler(fieldValues)
        }
        fatalError("startAtFieldValuesHandler expected to be set.")
    }
    var startAtFieldValuesCallCount: Int = 0
    var startAtFieldValuesHandler: ((_ fieldValues: [Any]) -> (QueryProtocol))? = nil
    func whereFilter(_ filter: Filter) -> QueryProtocol {
        whereFilterCallCount += 1
        if let __whereFilterHandler = self.whereFilterHandler {
            return __whereFilterHandler(filter)
        }
        fatalError("whereFilterHandler expected to be set.")
    }
    var whereFilterCallCount: Int = 0
    var whereFilterHandler: ((_ filter: Filter) -> (QueryProtocol))? = nil
}

// MARK: - DocumentChangeProtocol
class DocumentChangeProtocolMock: DocumentChangeProtocol {

    // MARK: - Variables
    var document: DocumentSnapshotProtocol
    var newIndex: UInt = 0
    var oldIndex: UInt = 0
    var type: DocumentChangeType

    // MARK: - Initializer
    init(document: DocumentSnapshotProtocol, type: DocumentChangeType) {
        self.document = document
        self.type = type
    }
}

// MARK: - DocumentReferenceProtocol
class DocumentReferenceProtocolMock: DocumentReferenceProtocol {

    // MARK: - Variables
    var documentID: String = ""
    var parent: CollectionReferenceProtocol
    var path: String = ""

    // MARK: - Initializer
    init(parent: CollectionReferenceProtocol) {
        self.parent = parent
    }

    // MARK: - Methods
    func addSnapshotListener(includeMetadataChanges: Bool, _ listener: (Result<DocumentSnapshotProtocol, Error>) -> Void) -> ListenerRegistrationProtocol {
        addSnapshotListenerCallCount += 1
        if let __addSnapshotListenerHandler = self.addSnapshotListenerHandler {
            return __addSnapshotListenerHandler(includeMetadataChanges, listener)
        }
        fatalError("addSnapshotListenerHandler expected to be set.")
    }
    var addSnapshotListenerCallCount: Int = 0
    var addSnapshotListenerHandler: ((_ includeMetadataChanges: Bool, _ listener: (Result<DocumentSnapshotProtocol, Error>) -> Void) -> (ListenerRegistrationProtocol))? = nil
    func collection(_ path: String) -> CollectionReferenceProtocol {
        collectionCallCount += 1
        if let __collectionHandler = self.collectionHandler {
            return __collectionHandler(path)
        }
        fatalError("collectionHandler expected to be set.")
    }
    var collectionCallCount: Int = 0
    var collectionHandler: ((_ path: String) -> (CollectionReferenceProtocol))? = nil
    func delete(completion: (Result<Void, Error>) -> Void) {
        deleteCallCount += 1
        if let __deleteHandler = self.deleteHandler {
            __deleteHandler(completion)
        }
    }
    var deleteCallCount: Int = 0
    var deleteHandler: ((_ completion: (Result<Void, Error>) -> Void) -> ())? = nil
    func getDocument(completion: (Result<DocumentSnapshotProtocol, Error>) -> Void) {
        getDocumentCallCount += 1
        if let __getDocumentHandler = self.getDocumentHandler {
            __getDocumentHandler(completion)
        }
    }
    var getDocumentCallCount: Int = 0
    var getDocumentHandler: ((_ completion: (Result<DocumentSnapshotProtocol, Error>) -> Void) -> ())? = nil
    func getDocument(source: FirestoreSource, completion: (Result<DocumentSnapshotProtocol, Error>) -> Void) {
        getDocumentSourceCompletionCallCount += 1
        if let __getDocumentSourceCompletionHandler = self.getDocumentSourceCompletionHandler {
            __getDocumentSourceCompletionHandler(source, completion)
        }
    }
    var getDocumentSourceCompletionCallCount: Int = 0
    var getDocumentSourceCompletionHandler: ((_ source: FirestoreSource, _ completion: (Result<DocumentSnapshotProtocol, Error>) -> Void) -> ())? = nil
    func setData(_ data: [String: Any], mergeOption: MergeOption, completion: (Result<Void, Error>) -> Void) {
        setDataCallCount += 1
        if let __setDataHandler = self.setDataHandler {
            __setDataHandler(data, mergeOption, completion)
        }
    }
    var setDataCallCount: Int = 0
    var setDataHandler: ((_ data: [String: Any], _ mergeOption: MergeOption, _ completion: (Result<Void, Error>) -> Void) -> ())? = nil
    func updateData(_ fields: [String: Any], completion: (Result<Void, Error>) -> Void) {
        updateDataCallCount += 1
        if let __updateDataHandler = self.updateDataHandler {
            __updateDataHandler(fields, completion)
        }
    }
    var updateDataCallCount: Int = 0
    var updateDataHandler: ((_ fields: [String: Any], _ completion: (Result<Void, Error>) -> Void) -> ())? = nil
}

// MARK: - DocumentSnapshotProtocol
class DocumentSnapshotProtocolMock: DocumentSnapshotProtocol {

    // MARK: - Variables
    var documentID: String = ""
    var exists: Bool = false
    var metadata: SnapshotMetadataProtocol
    var reference: DocumentReferenceProtocol

    // MARK: - Initializer
    init(metadata: SnapshotMetadataProtocol, reference: DocumentReferenceProtocol) {
        self.metadata = metadata
        self.reference = reference
    }

    // MARK: - Methods
    func data() -> [String: Any]? {
        dataCallCount += 1
        if let __dataHandler = self.dataHandler {
            return __dataHandler()
        }
        return nil
    }
    var dataCallCount: Int = 0
    var dataHandler: (() -> ([String: Any]?))? = nil
    func get(_ field: String) -> Any? {
        getCallCount += 1
        if let __getHandler = self.getHandler {
            return __getHandler(field)
        }
        return nil
    }
    var getCallCount: Int = 0
    var getHandler: ((_ field: String) -> (Any?))? = nil
}

// MARK: - FirestoreProtocol
class FirestoreProtocolMock: FirestoreProtocol {

    // MARK: - Methods
    func batch() -> WriteBatchProtocol {
        batchCallCount += 1
        if let __batchHandler = self.batchHandler {
            return __batchHandler()
        }
        fatalError("batchHandler expected to be set.")
    }
    var batchCallCount: Int = 0
    var batchHandler: (() -> (WriteBatchProtocol))? = nil
    func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
        collectionCallCount += 1
        if let __collectionHandler = self.collectionHandler {
            return __collectionHandler(collectionPath)
        }
        fatalError("collectionHandler expected to be set.")
    }
    var collectionCallCount: Int = 0
    var collectionHandler: ((_ collectionPath: String) -> (CollectionReferenceProtocol))? = nil
    func collectionGroup(_ collectionID: String) -> QueryProtocol {
        collectionGroupCallCount += 1
        if let __collectionGroupHandler = self.collectionGroupHandler {
            return __collectionGroupHandler(collectionID)
        }
        fatalError("collectionGroupHandler expected to be set.")
    }
    var collectionGroupCallCount: Int = 0
    var collectionGroupHandler: ((_ collectionID: String) -> (QueryProtocol))? = nil
    func document(_ documentPath: String) -> DocumentReferenceProtocol {
        documentCallCount += 1
        if let __documentHandler = self.documentHandler {
            return __documentHandler(documentPath)
        }
        fatalError("documentHandler expected to be set.")
    }
    var documentCallCount: Int = 0
    var documentHandler: ((_ documentPath: String) -> (DocumentReferenceProtocol))? = nil
    func runTransaction(_ updateBlock: (TransactionProtocol) throws -> Any?, completion: (Result<Any?, Error>) -> Void) {
        runTransactionCallCount += 1
        if let __runTransactionHandler = self.runTransactionHandler {
            __runTransactionHandler(updateBlock, completion)
        }
    }
    var runTransactionCallCount: Int = 0
    var runTransactionHandler: ((_ updateBlock: (TransactionProtocol) throws -> Any?, _ completion: (Result<Any?, Error>) -> Void) -> ())? = nil
}

// MARK: - ListenerRegistrationProtocol
class ListenerRegistrationProtocolMock: ListenerRegistrationProtocol {

    // MARK: - Methods
    func remove() {
        removeCallCount += 1
        if let __removeHandler = self.removeHandler {
            __removeHandler()
        }
    }
    var removeCallCount: Int = 0
    var removeHandler: (() -> ())? = nil
}

// MARK: - QueryProtocol
class QueryProtocolMock: QueryProtocol {

    // MARK: - Variables
    var count: AggregateQueryProtocol

    // MARK: - Initializer
    init(count: AggregateQueryProtocol) {
        self.count = count
    }

    // MARK: - Methods
    func addSnapshotListener(includeMetadataChanges: Bool, _ listener: (Result<QuerySnapshotProtocol, Error>) -> Void) -> ListenerRegistrationProtocol {
        addSnapshotListenerCallCount += 1
        if let __addSnapshotListenerHandler = self.addSnapshotListenerHandler {
            return __addSnapshotListenerHandler(includeMetadataChanges, listener)
        }
        fatalError("addSnapshotListenerHandler expected to be set.")
    }
    var addSnapshotListenerCallCount: Int = 0
    var addSnapshotListenerHandler: ((_ includeMetadataChanges: Bool, _ listener: (Result<QuerySnapshotProtocol, Error>) -> Void) -> (ListenerRegistrationProtocol))? = nil
    func end(atDocument document: DocumentSnapshotProtocol) -> QueryProtocol {
        endAtDocumentDocumentCallCount += 1
        if let __endAtDocumentDocumentHandler = self.endAtDocumentDocumentHandler {
            return __endAtDocumentDocumentHandler(document)
        }
        fatalError("endAtDocumentDocumentHandler expected to be set.")
    }
    var endAtDocumentDocumentCallCount: Int = 0
    var endAtDocumentDocumentHandler: ((_ document: DocumentSnapshotProtocol) -> (QueryProtocol))? = nil
    func end(at fieldValues: [Any]) -> QueryProtocol {
        endAtFieldValuesCallCount += 1
        if let __endAtFieldValuesHandler = self.endAtFieldValuesHandler {
            return __endAtFieldValuesHandler(fieldValues)
        }
        fatalError("endAtFieldValuesHandler expected to be set.")
    }
    var endAtFieldValuesCallCount: Int = 0
    var endAtFieldValuesHandler: ((_ fieldValues: [Any]) -> (QueryProtocol))? = nil
    func end(beforeDocument document: DocumentSnapshotProtocol) -> QueryProtocol {
        endBeforeDocumentDocumentCallCount += 1
        if let __endBeforeDocumentDocumentHandler = self.endBeforeDocumentDocumentHandler {
            return __endBeforeDocumentDocumentHandler(document)
        }
        fatalError("endBeforeDocumentDocumentHandler expected to be set.")
    }
    var endBeforeDocumentDocumentCallCount: Int = 0
    var endBeforeDocumentDocumentHandler: ((_ document: DocumentSnapshotProtocol) -> (QueryProtocol))? = nil
    func end(before fieldValues: [Any]) -> QueryProtocol {
        endBeforeFieldValuesCallCount += 1
        if let __endBeforeFieldValuesHandler = self.endBeforeFieldValuesHandler {
            return __endBeforeFieldValuesHandler(fieldValues)
        }
        fatalError("endBeforeFieldValuesHandler expected to be set.")
    }
    var endBeforeFieldValuesCallCount: Int = 0
    var endBeforeFieldValuesHandler: ((_ fieldValues: [Any]) -> (QueryProtocol))? = nil
    func getDocuments(completion: (Result<QuerySnapshotProtocol, Error>) -> Void) {
        getDocumentsCallCount += 1
        if let __getDocumentsHandler = self.getDocumentsHandler {
            __getDocumentsHandler(completion)
        }
    }
    var getDocumentsCallCount: Int = 0
    var getDocumentsHandler: ((_ completion: (Result<QuerySnapshotProtocol, Error>) -> Void) -> ())? = nil
    func getDocuments(source: FirestoreSource, completion: (Result<QuerySnapshotProtocol, Error>) -> Void) {
        getDocumentsSourceCompletionCallCount += 1
        if let __getDocumentsSourceCompletionHandler = self.getDocumentsSourceCompletionHandler {
            __getDocumentsSourceCompletionHandler(source, completion)
        }
    }
    var getDocumentsSourceCompletionCallCount: Int = 0
    var getDocumentsSourceCompletionHandler: ((_ source: FirestoreSource, _ completion: (Result<QuerySnapshotProtocol, Error>) -> Void) -> ())? = nil
    func limit(toLast value: Int) -> QueryProtocol {
        limitToLastValueCallCount += 1
        if let __limitToLastValueHandler = self.limitToLastValueHandler {
            return __limitToLastValueHandler(value)
        }
        fatalError("limitToLastValueHandler expected to be set.")
    }
    var limitToLastValueCallCount: Int = 0
    var limitToLastValueHandler: ((_ value: Int) -> (QueryProtocol))? = nil
    func limit(to value: Int) -> QueryProtocol {
        limitToValueCallCount += 1
        if let __limitToValueHandler = self.limitToValueHandler {
            return __limitToValueHandler(value)
        }
        fatalError("limitToValueHandler expected to be set.")
    }
    var limitToValueCallCount: Int = 0
    var limitToValueHandler: ((_ value: Int) -> (QueryProtocol))? = nil
    func order(by field: FieldPath, descending: Bool) -> QueryProtocol {
        orderCallCount += 1
        if let __orderHandler = self.orderHandler {
            return __orderHandler(field, descending)
        }
        fatalError("orderHandler expected to be set.")
    }
    var orderCallCount: Int = 0
    var orderHandler: ((_ field: FieldPath, _ descending: Bool) -> (QueryProtocol))? = nil
    func start(afterDocument document: DocumentSnapshotProtocol) -> QueryProtocol {
        startAfterDocumentDocumentCallCount += 1
        if let __startAfterDocumentDocumentHandler = self.startAfterDocumentDocumentHandler {
            return __startAfterDocumentDocumentHandler(document)
        }
        fatalError("startAfterDocumentDocumentHandler expected to be set.")
    }
    var startAfterDocumentDocumentCallCount: Int = 0
    var startAfterDocumentDocumentHandler: ((_ document: DocumentSnapshotProtocol) -> (QueryProtocol))? = nil
    func start(after fieldValues: [Any]) -> QueryProtocol {
        startAfterFieldValuesCallCount += 1
        if let __startAfterFieldValuesHandler = self.startAfterFieldValuesHandler {
            return __startAfterFieldValuesHandler(fieldValues)
        }
        fatalError("startAfterFieldValuesHandler expected to be set.")
    }
    var startAfterFieldValuesCallCount: Int = 0
    var startAfterFieldValuesHandler: ((_ fieldValues: [Any]) -> (QueryProtocol))? = nil
    func start(atDocument document: DocumentSnapshotProtocol) -> QueryProtocol {
        startAtDocumentDocumentCallCount += 1
        if let __startAtDocumentDocumentHandler = self.startAtDocumentDocumentHandler {
            return __startAtDocumentDocumentHandler(document)
        }
        fatalError("startAtDocumentDocumentHandler expected to be set.")
    }
    var startAtDocumentDocumentCallCount: Int = 0
    var startAtDocumentDocumentHandler: ((_ document: DocumentSnapshotProtocol) -> (QueryProtocol))? = nil
    func start(at fieldValues: [Any]) -> QueryProtocol {
        startAtFieldValuesCallCount += 1
        if let __startAtFieldValuesHandler = self.startAtFieldValuesHandler {
            return __startAtFieldValuesHandler(fieldValues)
        }
        fatalError("startAtFieldValuesHandler expected to be set.")
    }
    var startAtFieldValuesCallCount: Int = 0
    var startAtFieldValuesHandler: ((_ fieldValues: [Any]) -> (QueryProtocol))? = nil
    func whereFilter(_ filter: Filter) -> QueryProtocol {
        whereFilterCallCount += 1
        if let __whereFilterHandler = self.whereFilterHandler {
            return __whereFilterHandler(filter)
        }
        fatalError("whereFilterHandler expected to be set.")
    }
    var whereFilterCallCount: Int = 0
    var whereFilterHandler: ((_ filter: Filter) -> (QueryProtocol))? = nil
}

// MARK: - QuerySnapshotProtocol
class QuerySnapshotProtocolMock: QuerySnapshotProtocol {

    // MARK: - Variables
    var count: Int = 0
    var documentChanges: [DocumentChangeProtocol] = []
    var documents: [DocumentSnapshotProtocol] = []
    var isEmpty: Bool = false
    var metadata: SnapshotMetadataProtocol

    // MARK: - Initializer
    init(metadata: SnapshotMetadataProtocol) {
        self.metadata = metadata
    }
}

// MARK: - SnapshotMetadataProtocol
class SnapshotMetadataProtocolMock: SnapshotMetadataProtocol {

    // MARK: - Variables
    var hasPendingWrites: Bool = false
    var isFromCache: Bool = false
}

// MARK: - TransactionProtocol
class TransactionProtocolMock: TransactionProtocol {

    // MARK: - Methods
    func deleteDocument(_ document: DocumentReferenceProtocol) {
        deleteDocumentCallCount += 1
        if let __deleteDocumentHandler = self.deleteDocumentHandler {
            __deleteDocumentHandler(document)
        }
    }
    var deleteDocumentCallCount: Int = 0
    var deleteDocumentHandler: ((_ document: DocumentReferenceProtocol) -> ())? = nil
    func getDocument(_ document: DocumentReferenceProtocol) throws -> DocumentSnapshotProtocol {
        getDocumentCallCount += 1
        if let __getDocumentHandler = self.getDocumentHandler {
            return try __getDocumentHandler(document)
        }
        fatalError("getDocumentHandler expected to be set.")
    }
    var getDocumentCallCount: Int = 0
    var getDocumentHandler: ((_ document: DocumentReferenceProtocol) throws -> (DocumentSnapshotProtocol))? = nil
    func setData(_ data: [String: Any], forDocument document: DocumentReferenceProtocol, mergeOption: MergeOption) {
        setDataCallCount += 1
        if let __setDataHandler = self.setDataHandler {
            __setDataHandler(data, document, mergeOption)
        }
    }
    var setDataCallCount: Int = 0
    var setDataHandler: ((_ data: [String: Any], _ document: DocumentReferenceProtocol, _ mergeOption: MergeOption) -> ())? = nil
    func updateData(_ fields: [String: Any], forDocument document: DocumentReferenceProtocol) {
        updateDataCallCount += 1
        if let __updateDataHandler = self.updateDataHandler {
            __updateDataHandler(fields, document)
        }
    }
    var updateDataCallCount: Int = 0
    var updateDataHandler: ((_ fields: [String: Any], _ document: DocumentReferenceProtocol) -> ())? = nil
}

// MARK: - WriteBatchProtocol
class WriteBatchProtocolMock: WriteBatchProtocol {

    // MARK: - Methods
    func commit(completion: (Result<Void, Error>) -> Void) {
        commitCallCount += 1
        if let __commitHandler = self.commitHandler {
            __commitHandler(completion)
        }
    }
    var commitCallCount: Int = 0
    var commitHandler: ((_ completion: (Result<Void, Error>) -> Void) -> ())? = nil
    func deleteDocument(_ document: DocumentReferenceProtocol) {
        deleteDocumentCallCount += 1
        if let __deleteDocumentHandler = self.deleteDocumentHandler {
            __deleteDocumentHandler(document)
        }
    }
    var deleteDocumentCallCount: Int = 0
    var deleteDocumentHandler: ((_ document: DocumentReferenceProtocol) -> ())? = nil
    func setData(_ data: [String: Any], forDocument document: DocumentReferenceProtocol, mergeOption: MergeOption) {
        setDataCallCount += 1
        if let __setDataHandler = self.setDataHandler {
            __setDataHandler(data, document, mergeOption)
        }
    }
    var setDataCallCount: Int = 0
    var setDataHandler: ((_ data: [String: Any], _ document: DocumentReferenceProtocol, _ mergeOption: MergeOption) -> ())? = nil
    func updateData(_ fields: [String: Any], forDocument document: DocumentReferenceProtocol) {
        updateDataCallCount += 1
        if let __updateDataHandler = self.updateDataHandler {
            __updateDataHandler(fields, document)
        }
    }
    var updateDataCallCount: Int = 0
    var updateDataHandler: ((_ fields: [String: Any], _ document: DocumentReferenceProtocol) -> ())? = nil
}
