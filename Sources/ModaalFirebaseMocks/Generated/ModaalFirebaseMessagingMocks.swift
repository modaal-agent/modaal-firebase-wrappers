// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
@testable import ModaalFirebaseMessaging

// MARK: - FirebaseMessagingProtocol
class FirebaseMessagingProtocolMock: FirebaseMessagingProtocol {

    // MARK: - Variables
    var apnsToken: Data? = nil {
        didSet {
            apnsTokenSetCount += 1
        }
    }
    var apnsTokenSetCount: Int = 0
    var fcmToken: String? = nil
    var isAutoInitEnabled: Bool = false {
        didSet {
            isAutoInitEnabledSetCount += 1
        }
    }
    var isAutoInitEnabledSetCount: Int = 0

    // MARK: - Methods
    func deleteToken(completion: @escaping (Result<Void, Error>) -> Void) {
        deleteTokenCallCount += 1
        if let __deleteTokenHandler = self.deleteTokenHandler {
            __deleteTokenHandler(completion)
        }
    }
    var deleteTokenCallCount: Int = 0
    var deleteTokenHandler: ((_ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
    func subscribe(toTopic topic: String, completion: @escaping (Result<Void, Error>) -> Void) {
        subscribeCallCount += 1
        if let __subscribeHandler = self.subscribeHandler {
            __subscribeHandler(topic, completion)
        }
    }
    var subscribeCallCount: Int = 0
    var subscribeHandler: ((_ topic: String, _ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
    func token(completion: @escaping (Result<String, Error>) -> Void) {
        tokenCallCount += 1
        if let __tokenHandler = self.tokenHandler {
            __tokenHandler(completion)
        }
    }
    var tokenCallCount: Int = 0
    var tokenHandler: ((_ completion: @escaping (Result<String, Error>) -> Void) -> ())? = nil
    func unsubscribe(fromTopic topic: String, completion: @escaping (Result<Void, Error>) -> Void) {
        unsubscribeCallCount += 1
        if let __unsubscribeHandler = self.unsubscribeHandler {
            __unsubscribeHandler(topic, completion)
        }
    }
    var unsubscribeCallCount: Int = 0
    var unsubscribeHandler: ((_ topic: String, _ completion: @escaping (Result<Void, Error>) -> Void) -> ())? = nil
}
