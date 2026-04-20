// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import SwiftUI
import Combine
import ModaalFirestore

@MainActor
final class TickerViewModel: ObservableObject {
  @Published private(set) var tickers: [Ticker] = []
  @Published private(set) var connectionStatus: String = "Connecting…"
  @Published private(set) var isLive: Bool = false

  private let firestore: FirestoreProtocol
  private let writer: TickerWriter
  private var subscription: AnyCancellable?

  init(firestore: FirestoreProtocol) {
    self.firestore = firestore
    self.writer = TickerWriter(firestore: firestore)
  }

  func start() {
    // Foreground: reactive snapshot listener on the collection via the
    // Combine wrapper on QueryProtocol.
    let collection: CollectionReferenceProtocol = firestore.collection("tickers")
    subscription = collection
      .snapshotPublisher()
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          if case .failure(let error) = completion {
            self?.connectionStatus = "Error: \(error.localizedDescription)"
            self?.isLive = false
          }
        },
        receiveValue: { [weak self] snapshot in
          guard let self else { return }
          let rows = snapshot.documents.compactMap {
            Ticker(documentID: $0.documentID, data: $0.data())
          }
          self.tickers = rows.sorted(by: { $0.id < $1.id })
          self.connectionStatus = "\(rows.count) symbols"
          self.isLive = true
        }
      )

    // Background: fake market data writer on a 1 Hz timer.
    writer.start()
  }

  func stop() {
    subscription?.cancel()
    subscription = nil
    writer.stop()
    connectionStatus = "Stopped"
    isLive = false
  }
}

struct TickerView: View {
  @ObservedObject var viewModel: TickerViewModel

  var body: some View {
    NavigationStack {
      List(viewModel.tickers) { ticker in
        TickerRow(ticker: ticker)
      }
      .navigationTitle("Market")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          HStack(spacing: 6) {
            Circle()
              .fill(viewModel.isLive ? Color.green : Color.secondary)
              .frame(width: 8, height: 8)
            Text(viewModel.connectionStatus)
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      }
    }
    .onAppear { viewModel.start() }
    .onDisappear { viewModel.stop() }
  }
}

struct TickerRow: View {
  let ticker: Ticker

  var body: some View {
    HStack {
      Text(ticker.id)
        .font(.system(.body, design: .monospaced).weight(.bold))
        .frame(width: 70, alignment: .leading)

      Spacer()

      VStack(alignment: .trailing, spacing: 2) {
        Text(String(format: "$%.2f", ticker.price))
          .font(.system(.body, design: .monospaced))

        Text(String(format: "%+.2f%%", ticker.changePct))
          .font(.caption.monospaced())
          .foregroundColor(ticker.changePct >= 0 ? .green : .red)
      }
    }
    .padding(.vertical, 4)
  }
}
