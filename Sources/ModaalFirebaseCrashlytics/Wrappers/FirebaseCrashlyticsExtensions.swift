// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseCrashlytics

extension FirebaseCrashlytics.Crashlytics: FirebaseCrashlyticsProtocol {}

public extension FirebaseCrashlyticsProtocol where Self == FirebaseCrashlytics.Crashlytics {
  /// Return the default `Crashlytics.crashlytics()` instance typed as
  /// `FirebaseCrashlyticsProtocol`.
  ///
  /// Crashlytics uses direct extension conformance (no wrapper class), so
  /// this factory lives on the protocol itself. Swift's protocol-static
  /// lookup requires an expected-type context — call it via implicit-member
  /// syntax:
  ///
  /// ```swift
  /// let crashlytics: FirebaseCrashlyticsProtocol = .makeDefault()
  /// ```
  ///
  /// No `import FirebaseCrashlytics` required at the call site.
  static func makeDefault() -> Self {
    Crashlytics.crashlytics()
  }
}
