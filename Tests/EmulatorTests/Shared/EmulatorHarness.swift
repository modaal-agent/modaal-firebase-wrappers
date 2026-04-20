// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.
//
// Shared by ModaalFirebaseSmokeTests and ModaalFirebaseIntegrationTests.
//
// Firebase itself is configured (once, on the main thread) inside
// EmulatorTestHostApp.init — see Tests/EmulatorTests/EmulatorTestHost/ — so
// the only Firebase-SDK imports here are the ones needed to build protocol-
// typed wrapper instances. Every test body should bind the returned values
// to their protocol types and operate only through the protocol surface.

import Foundation
import XCTest
import ModaalFirebaseAuth
import ModaalFirestore
import ModaalCloudStorage

public enum EmulatorHarness {
  public static let projectID = "demo-modaal"
  public static let storageBucket = "demo-modaal.appspot.com"

  public static var isEnabled: Bool {
    ProcessInfo.processInfo.environment["MODAAL_EMULATOR_HOST"] != nil
  }

  public static var host: String {
    ProcessInfo.processInfo.environment["MODAAL_EMULATOR_HOST"] ?? "localhost"
  }

  public static var firestorePort: Int { port("MODAAL_FIRESTORE_PORT", default: 8080) }
  public static var authPort: Int { port("MODAAL_AUTH_PORT", default: 9099) }
  public static var storagePort: Int { port("MODAAL_STORAGE_PORT", default: 9199) }

  private static func port(_ envVar: String, default defaultValue: Int) -> Int {
    if let raw = ProcessInfo.processInfo.environment[envVar], let int = Int(raw) {
      return int
    }
    return defaultValue
  }

  /// Skip the calling test when the emulator is not configured.
  public static func skipIfDisabled(file: StaticString = #filePath, line: UInt = #line) throws {
    guard isEnabled else {
      throw XCTSkip("MODAAL_EMULATOR_HOST not set — skipping emulator-backed test",
                    file: file, line: line)
    }
  }

  // MARK: - Configuration sentinel
  //
  // Firebase is configured by EmulatorTestHostApp.init. Kept as a no-op so
  // test setUp sites remain symmetric with earlier harness revisions.
  public static func configureFirebaseForEmulatorIfNeeded() {}

  // MARK: - Protocol-typed factories (the ONLY entry point for tests)

  public static func makeFirestore() -> FirestoreProtocol {
    FirestoreWrapper.makeDefault()
  }

  public static func makeAuth() -> FirebaseAuthProtocol {
    FirebaseAuthWrapper.makeDefault()
  }

  public static func makeStorage() -> CloudStorageProtocol {
    CloudStorageWrapper.makeDefault()
  }

  // MARK: - State reset (REST)

  /// Clears Firestore documents and Auth accounts. Storage state is not reset
  /// across tests — tests use unique paths per case.
  public static func resetEmulatorState() async throws {
    try await resetFirestore()
    try await resetAuth()
  }

  public static func resetFirestore() async throws {
    try await delete("http://\(host):\(firestorePort)/emulator/v1/projects/\(projectID)/databases/(default)/documents")
  }

  public static func resetAuth() async throws {
    try await delete("http://\(host):\(authPort)/emulator/v1/projects/\(projectID)/accounts")
  }

  private static func delete(_ urlString: String) async throws {
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    _ = try await URLSession.shared.data(for: request)
  }
}
