// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

// MARK: - FieldPath -> FirebaseFirestore.FieldPath

extension FieldPath {
  var asFirestoreFieldPath: FirebaseFirestore.FieldPath {
    switch self {
    case .documentId: return .documentID()
    case .fields(let fields): return .init(fields)
    }
  }
}

// MARK: - Filter -> FirebaseFirestore.Filter

extension Filter {
  var asFirestoreFilter: FirebaseFirestore.Filter {
    switch self {
    case .equalTo(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, isEqualTo: value)
    case .notEqualTo(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, isNotEqualTo: value)
    case .greaterThan(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, isGreaterThan: value)
    case .greaterThanOrEqualTo(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, isGreaterOrEqualTo: value)
    case .lessThan(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, isLessThan: value)
    case .lessThanOrEqualTo(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, isLessThanOrEqualTo: value)
    case .arrayContains(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, arrayContains: value)
    case .arrayContainsAny(let fieldPath, let values):
      return .whereField(fieldPath.asFirestoreFieldPath, arrayContainsAny: values)
    case .fieldIn(let fieldPath, let values):
      return .whereField(fieldPath.asFirestoreFieldPath, in: values)
    case .fieldNotIn(let fieldPath, let values):
      return .whereField(fieldPath.asFirestoreFieldPath, notIn: values)
    case .any(let filters):
      return .orFilter(filters.map(\.asFirestoreFilter))
    case .all(let filters):
      return .andFilter(filters.map(\.asFirestoreFilter))
    }
  }
}

// MARK: - FirestoreAggregateSource -> FirebaseFirestore.AggregateSource

extension FirestoreAggregateSource {
  var asFirestoreType: FirebaseFirestore.AggregateSource {
    switch self {
    case .server: return .server
    }
  }
}

// MARK: - FirestoreSource -> FirebaseFirestore.FirestoreSource

extension FirestoreSource {
  var asFirestoreType: FirebaseFirestore.FirestoreSource {
    switch self {
    case .default: return .default
    case .server: return .server
    case .cache: return .cache
    }
  }
}
