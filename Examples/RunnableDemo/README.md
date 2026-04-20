# RunnableDemo — Realtime market ticker

A small SwiftUI app that demonstrates `ModaalFirebase` end-to-end against the local Firebase Emulator.

- **Foreground**: `TickerViewModel` subscribes to the `/tickers` collection via the Combine `snapshotPublisher()` on `CollectionReferenceProtocol`, re-rendering the market list on every document change.
- **Background**: `TickerWriter` randomly walks a fixed basket of symbols (AAPL, MSFT, GOOG, …) on a 1 Hz `Timer.publish`, writing each tick via `DocumentReferenceProtocol.setData(...)` (Combine wrapper).

Everything outside `AppBootstrap.configure()` goes through the `FirestoreProtocol` / `CollectionReferenceProtocol` / `DocumentReferenceProtocol` surface — zero Firebase SDK imports in the view model or writer. `AppBootstrap` is the single place that instantiates the wrapper and points it at the emulator.

## Run

```bash
# 1. Start the emulator (in one terminal)
firebase emulators:start --only firestore --project demo-modaal

# 2. Generate + open the Xcode project
cd Examples/RunnableDemo
mint run yonaskolb/XcodeGen xcodegen generate --spec xcodegen.yml
open RunnableDemo.xcodeproj

# 3. Build + run on any iOS 17+ Simulator
```

You should see six symbols immediately (seeded on launch) and prices wobbling every second.

## Files

- `RunnableDemoApp.swift` — SwiftUI `@main` + `AppBootstrap.configure()` (the sole Firebase-SDK touchpoint)
- `TickerView.swift` — `TickerViewModel` + `TickerView` + `TickerRow`, driven by `CollectionReferenceProtocol.snapshotPublisher()`
- `TickerWriter.swift` — timer-driven writer using `DocumentReferenceProtocol.setData(_:)` Combine wrapper
- `Ticker.swift` — plain model struct + seed catalog
