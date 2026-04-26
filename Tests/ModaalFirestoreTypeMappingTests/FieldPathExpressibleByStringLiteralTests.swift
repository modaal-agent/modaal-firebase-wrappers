// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest
import FirebaseFirestore
@testable import ModaalFirestore

private typealias MFieldPath = ModaalFirestore.FieldPath

/// Verifies the v1.4.0 `ExpressibleByStringLiteral` conformance on `FieldPath`.
/// String literal sites such as `query.order(by: "createdAt", descending: true)`
/// must resolve to `.fields([literal])` and produce the same Firebase `FieldPath`
/// as the explicit `.field("createdAt")` form.
final class FieldPathExpressibleByStringLiteralTests: XCTestCase {

  func testStringLiteralResolvesToFieldsCase() {
    let path: MFieldPath = "createdAt"
    if case .fields(let names) = path {
      XCTAssertEqual(names, ["createdAt"])
    } else {
      XCTFail("String literal should resolve to .fields([literal])")
    }
  }

  func testStringLiteralProducesSameFirebaseFieldPathAsExplicitFactory() {
    let literalPath: MFieldPath = "createdAt"
    let factoryPath = MFieldPath.field("createdAt")

    let literalFirebase = literalPath.asFirestoreFieldPath
    let factoryFirebase = factoryPath.asFirestoreFieldPath

    XCTAssertEqual(literalFirebase, factoryFirebase)
  }

  func testStringLiteralCallSiteCompiles() {
    // Compile-time proof that string literals work in API positions
    // that take `FieldPath`. The explicit type ascription ensures the
    // literal is resolved through `ExpressibleByStringLiteral`, not as
    // a nominal `String` argument.
    func acceptsFieldPath(_ path: MFieldPath) -> MFieldPath { path }
    let result = acceptsFieldPath("status")
    if case .fields(let names) = result {
      XCTAssertEqual(names, ["status"])
    } else {
      XCTFail("Literal at call site should resolve to .fields([literal])")
    }
  }
}
