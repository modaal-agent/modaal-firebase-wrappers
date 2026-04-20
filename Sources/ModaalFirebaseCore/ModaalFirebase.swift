// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation
import FirebaseCore

public final class ModaalFirebase {
  public static let shared = ModaalFirebase()

  private init() {}

  /// Configure Firebase using the default `GoogleService-Info.plist` in the main bundle.
  public func configure() {
    FirebaseApp.configure()
  }

  /// Configure Firebase using a `GoogleService-Info.plist` at the given file path.
  /// Returns the parsed options on success, or `nil` if the file is missing or invalid.
  @discardableResult
  public func configure(plistPath: String) -> FirAppOptions? {
    guard FileManager.default.fileExists(atPath: plistPath),
          let options = FirebaseOptions(contentsOfFile: plistPath)
    else {
      return nil
    }
    FirebaseApp.configure(options: options)
    return FirAppOptions(clientID: options.clientID ?? "")
  }

  /// Configure Firebase with options built in code — useful for testing with
  /// the Firebase Emulator Suite (project IDs starting with `demo-`) or for
  /// apps that don't ship `GoogleService-Info.plist`.
  public func configure(options: ModaalFirebaseOptions) {
    let firebaseOptions = FirebaseOptions(googleAppID: options.googleAppID,
                                          gcmSenderID: options.gcmSenderID)
    if let apiKey = options.apiKey { firebaseOptions.apiKey = apiKey }
    if let projectID = options.projectID { firebaseOptions.projectID = projectID }
    if let storageBucket = options.storageBucket { firebaseOptions.storageBucket = storageBucket }
    if let clientID = options.clientID { firebaseOptions.clientID = clientID }
    if let bundleID = options.bundleID { firebaseOptions.bundleID = bundleID }
    FirebaseApp.configure(options: firebaseOptions)
  }
}

/// In-code Firebase configuration. Mirrors `FirebaseOptions` — the fields
/// most commonly needed for emulator / testing setups, without making
/// consumers `import FirebaseCore`.
public struct ModaalFirebaseOptions {
  public let googleAppID: String
  public let gcmSenderID: String
  public var apiKey: String?
  public var projectID: String?
  public var storageBucket: String?
  public var clientID: String?
  public var bundleID: String?

  public init(googleAppID: String,
              gcmSenderID: String,
              apiKey: String? = nil,
              projectID: String? = nil,
              storageBucket: String? = nil,
              clientID: String? = nil,
              bundleID: String? = nil) {
    self.googleAppID = googleAppID
    self.gcmSenderID = gcmSenderID
    self.apiKey = apiKey
    self.projectID = projectID
    self.storageBucket = storageBucket
    self.clientID = clientID
    self.bundleID = bundleID
  }
}
