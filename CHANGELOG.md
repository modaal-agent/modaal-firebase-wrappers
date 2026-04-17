# Changelog

## [1.0.0] — 2026-04-17

First stable release. 8 Firebase services wrapped behind Swift protocols with full Combine extension layer, escape hatches, and comprehensive documentation.

### Modules

- **ModaalFirebaseCore** — bootstrap (`configure()`) + `FirAppOptions`
- **ModaalFirebaseAuth** — 7 protocols, 40+ methods (sign-in, user management, ID tokens, reauthenticate, link/unlink, state listeners)
- **ModaalFirebaseAnalytics** — logEvent, setUserProperty, setUserID, privacy controls
- **ModaalFirebaseCrashlytics** — setUserID, setCustomValue, log, record (direct extension conformance)
- **ModaalFirestore** — 12 protocols, 70+ methods (CRUD, queries, pagination cursors, snapshot listeners with `includeMetadataChanges`, document changes, transactions, batched writes, aggregation)
- **ModaalCloudStorage** — 5 protocols (download, upload with metadata, delete, list, navigation, metadata operations)
- **ModaalFirebaseMessaging** — FCM token management, APNS token, topic subscribe/unsubscribe
- **ModaalFirebaseRemoteConfig** — fetch/activate, config values, real-time update listener, mirrored enums

### Highlights

- **31 protocols** wrapping the Firebase iOS SDK 12.x surface
- **~170 completion-handler methods** across all modules
- **39 `Future<T, Error>` Combine extensions** for one-shot operations
- **4 streaming publishers** (auth state, document snapshots, query snapshots, config updates)
- **Escape hatches** on every entry-point wrapper (public underlying Firebase type)
- **SampleApp** exercising 100% of protocol surface (completion handlers + Combine)
- **Comprehensive documentation** — README, architecture guide, getting-started guide, agent docs (coverage audit, patterns, anti-patterns, adding-a-wrapper), contributing guide

### Beyond original plan

The v1.0.0 release exceeds the original spec's planned scope:

| Area | Original plan | Delivered |
|------|--------------|-----------|
| Auth methods | ~30 (ported from template) | ~40 (+ signIn email/pw, getIDToken, reauthenticate, unlink, updatePassword, reload, revokeToken) |
| Firestore methods | ~15 (leaky — raw types) | ~70 (fully wrapped, pagination cursors, documentChanges, metadata, source-aware reads) |
| CloudStorage methods | ~10 (leaky entry point) | ~25 (fully wrapped, metadata operations, upload-with-metadata) |
| Combine layer | Not planned | 39 Future + 4 streaming publishers, FirebaseCombineSwift-compatible |
| Escape hatches | Not planned | Public underlying type on every entry-point wrapper |
| Privacy controls | Not planned | Analytics collection toggle + reset, Crashlytics collection via direct access |
| Default parameters | Not planned | `setData` defaults to `.overwrite`, `addSnapshotListener` defaults `includeMetadataChanges` to `false` |
