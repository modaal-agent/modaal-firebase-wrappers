// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation
import ModaalFirestore

// MARK: - FirestoreProtocol

/// Exercises every method on FirestoreProtocol.
/// This function is never called — it only needs to compile.
func exerciseFirestore(_ db: FirestoreProtocol) {
  let _: CollectionReferenceProtocol = db.collection("users")
  let _: DocumentReferenceProtocol = db.document("users/alice")
  let _: WriteBatchProtocol = db.batch()

  db.runTransaction({ transaction in
    // Transaction usage exercised in exerciseTransaction
    return nil
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

  // Subcollection
  let _: CollectionReferenceProtocol = ref.collection("posts")

  // Read
  ref.getDocument { result in
    switch result {
    case .success(let snapshot): _ = snapshot.documentID
    case .failure: break
    }
  }

  // Write — all MergeOption variants
  ref.setData(["name": "Alice"], mergeOption: .overwrite) { _ in }
  ref.setData(["name": "Alice"], mergeOption: .merge) { _ in }
  ref.setData(["name": "Alice"], mergeOption: .mergeFields(["name"])) { _ in }

  // Update
  ref.updateData(["name": "Bob"]) { _ in }

  // Delete
  ref.delete { _ in }

  // Snapshot listener
  let listener = ref.addSnapshotListener { result in
    switch result {
    case .success(let snapshot): _ = snapshot.exists
    case .failure: break
    }
  }
  listener.remove()
}

// MARK: - DocumentSnapshotProtocol

/// Exercises every property/method on DocumentSnapshotProtocol.
func exerciseDocumentSnapshot(_ snapshot: DocumentSnapshotProtocol) {
  _ = snapshot.documentID
  _ = snapshot.exists
  let _: DocumentReferenceProtocol = snapshot.reference
  _ = snapshot.data()
  _ = snapshot.get("name")
}

// MARK: - QueryProtocol

/// Exercises every method/property on QueryProtocol.
func exerciseQuery(_ query: QueryProtocol) {
  // Filtering
  let _: QueryProtocol = query.whereFilter(.equalTo(.field("name"), value: "Alice"))

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

  // Get documents
  query.getDocuments { result in
    switch result {
    case .success(let snapshot): _ = snapshot.documents
    case .failure: break
    }
  }

  // Snapshot listener
  let listener = query.addSnapshotListener { result in
    switch result {
    case .success(let snapshot): _ = snapshot.count
    case .failure: break
    }
  }
  listener.remove()

  // Aggregation
  let _: AggregateQueryProtocol = query.count
}

// MARK: - QuerySnapshotProtocol

/// Exercises every property on QuerySnapshotProtocol.
func exerciseQuerySnapshot(_ snapshot: QuerySnapshotProtocol) {
  let _: [DocumentSnapshotProtocol] = snapshot.documents
  _ = snapshot.count
  _ = snapshot.isEmpty
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

// MARK: - Wrapper instantiation

/// Exercises wrapper construction (proves the concrete type compiles).
func exerciseFirestoreWrapperInstantiation() {
  let _: FirestoreWrapper.Type = FirestoreWrapper.self
}
