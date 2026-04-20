// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation
import Combine
import ModaalFirestore

/// Background job that pushes fake price updates into the /tickers collection
/// on a timer. Uses the Combine writer on DocumentReferenceProtocol — no
/// Firebase SDK types visible.
final class TickerWriter {
  private let firestore: FirestoreProtocol
  private let interval: TimeInterval
  private var cancellables: Set<AnyCancellable> = []
  private var prices: [String: Double]
  private var timerCancellable: AnyCancellable?

  init(firestore: FirestoreProtocol, interval: TimeInterval = 1.0) {
    self.firestore = firestore
    self.interval = interval
    self.prices = Dictionary(uniqueKeysWithValues:
      TickerCatalog.seed.map { ($0.symbol, $0.startPrice) })
  }

  func start() {
    guard timerCancellable == nil else { return }
    seedIfNeeded()
    timerCancellable = Timer.publish(every: interval, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in self?.tick() }
  }

  func stop() {
    timerCancellable?.cancel()
    timerCancellable = nil
    cancellables.removeAll()
  }

  // MARK: - Private

  /// Write initial prices once so the UI has something to render before the
  /// first tick fires.
  private func seedIfNeeded() {
    for (symbol, price) in prices {
      publish(symbol: symbol, price: price, changePct: 0)
    }
  }

  private func tick() {
    for (symbol, lastPrice) in prices {
      // Random walk, +/- 0.5% per tick.
      let delta = Double.random(in: -0.005...0.005)
      let newPrice = max(0.01, lastPrice * (1 + delta))
      prices[symbol] = newPrice
      publish(symbol: symbol, price: newPrice, changePct: delta * 100)
    }
  }

  private func publish(symbol: String, price: Double, changePct: Double) {
    let doc: DocumentReferenceProtocol = firestore.document("tickers/\(symbol)")
    doc.setData([
      "price": price,
      "changePct": changePct,
      "updatedAt": Date().timeIntervalSince1970,
    ])
    .sink(
      receiveCompletion: { completion in
        if case .failure(let error) = completion {
          print("TickerWriter: failed to publish \(symbol): \(error)")
        }
      },
      receiveValue: { _ in }
    )
    .store(in: &cancellables)
  }
}
