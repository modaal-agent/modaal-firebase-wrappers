# Protocol Coverage Audit

Per-module coverage of the Firebase iOS SDK 12.x API surface. "Wrapped" means a protocol method exists. "Escape hatch" means accessible via the public underlying Firebase type on entry-point wrappers.

## ModaalFirebaseCore

| API | Status |
|-----|--------|
| `FirebaseApp.configure()` | Wrapped (`ModaalFirebase.shared.configure()`) |
| `FirebaseApp.configure(options:)` | Wrapped (`configure(plistPath:)`) |
| `FirAppOptions.clientID` | Wrapped |

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

**Escape hatch:** `FirestoreWrapper.firestore: Firestore` (public)

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

**Escape hatch:** `CloudStorageWrapper.storage: Storage` (public), `CloudStorageReference.reference: StorageReference` (public)

## ModaalFirebaseMessaging

| API | Status |
|-----|--------|
| `fcmToken` / `apnsToken` / `isAutoInitEnabled` | Wrapped |
| `token(completion:)` / `deleteToken(completion:)` | Wrapped |
| `subscribe(toTopic:)` / `unsubscribe(fromTopic:)` | Wrapped |
| `MessagingDelegate` | Escape hatch (`messagingWrapper.messaging.delegate`) |
| `appDidReceiveMessage(_:)` | Escape hatch |

**Escape hatch:** `FirebaseMessagingWrapper.messaging: Messaging` (public)

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

**Escape hatch:** `FirebaseRemoteConfigWrapper.remoteConfig: RemoteConfig` (public)

## Combine Extension Layer

Every completion-handler method has a corresponding Combine extension (protocol default implementation):

- **39 `Future<T, Error>` methods** — one-shot operations (signIn, getDocument, delete, etc.)
- **4 streaming publishers** — `authStateDidChangePublisher()`, `snapshotPublisher()` (doc + query), `configUpdatePublisher()`

Extensions are in `Sources/<Module>/Combine/` and work with any protocol conformer (wrappers and mocks).
