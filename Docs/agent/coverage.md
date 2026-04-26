# Protocol Coverage Audit

Per-module coverage of the Firebase iOS SDK 12.x API surface. "Wrapped" means a protocol method exists. "Escape hatch" means accessible via the public underlying Firebase type on entry-point wrappers.

## ModaalFirebaseCore

| API | Status |
|-----|--------|
| `FirebaseApp.configure()` | Wrapped (`ModaalFirebase.shared.configure()`) |
| `FirebaseApp.configure(options:)` from plist | Wrapped (`configure(plistPath:)`) |
| `FirebaseApp.configure(options:)` in-code | Wrapped (`configure(options:)` + `ModaalFirebaseOptions`) |
| `FirAppOptions.clientID` | Wrapped |
| `FirebaseOptions` fields: `googleAppID` / `gcmSenderID` / `apiKey` / `projectID` / `storageBucket` / `clientID` / `bundleID` | Wrapped via `ModaalFirebaseOptions` |
| `FirebaseOptions` fields: `androidClientID` / `appGroupID` / `deepLinkURLScheme` / `databaseURL` | Not covered (additive when needed) |

No escape hatch needed — Core is a thin bootstrap layer.

## ModaalFirebaseAuth

| API | Status |
|-----|--------|
| `signInAnonymously` | Wrapped |
| `signIn(with: AuthCredential)` | Wrapped |
| `signIn(withEmail:password:)` | Wrapped |
| `createUser(withEmail:password:)` | Wrapped |
| `sendPasswordReset(withEmail:)` | Wrapped |
| `signOut()` | Wrapped |
| `deleteUser(_:)` | Wrapped |
| `revokeToken(withAuthorizationCode:)` | Wrapped |
| `currentUser` | Wrapped |
| `addStateDidChangeListener` / `removeStateDidChangeListener` | Wrapped |
| `shareAuthStateAcrossDevices` | Wrapped |
| `useUserAccessGroup(_:)` | Wrapped |
| `canHandleOpenUrl` / `setAPNSToken` / `canHandleRemoteNotification` | Wrapped |
| `User.getIDToken` / `getIDTokenResult` | Wrapped |
| `User.reauthenticate(with:)` | Wrapped |
| `User.link(with:)` / `unlink(fromProvider:)` | Wrapped |
| `User.sendEmailVerification` | Wrapped |
| `User.updateUserProfile` / `updatePassword` / `reload` | Wrapped |
| `User.isAnonymous` / `isEmailVerified` / `refreshToken` / `metadata` / `providerData` | Wrapped |
| `Auth.languageCode` | Escape hatch (`authWrapper.auth.languageCode`) |
| `Auth.signIn(withEmail:link:)` | Escape hatch |
| `User.multiFactor` | Escape hatch |
| `Auth.auth()` default instance | Wrapped (`FirebaseAuthWrapper.makeDefault(emulator:)`) |
| `Auth.useEmulator(host:port:)` | Wrapped via `makeDefault(emulator:)` |
| `OAuthProvider.appleCredential(withIDToken:rawNonce:fullName:)` | Wrapped via `FirebaseAuthCredentialProtocol.apple(idToken:rawNonce:fullName:)` (implicit-member syntax: `let c: FirebaseAuthCredentialProtocol = .apple(...)`) |
| `GoogleAuthProvider.credential(withIDToken:accessToken:)` | Wrapped via `FirebaseAuthCredentialProtocol.google(idToken:accessToken:)` |
| `OAuthProvider.credential(providerID:idToken:rawNonce:accessToken:)` (Microsoft, Yahoo, custom OIDC) | Escape hatch — Firebase 12.x's modern API takes an `AuthProviderID` enum (`.custom("oidc.my-provider")`) which would need its own wrapper (`ModaalAuthProviderID`) to keep `import FirebaseAuth` out of consumer code. Until that lands: `import FirebaseAuth` at the credential-construction call site only. |

**Escape hatch:** `FirebaseAuthWrapper.auth: Auth` (public)

## ModaalFirebaseAnalytics

| API | Status |
|-----|--------|
| `logEvent(name:parameters:)` | Wrapped |
| `setUserProperty(_:forName:)` | Wrapped |
| `setUserID(_:)` | Wrapped |
| `setAnalyticsCollectionEnabled(_:)` | Wrapped |
| `resetAnalyticsData()` | Wrapped |
| `setConsent(_:)` | Escape hatch (static `Analytics` methods) |
| `setDefaultEventParameters(_:)` | Escape hatch |
| `appInstanceID()` | Escape hatch |

**Escape hatch:** Analytics uses static methods — call `Analytics.*` directly for unwrapped methods.

## ModaalFirebaseCrashlytics

| API | Status |
|-----|--------|
| `setUserID(_:)` | Wrapped |
| `setCustomValue(_:forKey:)` | Wrapped |
| `log(_:)` | Wrapped |
| `record(error:userInfo:)` | Wrapped |
| `isCrashlyticsCollectionEnabled` | Direct access on concrete `Crashlytics` instance |
| `setCrashlyticsCollectionEnabled(_:)` | Direct access on concrete `Crashlytics` instance |
| `didCrashDuringPreviousExecution` | Direct access on concrete `Crashlytics` instance |
| `Crashlytics.crashlytics()` default instance | Wrapped (`FirebaseCrashlyticsProtocol.makeDefault()` — protocol-level static factory, implicit-member syntax: `let c: FirebaseCrashlyticsProtocol = .makeDefault()`) |

**Note:** Crashlytics uses direct extension conformance (`extension Crashlytics: FirebaseCrashlyticsProtocol {}`). The consumer already has the concrete type — privacy toggles and other properties are accessible directly. The xcframeworks binary doesn't expose these in a protocol-conformable way.

## ModaalFirestore

| API | Status |
|-----|--------|
| `collection(_:)` / `collectionGroup(_:)` / `document(_:)` | Wrapped |
| `batch()` / `runTransaction(_:)` | Wrapped |
| `CollectionReference.*` (collectionID, path, parent, document, addDocument) | Wrapped |
| `DocumentReference.*` (CRUD, addSnapshotListener with includeMetadataChanges) | Wrapped |
| `Query.*` (whereFilter, order, limit, 8 pagination cursors, getDocuments with source) | Wrapped |
| `QuerySnapshot.*` (documents, documentChanges, count, isEmpty, metadata) | Wrapped |
| `DocumentSnapshot.*` (documentID, exists, reference, data, get, metadata) | Wrapped |
| `WriteBatch.*` / `Transaction.*` | Wrapped |
| `AggregateQuery.getAggregation(source:)` | Wrapped |
| `SnapshotMetadata` (hasPendingWrites, isFromCache) | Wrapped (direct conformance) |
| `DocumentSnapshot.data(as:)` / `setData(from:)` (Codable) | Escape hatch |
| `Firestore.settings` / `enableNetwork` / `disableNetwork` | Escape hatch |
| `Firestore.clearPersistence` / `terminate` / `waitForPendingWrites` | Escape hatch |
| `Firestore.firestore()` default instance | Wrapped (`FirestoreWrapper.makeDefault(emulator:)`) |
| `FirestoreSettings.host` / `isSSLEnabled` / `MemoryCacheSettings` (emulator wiring) | Wrapped via `makeDefault(emulator:)` |
| `Timestamp` (write-payload value type) | Re-exported as `ModaalFirestore.Timestamp` (typealias) — usable under `import ModaalFirestore` alone |
| `FieldValue.serverTimestamp() / .delete() / .arrayUnion(_:) / .arrayRemove(_:) / .increment(_:)` (write-payload sentinels) | Re-exported as `ModaalFirestore.FieldValue` (typealias) — usable under `import ModaalFirestore` alone |

**Escape hatch:** `FirestoreWrapper.firestore: Firestore` (public)

**Note on raw-type re-exports:** `Timestamp` and `FieldValue` are value types that the wrapper passes through opaquely via `[String: Any]` document data — re-exporting their *names* under `import ModaalFirestore` does not change the protocol surface (no method signature names them) but lets consumers construct write payloads without `import FirebaseFirestore`. Reference types (`CollectionReference`, `DocumentReference`, `ListenerRegistration`, etc.) are intentionally NOT re-exported — they have dedicated wrapper protocols.

## ModaalCloudStorage

| API | Status |
|-----|--------|
| `reference()` / `reference(forURL:)` / `reference(withPath:)` | Wrapped |
| `fullPath` / `name` / `bucket` / `child` / `parent` / `root` | Wrapped |
| `getData` / `downloadToFile` / `getDownloadURL` | Wrapped |
| `putData` / `uploadFromFile` (with optional metadata) | Wrapped |
| `getMetadata` / `updateMetadata` | Wrapped |
| `delete` | Wrapped |
| `listAll` | Wrapped |
| `list(maxResults:)` / `list(maxResults:pageToken:)` | Escape hatch |
| `Storage.storage()` default instance | Wrapped (`CloudStorageWrapper.makeDefault(emulator:)`) |
| `Storage.useEmulator(host:port:)` | Wrapped via `makeDefault(emulator:)` |

**Escape hatch:** `CloudStorageWrapper.storage: Storage` (public), `CloudStorageReference.reference: StorageReference` (public)

## ModaalFirebaseMessaging

| API | Status |
|-----|--------|
| `fcmToken` / `apnsToken` / `isAutoInitEnabled` | Wrapped |
| `token(completion:)` / `deleteToken(completion:)` | Wrapped |
| `subscribe(toTopic:)` / `unsubscribe(fromTopic:)` | Wrapped |
| `MessagingDelegate` | Escape hatch (`messagingWrapper.messaging.delegate`) |
| `appDidReceiveMessage(_:)` | Escape hatch |
| `Messaging.messaging()` default instance | Wrapped (`FirebaseMessagingWrapper.makeDefault()`) |

**Escape hatch:** `FirebaseMessagingWrapper.messaging: Messaging` (public)

**No emulator variant:** Firebase Emulator Suite has no FCM emulator.

## ModaalFirebaseRemoteConfig

| API | Status |
|-----|--------|
| `minimumFetchInterval` / `lastFetchTime` / `lastFetchStatus` | Wrapped |
| `fetch` / `fetchAndActivate` / `activate` | Wrapped |
| `configValue(forKey:)` / `allKeys(from:)` / `setDefaults(_:)` | Wrapped |
| `addOnConfigUpdateListener` | Wrapped |
| `RemoteConfigValue.*` (stringValue, numberValue, dataValue, boolValue, jsonValue, source) | Wrapped |
| `configSettings.fetchTimeout` | Escape hatch |
| `setDefaults(fromPlist:)` | Escape hatch |
| `ensureInitialized(completion:)` | Escape hatch |
| `RemoteConfig.remoteConfig()` default instance | Wrapped (`FirebaseRemoteConfigWrapper.makeDefault()`) |

**Escape hatch:** `FirebaseRemoteConfigWrapper.remoteConfig: RemoteConfig` (public)

**No emulator variant:** Firebase Emulator Suite has no Remote Config emulator; use `setDefaults(_:)` for local testing.

## ModaalGoogleSignIn (not yet wrapped)

Google Sign-In's iOS SDK (`GIDSignIn`) is **not yet wrapped**. The `firebase-ios-sdk-xcframeworks` package re-exports the `GoogleSignIn` library product (binary XCFramework, resources self-contained); consumers add it directly until a `ModaalGoogleSignIn` module ships.

| API | Status |
|-----|--------|
| `GIDSignIn.sharedInstance.signIn(withPresenting:)` | Not yet wrapped — consume `GoogleSignIn` directly |
| `GIDSignIn.sharedInstance.handle(_ url:)` | Not yet wrapped |
| `GIDSignIn.sharedInstance.restorePreviousSignIn(completion:)` | Not yet wrapped |
| `GIDSignIn.sharedInstance.disconnect(completion:)` | Not yet wrapped |
| `GIDConfiguration(clientID:)` | Not yet wrapped |
| `GIDSignInResult.user.idToken` / `.accessToken` | Not yet wrapped |
| `GoogleAuthProvider.credential(withIDToken:accessToken:)` | Wrapped (re-exported from `ModaalFirebaseAuth`) — feed the credential to `auth.signIn(with:)` |

**Interim consumer guidance** (Modaal repo): [`integrations-firebase.md#google-signin-interim`](https://github.com/modaal-agent/modaal-agent/blob/main/resources/knowledge/integrations-firebase.md#google-signin-interim).

**Roadmap entry** (Modaal repo): [`firebase-shared-wrapper-followup-GoogleSignIn.md`](https://github.com/modaal-agent/modaal-agent/blob/main/specs/066-integrations-firebase/firebase-shared-wrapper-followup-GoogleSignIn.md).

## Combine Extension Layer

Every completion-handler method has a corresponding Combine extension (protocol default implementation):

- **43 `Future<T, Error>` methods** — one-shot operations (signIn, getDocument, delete, etc.). Breakdown: Auth 16, Firestore 9, Cloud Storage 11, Messaging 4, Remote Config 3.
- **4 streaming publishers** — `authStateDidChangePublisher()`, `snapshotPublisher()` (doc + query), `configUpdatePublisher()`

Extensions are in `Sources/<Module>/Combine/` and work with any protocol conformer (wrappers and mocks).
