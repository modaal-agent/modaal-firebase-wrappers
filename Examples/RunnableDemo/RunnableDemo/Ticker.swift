// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

/// One row in the /tickers collection.
struct Ticker: Identifiable, Equatable {
  let id: String      // symbol, e.g. "AAPL"
  let price: Double
  let changePct: Double
  let updatedAt: Date

  init?(documentID: String, data: [String: Any]?) {
    guard
      let data,
      let price = data["price"] as? Double,
      let changePct = data["changePct"] as? Double
    else { return nil }
    self.id = documentID
    self.price = price
    self.changePct = changePct
    self.updatedAt = (data["updatedAt"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) }
      ?? Date()
  }
}

enum TickerCatalog {
  /// Fake symbols + starting prices used by the writer job.
  static let seed: [(symbol: String, startPrice: Double)] = [
    ("AAPL", 225.00),
    ("MSFT", 410.00),
    ("GOOG", 170.00),
    ("AMZN", 190.00),
    ("NVDA", 135.00),
    ("META", 575.00),
  ]
}
