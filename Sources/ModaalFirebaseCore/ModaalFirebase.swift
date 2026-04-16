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
}
