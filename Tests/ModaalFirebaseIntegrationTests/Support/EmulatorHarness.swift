// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.
//
// This file is the ONLY place in the integration test suite that touches the
// Firebase SDK directly. Every test body should bind the wrapper instances it
// receives from the factory methods below to their protocol types and operate
// only through the protocol surface.

import Foundation
import XCTest
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
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

  public static let firestorePort = 8080
  public static let authPort = 9099
  public static let storagePort = 9199

  /// Skip the calling test when the emulator is not configured.
  public static func skipIfDisabled(file: StaticString = #filePath, line: UInt = #line) throws {
    guard isEnabled else {
      throw XCTSkip("MODAAL_EMULATOR_HOST not set — skipping emulator-backed test",
                    file: file, line: line)
    }
  }

  // MARK: - One-time Firebase configuration

  private static var isConfigured = false
  private static let configureLock = NSLock()

  /// Configure Firebase (once per process) with bogus options and point each
  /// service at the local emulator. Safe to call from every `setUp`.
  public static func configureFirebaseForEmulatorIfNeeded() {
    configureLock.lock()
    defer { configureLock.unlock() }
    guard !isConfigured else { return }

    let options = FirebaseOptions(googleAppID: "1:0000000000:ios:0000000000000000000000",
                                  gcmSenderID: "0000000000")
    options.apiKey = "fake-api-key"
    options.projectID = projectID
    options.storageBucket = storageBucket
    FirebaseApp.configure(options: options)

    let settings = FirestoreSettings()
    settings.host = "\(host):\(firestorePort)"
    settings.isSSLEnabled = false
    settings.cacheSettings = MemoryCacheSettings()
    Firestore.firestore().settings = settings

    Auth.auth().useEmulator(withHost: host, port: authPort)
    Storage.storage().useEmulator(withHost: host, port: storagePort)

    isConfigured = true
  }

  // MARK: - Protocol-typed factories (the ONLY entry point for tests)

  public static func makeFirestore() -> FirestoreProtocol {
    FirestoreWrapper(firestore: Firestore.firestore())
  }

  public static func makeAuth() -> FirebaseAuthProtocol {
    FirebaseAuthWrapper(auth: Auth.auth())
  }

  public static func makeStorage() -> CloudStorageProtocol {
    CloudStorageWrapper(storage: Storage.storage())
  }

  // MARK: - State reset (REST)

  /// Clears Firestore documents and Auth accounts. Storage state is not reset
  /// across tests — tests use unique paths per case.
  public static func resetEmulatorState() async throws {
    try await delete("http://\(host):\(firestorePort)/emulator/v1/projects/\(projectID)/databases/(default)/documents")
    try await delete("http://\(host):\(authPort)/emulator/v1/projects/\(projectID)/accounts")
  }

  private static func delete(_ urlString: String) async throws {
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    _ = try await URLSession.shared.data(for: request)
  }
}

/// Base class for integration tests — wires `setUp` to ensure Firebase is
/// configured and emulator state is reset. Subclasses interact only via the
/// `FirestoreProtocol` / `FirebaseAuthProtocol` / `CloudStorageProtocol`
/// factories on `EmulatorHarness`.
open class EmulatorIntegrationTestCase: XCTestCase {
  open override func setUp() async throws {
    try await super.setUp()
    try EmulatorHarness.skipIfDisabled()
    EmulatorHarness.configureFirebaseForEmulatorIfNeeded()
    try await EmulatorHarness.resetEmulatorState()
  }
}
