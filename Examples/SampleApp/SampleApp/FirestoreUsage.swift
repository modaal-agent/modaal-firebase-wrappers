// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation
import ModaalFirestore

// MARK: - FirestoreProtocol

/// Exercises every method on FirestoreProtocol.
/// This function is never called — it only needs to compile.
func exerciseFirestore(_ db: FirestoreProtocol) {
  let _: CollectionReferenceProtocol = db.collection("users")
  let _: QueryProtocol = db.collectionGroup("comments")
  let _: DocumentReferenceProtocol = db.document("users/alice")
  let _: WriteBatchProtocol = db.batch()

  // Transaction with actual reads and writes
  let docRef = db.document("counters/visits")
  db.runTransaction({ transaction in
    let snap = try transaction.getDocument(docRef)
    let currentCount = snap.get("count") as? Int ?? 0
    transaction.updateData(["count": currentCount + 1], forDocument: docRef)
    return currentCount + 1
  }) { result in
    switch result {
    case .success(let value): _ = value
    case .failure(let error): _ = error.localizedDescription
    }
  }
}

// MARK: - CollectionReferenceProtocol

/// Exercises CollectionReferenceProtocol properties and methods
/// (including inherited QueryProtocol methods).
func exerciseCollectionRef(_ ref: CollectionReferenceProtocol) {
  // Properties
  _ = ref.collectionID
  _ = ref.path
  _ = ref.parent

  // Document access
  let _: DocumentReferenceProtocol = ref.document()
  let _: DocumentReferenceProtocol = ref.document("alice")

  // Add document
  ref.addDocument(data: ["name": "Alice", "age": 30]) { result in
    switch result {
    case .success(let docRef): _ = docRef.documentID
    case .failure: break
    }
  }

  // Inherited QueryProtocol methods
  exerciseQuery(ref)
}

// MARK: - DocumentReferenceProtocol

/// Exercises every method/property on DocumentReferenceProtocol.
func exerciseDocumentRef(_ ref: DocumentReferenceProtocol) {
  // Properties
  _ = ref.documentID
  _ = ref.path
  let _: CollectionReferenceProtocol = ref.parent

  // Subcollection chain: doc → collection → doc → collection
  let posts = ref.collection("posts")
  let firstPost = posts.document("post1")
  let comments = firstPost.collection("comments")
  let _: DocumentReferenceProtocol = comments.document("comment1")

  // Read (default source)
  ref.getDocument { result in
    switch result {
    case .success(let snapshot): _ = snapshot.documentID
    case .failure: break
    }
  }

  // Read (explicit source)
  ref.getDocument(source: .cache) { result in
    switch result {
    case .success(let snapshot): _ = snapshot.metadata.isFromCache
    case .failure: break
    }
  }

  ref.getDocument(source: .server) { _ in }

  // Write — default mergeOption (overwrite)
  ref.setData(["name": "Alice"]) { _ in }

  // Write — explicit MergeOption variants
  ref.setData(["name": "Alice"], mergeOption: .overwrite) { _ in }
  ref.setData(["name": "Alice"], mergeOption: .merge) { _ in }
  ref.setData(["name": "Alice"], mergeOption: .mergeFields(["name"])) { _ in }

  // Update
  ref.updateData(["name": "Bob"]) { _ in }

  // Delete
  ref.delete { _ in }

  // Snapshot listener (default — no metadata changes)
  let listener = ref.addSnapshotListener { result in
    switch result {
    case .success(let snapshot):
      _ = snapshot.exists
      _ = snapshot.metadata.hasPendingWrites
      _ = snapshot.metadata.isFromCache
    case .failure: break
    }
  }
  listener.remove()

  // Snapshot listener (with metadata changes)
  let metaListener = ref.addSnapshotListener(includeMetadataChanges: true) { result in
    switch result {
    case .success(let snapshot): _ = snapshot.metadata.isFromCache
    case .failure: break
    }
  }
  metaListener.remove()
}

// MARK: - DocumentSnapshotProtocol

/// Exercises every property/method on DocumentSnapshotProtocol.
func exerciseDocumentSnapshot(_ snapshot: DocumentSnapshotProtocol) {
  _ = snapshot.documentID
  _ = snapshot.exists
  let _: DocumentReferenceProtocol = snapshot.reference
  _ = snapshot.data()
  _ = snapshot.get("name")

  // Metadata
  _ = snapshot.metadata.hasPendingWrites
  _ = snapshot.metadata.isFromCache
}

// MARK: - QueryProtocol

/// Exercises every method/property on QueryProtocol.
func exerciseQuery(_ query: QueryProtocol) {
  // Filtering
  let _: QueryProtocol = query.whereFilter(.equalTo(.field("name"), value: "Alice"))

  // Filter with FieldPath.documentId
  let _: QueryProtocol = query.whereFilter(.equalTo(.documentId, value: "abc123"))

  // Ordering
  let _: QueryProtocol = query.order(by: .field("createdAt"), descending: true)

  // Limiting
  let _: QueryProtocol = query.limit(to: 10)
  let _: QueryProtocol = query.limit(toLast: 5)

  // Chained query
  let _: QueryProtocol = query
    .whereFilter(.greaterThan(.field("age"), value: 18))
    .order(by: .field("age"), descending: false)
    .limit(to: 20)

  // Get documents (default source)
  query.getDocuments { result in
    switch result {
    case .success(let snapshot): _ = snapshot.documents
    case .failure: break
    }
  }

  // Get documents (explicit source)
  query.getDocuments(source: .cache) { _ in }
  query.getDocuments(source: .server) { _ in }

  // Snapshot listener (default — no metadata changes)
  let listener = query.addSnapshotListener { result in
    switch result {
    case .success(let snapshot):
      _ = snapshot.count
      // Incremental document changes
      for change in snapshot.documentChanges {
        switch change.type {
        case .added: _ = change.document.documentID
        case .modified: _ = change.oldIndex
        case .removed: _ = change.newIndex
        }
      }
      // Snapshot metadata
      _ = snapshot.metadata.hasPendingWrites
      _ = snapshot.metadata.isFromCache
    case .failure: break
    }
  }
  listener.remove()

  // Snapshot listener (with metadata changes)
  let metaListener = query.addSnapshotListener(includeMetadataChanges: true) { result in
    switch result {
    case .success(let snapshot): _ = snapshot.metadata.isFromCache
    case .failure: break
    }
  }
  metaListener.remove()

  // Aggregation
  let _: AggregateQueryProtocol = query.count
}

// MARK: - Pagination cursors

/// Exercises document-based and field-value-based pagination.
func exercisePagination(_ query: QueryProtocol, snapshot: DocumentSnapshotProtocol) {
  // Document-based cursors
  let _: QueryProtocol = query.start(atDocument: snapshot)
  let _: QueryProtocol = query.start(afterDocument: snapshot)
  let _: QueryProtocol = query.end(atDocument: snapshot)
  let _: QueryProtocol = query.end(beforeDocument: snapshot)

  // Field-value-based cursors
  let _: QueryProtocol = query.start(at: ["Alice", 30])
  let _: QueryProtocol = query.start(after: ["Alice", 30])
  let _: QueryProtocol = query.end(at: ["Zara", 99])
  let _: QueryProtocol = query.end(before: ["Zara", 99])

  // Paginated query pattern
  let _: QueryProtocol = query
    .order(by: .field("name"), descending: false)
    .limit(to: 25)
    .start(afterDocument: snapshot)
}

// MARK: - QuerySnapshotProtocol

/// Exercises every property on QuerySnapshotProtocol.
func exerciseQuerySnapshot(_ snapshot: QuerySnapshotProtocol) {
  let _: [DocumentSnapshotProtocol] = snapshot.documents
  let _: [DocumentChangeProtocol] = snapshot.documentChanges
  _ = snapshot.count
  _ = snapshot.isEmpty
  _ = snapshot.metadata.hasPendingWrites
  _ = snapshot.metadata.isFromCache
}

// MARK: - DocumentChangeProtocol

/// Exercises DocumentChangeProtocol.
func exerciseDocumentChange(_ change: DocumentChangeProtocol) {
  let _: DocumentChangeType = change.type
  let _: DocumentSnapshotProtocol = change.document
  _ = change.oldIndex
  _ = change.newIndex
}

// MARK: - SnapshotMetadataProtocol

/// Exercises SnapshotMetadataProtocol.
func exerciseSnapshotMetadata(_ metadata: SnapshotMetadataProtocol) {
  _ = metadata.hasPendingWrites
  _ = metadata.isFromCache
}

// MARK: - WriteBatchProtocol

/// Exercises every method on WriteBatchProtocol.
func exerciseWriteBatch(_ batch: WriteBatchProtocol, doc: DocumentReferenceProtocol) {
  // All MergeOption variants
  batch.setData(["name": "Alice"], forDocument: doc, mergeOption: .overwrite)
  batch.setData(["name": "Alice"], forDocument: doc, mergeOption: .merge)
  batch.setData(["name": "Alice"], forDocument: doc, mergeOption: .mergeFields(["name"]))

  batch.updateData(["name": "Bob"], forDocument: doc)
  batch.deleteDocument(doc)

  batch.commit { result in
    switch result {
    case .success: break
    case .failure(let error): _ = error.localizedDescription
    }
  }
}

// MARK: - TransactionProtocol

/// Exercises every method on TransactionProtocol.
func exerciseTransaction(_ transaction: TransactionProtocol, doc: DocumentReferenceProtocol) {
  _ = try? transaction.getDocument(doc)

  // All MergeOption variants
  transaction.setData(["name": "Alice"], forDocument: doc, mergeOption: .overwrite)
  transaction.setData(["name": "Alice"], forDocument: doc, mergeOption: .merge)
  transaction.setData(["name": "Alice"], forDocument: doc, mergeOption: .mergeFields(["name"]))

  transaction.updateData(["name": "Bob"], forDocument: doc)
  transaction.deleteDocument(doc)
}

// MARK: - ListenerRegistrationProtocol

/// Exercises ListenerRegistrationProtocol.
func exerciseListenerRegistration(_ registration: ListenerRegistrationProtocol) {
  registration.remove()
}

// MARK: - AggregateQueryProtocol

/// Exercises AggregateQueryProtocol.
func exerciseAggregateQuery(_ query: AggregateQueryProtocol) {
  query.getAggregation(source: .server) { result in
    switch result {
    case .success(let count): _ = count
    case .failure: break
    }
  }
}

// MARK: - Type exercises

/// Exercises Filter enum construction (all cases).
func exerciseFilters() {
  _ = Filter.equalTo(.field("name"), value: "Alice")
  _ = Filter.equalTo(.documentId, value: "abc123")
  _ = Filter.notEqualTo(.field("name"), value: "Bob")
  _ = Filter.greaterThan(.field("age"), value: 18)
  _ = Filter.greaterThanOrEqualTo(.field("age"), value: 18)
  _ = Filter.lessThan(.field("age"), value: 65)
  _ = Filter.lessThanOrEqualTo(.field("age"), value: 65)
  _ = Filter.arrayContains(.field("tags"), value: "admin")
  _ = Filter.arrayContainsAny(.field("tags"), values: ["admin", "mod"])
  _ = Filter.fieldIn(.field("status"), value: ["active", "pending"])
  _ = Filter.fieldNotIn(.field("status"), values: ["banned"])
  _ = Filter.any([
    .equalTo(.field("a"), value: 1),
    .equalTo(.field("b"), value: 2),
  ])
  _ = Filter.all([
    .greaterThan(.field("age"), value: 18),
    .lessThan(.field("age"), value: 65),
  ])
}

/// Exercises FieldPath enum construction (all cases).
func exerciseFieldPaths() {
  _ = FieldPath.documentId
  _ = FieldPath.field("name")
  _ = FieldPath.fields(["a", "b", "c"])
}

/// Exercises MergeOption enum construction (all cases).
func exerciseMergeOptions() {
  _ = MergeOption.overwrite
  _ = MergeOption.merge
  _ = MergeOption.mergeFields(["name", "email"])
}

/// Exercises FirestoreAggregateSource enum.
func exerciseAggregateSource() {
  _ = FirestoreAggregateSource.server
}

/// Exercises FirestoreSource enum (all cases).
func exerciseFirestoreSource() {
  _ = FirestoreSource.default
  _ = FirestoreSource.server
  _ = FirestoreSource.cache
}

/// Exercises DocumentChangeType enum (all cases).
func exerciseDocumentChangeType() {
  let types: [DocumentChangeType] = [.added, .modified, .removed]
  _ = types
}

// MARK: - Combine extensions

import Combine

/// Exercises Combine API on FirestoreProtocol.
func exerciseFirestoreCombine(_ db: FirestoreProtocol) {
  let _: Future<Any?, Error> = db.runTransaction { transaction in
    return nil
  }
}

/// Exercises Combine API on DocumentReferenceProtocol.
func exerciseDocumentRefCombine(_ ref: DocumentReferenceProtocol) {
  var cancellables = Set<AnyCancellable>()

  // One-shot
  let _: Future<DocumentSnapshotProtocol, Error> = ref.getDocument()
  let _: Future<DocumentSnapshotProtocol, Error> = ref.getDocument(source: .cache)
  let _: Future<Void, Error> = ref.setData(["name": "Alice"])
  let _: Future<Void, Error> = ref.setData(["name": "Alice"], mergeOption: .merge)
  let _: Future<Void, Error> = ref.updateData(["name": "Bob"])
  let _: Future<Void, Error> = ref.delete()

  // Streaming
  ref.snapshotPublisher()
    .sink(receiveCompletion: { _ in }, receiveValue: { snapshot in _ = snapshot.exists })
    .store(in: &cancellables)

  ref.snapshotPublisher(includeMetadataChanges: true)
    .sink(receiveCompletion: { _ in }, receiveValue: { snapshot in _ = snapshot.metadata.isFromCache })
    .store(in: &cancellables)
}

/// Exercises Combine API on QueryProtocol.
func exerciseQueryCombine(_ query: QueryProtocol) {
  var cancellables = Set<AnyCancellable>()

  // One-shot
  let _: Future<QuerySnapshotProtocol, Error> = query.getDocuments()
  let _: Future<QuerySnapshotProtocol, Error> = query.getDocuments(source: .server)

  // Streaming
  query.snapshotPublisher()
    .sink(receiveCompletion: { _ in }, receiveValue: { snapshot in _ = snapshot.count })
    .store(in: &cancellables)

  query.snapshotPublisher(includeMetadataChanges: true)
    .sink(receiveCompletion: { _ in }, receiveValue: { snapshot in _ = snapshot.metadata.isFromCache })
    .store(in: &cancellables)
}

/// Exercises Combine API on CollectionReferenceProtocol.
func exerciseCollectionRefCombine(_ ref: CollectionReferenceProtocol) {
  let _: Future<DocumentReferenceProtocol, Error> = ref.addDocument(data: ["name": "Alice"])
}

/// Exercises Combine API on WriteBatchProtocol.
func exerciseWriteBatchCombine(_ batch: WriteBatchProtocol) {
  let _: Future<Void, Error> = batch.commit()
}

/// Exercises Combine API on AggregateQueryProtocol.
func exerciseAggregateQueryCombine(_ query: AggregateQueryProtocol) {
  let _: Future<Int, Error> = query.getAggregation()
  let _: Future<Int, Error> = query.getAggregation(source: .server)
}

// MARK: - Wrapper instantiation

/// Exercises wrapper construction (proves the concrete type compiles).
func exerciseFirestoreWrapperInstantiation() {
  let _: FirestoreWrapper.Type = FirestoreWrapper.self
}
