// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.
//
// End-to-end demo: a stock-ticker UI driven by a Firestore snapshot listener,
// fed by a background writer job that pushes fake market data into the local
// Firebase Emulator. Both the UI and the writer interact with Firestore only
// through `ModaalFirestore` protocol types + Combine wrappers — the single
// Firebase-SDK touchpoint is `AppBootstrap.configure()` below.
//
// Run `firebase emulators:start --only firestore --project demo-modaal`
// locally, then launch this app in an iOS Simulator.

import SwiftUI
import ModaalFirebaseCore
import ModaalFirestore

@main
struct RunnableDemoApp: App {
  @StateObject private var tickerViewModel = TickerViewModel(
    firestore: AppBootstrap.configure()
  )

  var body: some Scene {
    WindowGroup {
      TickerView(viewModel: tickerViewModel)
    }
  }
}

/// No Firebase SDK imports: everything is expressed through the
/// `ModaalFirebase*` wrappers.
enum AppBootstrap {
  static func configure() -> FirestoreProtocol {
    ModaalFirebase.shared.configure(options: ModaalFirebaseOptions(
      googleAppID: "1:1234567890:ios:abcdef1234567890abcdef",
      gcmSenderID: "1234567890",
      apiKey: "A" + String(repeating: "z", count: 38),
      projectID: "demo-modaal",
      storageBucket: "demo-modaal.appspot.com"
    ))
    return FirestoreWrapper.makeDefault(emulator: (host: "localhost", port: 8080))
  }
}
