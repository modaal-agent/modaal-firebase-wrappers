// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest
import FirebaseFirestore
@testable import ModaalFirestore

// Disambiguate types that exist in both ModaalFirestore and FirebaseFirestore.
private typealias MFieldPath = ModaalFirestore.FieldPath
private typealias MFilter = ModaalFirestore.Filter
private typealias MFirestoreSource = ModaalFirestore.FirestoreSource
private typealias MFirestoreAggregateSource = ModaalFirestore.FirestoreAggregateSource

/// Tests that mirrored Modaal types correctly convert to Firebase SDK equivalents.
/// These conversions are internal to ModaalFirestore (used by wrapper implementations).
/// A wrong mapping silently produces incorrect query behavior at runtime.
final class FirestoreTypeMappingTests: XCTestCase {

  // MARK: - FieldPath

  func testFieldPathDocumentId() {
    let modaalPath = MFieldPath.documentId
    let firebasePath = modaalPath.asFirestoreFieldPath
    // FieldPath.documentID() is a well-known sentinel; verify it converts without crashing.
    XCTAssertNotNil(firebasePath)
  }

  func testFieldPathSingleField() {
    let modaalPath = MFieldPath.field("name")
    let firebasePath = modaalPath.asFirestoreFieldPath
    XCTAssertNotNil(firebasePath)
  }

  func testFieldPathMultipleFields() {
    let modaalPath = MFieldPath.fields(["address", "city"])
    let firebasePath = modaalPath.asFirestoreFieldPath
    XCTAssertNotNil(firebasePath)
  }

  // MARK: - FirestoreSource

  func testFirestoreSourceDefault() {
    XCTAssertEqual(MFirestoreSource.default.asFirestoreType, .default)
  }

  func testFirestoreSourceServer() {
    XCTAssertEqual(MFirestoreSource.server.asFirestoreType, .server)
  }

  func testFirestoreSourceCache() {
    XCTAssertEqual(MFirestoreSource.cache.asFirestoreType, .cache)
  }

  func testFirestoreSourceExhaustive() {
    // Verify every Modaal case maps to a distinct Firebase case
    let sources: [MFirestoreSource] = [.default, .server, .cache]
    let mapped = Set(sources.map { "\($0.asFirestoreType)" })
    XCTAssertEqual(mapped.count, sources.count, "Each source should map to a distinct Firebase value")
  }

  // MARK: - FirestoreAggregateSource

  func testFirestoreAggregateSourceServer() {
    XCTAssertEqual(MFirestoreAggregateSource.server.asFirestoreType, .server)
  }

  // MARK: - Filter (verify construction, not equality)
  // FirebaseFirestore.Filter is not Equatable, so we verify each case
  // constructs without crashing and produces a non-nil result.

  func testFilterEqualTo() {
    let filter = MFilter.equalTo(.field("age"), value: 25)
    let result = filter.asFirestoreFilter
    XCTAssertNotNil(result)
  }

  func testFilterNotEqualTo() {
    let filter = MFilter.notEqualTo(.field("status"), value: "deleted")
    XCTAssertNotNil(filter.asFirestoreFilter)
  }

  func testFilterGreaterThan() {
    let filter = MFilter.greaterThan(.field("score"), value: 100)
    XCTAssertNotNil(filter.asFirestoreFilter)
  }

  func testFilterGreaterThanOrEqualTo() {
    let filter = MFilter.greaterThanOrEqualTo(.field("score"), value: 100)
    XCTAssertNotNil(filter.asFirestoreFilter)
  }

  func testFilterLessThan() {
    let filter = MFilter.lessThan(.field("price"), value: 50.0)
    XCTAssertNotNil(filter.asFirestoreFilter)
  }

  func testFilterLessThanOrEqualTo() {
    let filter = MFilter.lessThanOrEqualTo(.field("price"), value: 50.0)
    XCTAssertNotNil(filter.asFirestoreFilter)
  }

  func testFilterArrayContains() {
    let filter = MFilter.arrayContains(.field("tags"), value: "swift")
    XCTAssertNotNil(filter.asFirestoreFilter)
  }

  func testFilterArrayContainsAny() {
    let filter = MFilter.arrayContainsAny(.field("tags"), values: ["swift", "ios"])
    XCTAssertNotNil(filter.asFirestoreFilter)
  }

  func testFilterFieldIn() {
    let filter = MFilter.fieldIn(.field("status"), value: ["active", "pending"])
    XCTAssertNotNil(filter.asFirestoreFilter)
  }

  func testFilterFieldNotIn() {
    let filter = MFilter.fieldNotIn(.field("status"), values: ["deleted", "archived"])
    XCTAssertNotNil(filter.asFirestoreFilter)
  }

  func testFilterCompositeAny() {
    let filter = MFilter.any([
      .equalTo(.field("city"), value: "NYC"),
      .equalTo(.field("city"), value: "LA"),
    ])
    XCTAssertNotNil(filter.asFirestoreFilter)
  }

  func testFilterCompositeAll() {
    let filter = MFilter.all([
      .greaterThan(.field("age"), value: 18),
      .equalTo(.field("active"), value: true),
    ])
    XCTAssertNotNil(filter.asFirestoreFilter)
  }

  func testFilterNestedComposite() {
    let filter = MFilter.any([
      .all([
        .equalTo(.field("city"), value: "NYC"),
        .greaterThan(.field("age"), value: 21),
      ]),
      .all([
        .equalTo(.field("city"), value: "LA"),
        .greaterThan(.field("age"), value: 18),
      ]),
    ])
    XCTAssertNotNil(filter.asFirestoreFilter)
  }

  func testFilterWithDocumentId() {
    let filter = MFilter.equalTo(.documentId, value: "doc-123")
    XCTAssertNotNil(filter.asFirestoreFilter)
  }
}
