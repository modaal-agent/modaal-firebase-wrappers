// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest
import ModaalFirestore

/// Verifies that the public typealiases in `Types/RawTypeReExports.swift` make
/// `Timestamp` and `FieldValue` resolvable under `import ModaalFirestore`
/// alone, without `import FirebaseFirestore` at the call site.
///
/// The tests assert behavior at the type-resolution level (the typealiases
/// resolve to the expected Firebase SDK types and produce usable values).
/// They do not exercise Firestore writes — those live in
/// `Tests/EmulatorTests/`.
///
/// Notably uses `import ModaalFirestore` *without* `@testable` and *without*
/// `import FirebaseFirestore` — if either becomes necessary, the typealiases
/// have stopped serving their purpose.
final class RawTypeReExportsTests: XCTestCase {

  func testTimestampTypealiasResolvesAndConstructs() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let timestamp = Timestamp(date: now)
    XCTAssertEqual(timestamp.dateValue(), now)
    XCTAssertEqual(timestamp.seconds, 1_700_000_000)
    XCTAssertEqual(timestamp.nanoseconds, 0)
  }

  func testFieldValueTypealiasResolvesAndConstructsServerTimestamp() {
    // FieldValue.serverTimestamp() returns a sentinel object — assert that
    // the type resolves and a value is produced. The sentinel's identity is
    // opaque (Firebase intentionally does not expose its internals).
    let sentinel = FieldValue.serverTimestamp()
    XCTAssertNotNil(sentinel)
  }

  func testFieldValueArrayUnionAndIncrementResolveAndConstruct() {
    let union = FieldValue.arrayUnion(["alpha", "beta"])
    XCTAssertNotNil(union)

    let remove = FieldValue.arrayRemove(["beta"])
    XCTAssertNotNil(remove)

    let inc = FieldValue.increment(Int64(5))
    XCTAssertNotNil(inc)

    let delete = FieldValue.delete()
    XCTAssertNotNil(delete)
  }

  func testTimestampAndFieldValueComposeIntoWritePayloadDictionary() {
    // The motivating use case — a write payload built without `import
    // FirebaseFirestore` at the call site.
    let payload: [String: Any] = [
      "createdAt": Timestamp(date: .init()),
      "updatedAt": FieldValue.serverTimestamp(),
      "tags": FieldValue.arrayUnion(["new"]),
      "viewCount": FieldValue.increment(Int64(1)),
      "softDeleted": FieldValue.delete(),
    ]
    XCTAssertEqual(payload.count, 5)
    XCTAssertNotNil(payload["createdAt"] as? Timestamp)
  }
}
