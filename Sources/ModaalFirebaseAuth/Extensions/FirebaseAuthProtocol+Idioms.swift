// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

// MARK: - Two-tier API surface
//
// `FirebaseAuthProtocol` mirrors `firebase-ios-sdk`'s `Auth` exactly at
// the protocol-declaration level (`canHandle(_)`, `canHandleNotification(_)`).
// The verbose `canHandleOpenUrl(_)` / `canHandleRemoteNotification(_)` forms
// live here as Swift-idiomatic aliases that delegate to the canonical methods.
// See `Docs/agent/patterns.md` § "Two-tier API surface".

public extension FirebaseAuthProtocol {
  func canHandleOpenUrl(_ url: URL) -> Bool {
    canHandle(url)
  }

  func canHandleRemoteNotification(_ notification: [AnyHashable: Any]) -> Bool {
    canHandleNotification(notification)
  }
}
