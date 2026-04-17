// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

final class ListenerRegistrationWrapper: ListenerRegistrationProtocol {
  let registration: FirebaseFirestore.ListenerRegistration

  init(registration: FirebaseFirestore.ListenerRegistration) {
    self.registration = registration
  }

  func remove() {
    registration.remove()
  }
}
