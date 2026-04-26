// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

// Public typealiases for raw Firestore value types that the wrapper passes
// through opaquely via `[String: Any]` document data — `Timestamp` and
// `FieldValue` already cross the wrapper boundary as `Any` payloads, so
// re-exporting their *names* under `import ModaalFirestore` lets consumers
// construct write payloads (createdAt, updatedAt, .serverTimestamp(), .delete(),
// .arrayUnion(...), .arrayRemove(...), .increment(_:)) without an additional
// `import FirebaseFirestore` at the call site.
//
// This is **not** a relaxation of the "no raw Firebase types in protocol
// surfaces" rule — protocol method signatures continue to use only wrapper
// protocol types. These are value types passed through dict payloads, where
// the abstraction was already opaque.
//
// Reference types (`CollectionReference`, `DocumentReference`,
// `ListenerRegistration`, etc.) are intentionally NOT re-exported — they have
// dedicated wrapper protocols (`CollectionReferenceProtocol`,
// `DocumentReferenceProtocol`, `ListenerRegistrationProtocol`) that the
// `FirestoreProtocol` surface returns.

public typealias Timestamp = FirebaseFirestore.Timestamp
public typealias FieldValue = FirebaseFirestore.FieldValue
