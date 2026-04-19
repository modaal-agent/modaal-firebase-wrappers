// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import UIKit
@testable import ModaalFirebaseAuth

// MARK: - FirebaseAuthCredentialProtocol
class FirebaseAuthCredentialProtocolMock: FirebaseAuthCredentialProtocol {

    // MARK: - Variables
    var provider: String = ""
}

// MARK: - FirebaseAuthDataResultProtocol
class FirebaseAuthDataResultProtocolMock: FirebaseAuthDataResultProtocol {

    // MARK: - Variables
    var credential: FirebaseAuthCredentialProtocol? = nil
    var user: FirebaseUserProtocol

    // MARK: - Initializer
    init(user: FirebaseUserProtocol) {
        self.user = user
    }
}

// MARK: - FirebaseAuthProtocol
class FirebaseAuthProtocolMock: FirebaseAuthProtocol {

    // MARK: - Variables
    var currentUser: FirebaseUserProtocol? = nil
    var shareAuthStateAcrossDevices: Bool = false {
        didSet {
            shareAuthStateAcrossDevicesSetCount += 1
        }
    }
    var shareAuthStateAcrossDevicesSetCount: Int = 0

    // MARK: - Methods
    func addStateDidChangeListener(_ listener: (FirebaseAuthProtocol, FirebaseUserProtocol?) -> Void) -> FirebaseAuthStateDidChangeListenerHandle {
        addStateDidChangeListenerCallCount += 1
        if let __addStateDidChangeListenerHandler = self.addStateDidChangeListenerHandler {
            return __addStateDidChangeListenerHandler(listener)
        }
        fatalError("addStateDidChangeListenerHandler expected to be set.")
    }
    var addStateDidChangeListenerCallCount: Int = 0
    var addStateDidChangeListenerHandler: ((_ listener: (FirebaseAuthProtocol, FirebaseUserProtocol?) -> Void) -> (FirebaseAuthStateDidChangeListenerHandle))? = nil
    func canHandleOpenUrl(_ url: URL) -> Bool {
        canHandleOpenUrlCallCount += 1
        if let __canHandleOpenUrlHandler = self.canHandleOpenUrlHandler {
            return __canHandleOpenUrlHandler(url)
        }
        return false
    }
    var canHandleOpenUrlCallCount: Int = 0
    var canHandleOpenUrlHandler: ((_ url: URL) -> (Bool))? = nil
    func canHandleRemoteNotification(_ notification: [AnyHashable: Any]) -> Bool {
        canHandleRemoteNotificationCallCount += 1
        if let __canHandleRemoteNotificationHandler = self.canHandleRemoteNotificationHandler {
            return __canHandleRemoteNotificationHandler(notification)
        }
        return false
    }
    var canHandleRemoteNotificationCallCount: Int = 0
    var canHandleRemoteNotificationHandler: ((_ notification: [AnyHashable: Any]) -> (Bool))? = nil
    func createUser(withEmail email: String, password: String, completion: (Result<FirebaseAuthDataResultProtocol, Error>) -> ()) {
        createUserCallCount += 1
        if let __createUserHandler = self.createUserHandler {
            __createUserHandler(email, password, completion)
        }
    }
    var createUserCallCount: Int = 0
    var createUserHandler: ((_ email: String, _ password: String, _ completion: (Result<FirebaseAuthDataResultProtocol, Error>) -> ()) -> ())? = nil
    func deleteUser(_ user: FirebaseUserProtocol, completion: (Result<Void, Error>) -> Void) {
        deleteUserCallCount += 1
        if let __deleteUserHandler = self.deleteUserHandler {
            __deleteUserHandler(user, completion)
        }
    }
    var deleteUserCallCount: Int = 0
    var deleteUserHandler: ((_ user: FirebaseUserProtocol, _ completion: (Result<Void, Error>) -> Void) -> ())? = nil
    func removeStateDidChangeListener(_ handle: FirebaseAuthStateDidChangeListenerHandle) {
        removeStateDidChangeListenerCallCount += 1
        if let __removeStateDidChangeListenerHandler = self.removeStateDidChangeListenerHandler {
            __removeStateDidChangeListenerHandler(handle)
        }
    }
    var removeStateDidChangeListenerCallCount: Int = 0
    var removeStateDidChangeListenerHandler: ((_ handle: FirebaseAuthStateDidChangeListenerHandle) -> ())? = nil
    func revokeToken(withAuthorizationCode authorizationCode: String, completion: (Result<Void, Error>) -> Void) {
        revokeTokenCallCount += 1
        if let __revokeTokenHandler = self.revokeTokenHandler {
            __revokeTokenHandler(authorizationCode, completion)
        }
    }
    var revokeTokenCallCount: Int = 0
    var revokeTokenHandler: ((_ authorizationCode: String, _ completion: (Result<Void, Error>) -> Void) -> ())? = nil
    func sendPasswordReset(withEmail: String, completion: (Result<Void, Error>) -> ()) {
        sendPasswordResetCallCount += 1
        if let __sendPasswordResetHandler = self.sendPasswordResetHandler {
            __sendPasswordResetHandler(withEmail, completion)
        }
    }
    var sendPasswordResetCallCount: Int = 0
    var sendPasswordResetHandler: ((_ withEmail: String, _ completion: (Result<Void, Error>) -> ()) -> ())? = nil
    func setAPNSToken(_ deviceToken: Data, type: FirebaseAuthAPNSTokenType) {
        setAPNSTokenCallCount += 1
        if let __setAPNSTokenHandler = self.setAPNSTokenHandler {
            __setAPNSTokenHandler(deviceToken, type)
        }
    }
    var setAPNSTokenCallCount: Int = 0
    var setAPNSTokenHandler: ((_ deviceToken: Data, _ type: FirebaseAuthAPNSTokenType) -> ())? = nil
    func signIn(with credential: FirebaseAuthCredentialProtocol, completion: (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) {
        signInCallCount += 1
        if let __signInHandler = self.signInHandler {
            __signInHandler(credential, completion)
        }
    }
    var signInCallCount: Int = 0
    var signInHandler: ((_ credential: FirebaseAuthCredentialProtocol, _ completion: (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) -> ())? = nil
    func signInAnonymously(completion: (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) {
        signInAnonymouslyCallCount += 1
        if let __signInAnonymouslyHandler = self.signInAnonymouslyHandler {
            __signInAnonymouslyHandler(completion)
        }
    }
    var signInAnonymouslyCallCount: Int = 0
    var signInAnonymouslyHandler: ((_ completion: (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) -> ())? = nil
    func signIn(withEmail email: String, password: String, completion: (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) {
        signInWithEmailEmailPasswordCompletionCallCount += 1
        if let __signInWithEmailEmailPasswordCompletionHandler = self.signInWithEmailEmailPasswordCompletionHandler {
            __signInWithEmailEmailPasswordCompletionHandler(email, password, completion)
        }
    }
    var signInWithEmailEmailPasswordCompletionCallCount: Int = 0
    var signInWithEmailEmailPasswordCompletionHandler: ((_ email: String, _ password: String, _ completion: (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) -> ())? = nil
    func signOut() throws {
        signOutCallCount += 1
        if let __signOutHandler = self.signOutHandler {
            try __signOutHandler()
        }
    }
    var signOutCallCount: Int = 0
    var signOutHandler: (() throws -> ())? = nil
    func useUserAccessGroup(_ userAccessGroup: String?) throws {
        useUserAccessGroupCallCount += 1
        if let __useUserAccessGroupHandler = self.useUserAccessGroupHandler {
            try __useUserAccessGroupHandler(userAccessGroup)
        }
    }
    var useUserAccessGroupCallCount: Int = 0
    var useUserAccessGroupHandler: ((_ userAccessGroup: String?) throws -> ())? = nil
}

// MARK: - FirebaseAuthTokenResultProtocol
class FirebaseAuthTokenResultProtocolMock: FirebaseAuthTokenResultProtocol {

    // MARK: - Variables
    var authDate: Date
    var claims: [String: Any] = [:]
    var expirationDate: Date
    var issuedAtDate: Date
    var signInProvider: String = ""
    var token: String = ""

    // MARK: - Initializer
    init(authDate: Date, expirationDate: Date, issuedAtDate: Date) {
        self.authDate = authDate
        self.expirationDate = expirationDate
        self.issuedAtDate = issuedAtDate
    }
}

// MARK: - FirebaseUserInfoProtocol
class FirebaseUserInfoProtocolMock: FirebaseUserInfoProtocol {

    // MARK: - Variables
    var displayName: String? = nil
    var email: String? = nil
    var phoneNumber: String? = nil
    var photoURL: URL? = nil
    var providerID: String = ""
    var uid: String = ""
}

// MARK: - FirebaseUserMetadataProtocol
class FirebaseUserMetadataProtocolMock: FirebaseUserMetadataProtocol {

    // MARK: - Variables
    var creationDate: Date? = nil
    var lastSignInDate: Date? = nil
}

// MARK: - FirebaseUserProtocol
class FirebaseUserProtocolMock: FirebaseUserProtocol {

    // MARK: - Variables
    var displayName: String? = nil
    var email: String? = nil
    var isAnonymous: Bool = false
    var isEmailVerified: Bool = false
    var metadata: FirebaseUserMetadataProtocol
    var phoneNumber: String? = nil
    var photoURL: URL? = nil
    var providerData: [FirebaseUserInfoProtocol] = []
    var providerID: String = ""
    var refreshToken: String? = nil
    var uid: String = ""

    // MARK: - Initializer
    init(metadata: FirebaseUserMetadataProtocol) {
        self.metadata = metadata
    }

    // MARK: - Methods
    func getIDToken(completion: (Result<String, Error>) -> Void) {
        getIDTokenCallCount += 1
        if let __getIDTokenHandler = self.getIDTokenHandler {
            __getIDTokenHandler(completion)
        }
    }
    var getIDTokenCallCount: Int = 0
    var getIDTokenHandler: ((_ completion: (Result<String, Error>) -> Void) -> ())? = nil
    func getIDTokenResult(completion: (Result<FirebaseAuthTokenResultProtocol, Error>) -> Void) {
        getIDTokenResultCallCount += 1
        if let __getIDTokenResultHandler = self.getIDTokenResultHandler {
            __getIDTokenResultHandler(completion)
        }
    }
    var getIDTokenResultCallCount: Int = 0
    var getIDTokenResultHandler: ((_ completion: (Result<FirebaseAuthTokenResultProtocol, Error>) -> Void) -> ())? = nil
    func link(with credential: FirebaseAuthCredentialProtocol, completion: (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) {
        linkCallCount += 1
        if let __linkHandler = self.linkHandler {
            __linkHandler(credential, completion)
        }
    }
    var linkCallCount: Int = 0
    var linkHandler: ((_ credential: FirebaseAuthCredentialProtocol, _ completion: (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) -> ())? = nil
    func reauthenticate(with credential: FirebaseAuthCredentialProtocol, completion: (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) {
        reauthenticateCallCount += 1
        if let __reauthenticateHandler = self.reauthenticateHandler {
            __reauthenticateHandler(credential, completion)
        }
    }
    var reauthenticateCallCount: Int = 0
    var reauthenticateHandler: ((_ credential: FirebaseAuthCredentialProtocol, _ completion: (Result<FirebaseAuthDataResultProtocol, Error>) -> Void) -> ())? = nil
    func reload(completion: (Result<Void, Error>) -> Void) {
        reloadCallCount += 1
        if let __reloadHandler = self.reloadHandler {
            __reloadHandler(completion)
        }
    }
    var reloadCallCount: Int = 0
    var reloadHandler: ((_ completion: (Result<Void, Error>) -> Void) -> ())? = nil
    func sendEmailVerification(completion: (Result<Void, Error>) -> Void) {
        sendEmailVerificationCallCount += 1
        if let __sendEmailVerificationHandler = self.sendEmailVerificationHandler {
            __sendEmailVerificationHandler(completion)
        }
    }
    var sendEmailVerificationCallCount: Int = 0
    var sendEmailVerificationHandler: ((_ completion: (Result<Void, Error>) -> Void) -> ())? = nil
    func unlink(fromProvider provider: String, completion: (Result<FirebaseUserProtocol, Error>) -> Void) {
        unlinkCallCount += 1
        if let __unlinkHandler = self.unlinkHandler {
            __unlinkHandler(provider, completion)
        }
    }
    var unlinkCallCount: Int = 0
    var unlinkHandler: ((_ provider: String, _ completion: (Result<FirebaseUserProtocol, Error>) -> Void) -> ())? = nil
    func updatePassword(to password: String, completion: (Result<Void, Error>) -> Void) {
        updatePasswordCallCount += 1
        if let __updatePasswordHandler = self.updatePasswordHandler {
            __updatePasswordHandler(password, completion)
        }
    }
    var updatePasswordCallCount: Int = 0
    var updatePasswordHandler: ((_ password: String, _ completion: (Result<Void, Error>) -> Void) -> ())? = nil
    func updateUserProfile(displayName: String?, photoURL: URL?, completion: (Result<Void, Error>) -> ()) {
        updateUserProfileCallCount += 1
        if let __updateUserProfileHandler = self.updateUserProfileHandler {
            __updateUserProfileHandler(displayName, photoURL, completion)
        }
    }
    var updateUserProfileCallCount: Int = 0
    var updateUserProfileHandler: ((_ displayName: String?, _ photoURL: URL?, _ completion: (Result<Void, Error>) -> ()) -> ())? = nil
}
