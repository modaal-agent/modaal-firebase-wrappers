// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
@testable import ModaalFirebaseRemoteConfig

// MARK: - FirebaseRemoteConfigProtocol
class FirebaseRemoteConfigProtocolMock: FirebaseRemoteConfigProtocol {

    // MARK: - Variables
    var lastFetchStatus: ModaalRemoteConfigFetchStatus
    var lastFetchTime: Date? = nil
    var minimumFetchInterval: TimeInterval = 0.0 {
        didSet {
            minimumFetchIntervalSetCount += 1
        }
    }
    var minimumFetchIntervalSetCount: Int = 0

    // MARK: - Initializer
    init(lastFetchStatus: ModaalRemoteConfigFetchStatus) {
        self.lastFetchStatus = lastFetchStatus
    }

    // MARK: - Methods
    func activate(completion: @escaping (Result<Bool, Error>) -> Void) {
        activateCallCount += 1
        if let __activateHandler = self.activateHandler {
            __activateHandler(completion)
        }
    }
    var activateCallCount: Int = 0
    var activateHandler: ((_ completion: @escaping (Result<Bool, Error>) -> Void) -> ())? = nil
    func addOnConfigUpdateListener(_ listener: @escaping (Result<RemoteConfigUpdateProtocol, Error>) -> Void) -> RemoteConfigListenerRegistration {
        addOnConfigUpdateListenerCallCount += 1
        if let __addOnConfigUpdateListenerHandler = self.addOnConfigUpdateListenerHandler {
            return __addOnConfigUpdateListenerHandler(listener)
        }
        fatalError("addOnConfigUpdateListenerHandler expected to be set.")
    }
    var addOnConfigUpdateListenerCallCount: Int = 0
    var addOnConfigUpdateListenerHandler: ((_ listener: @escaping (Result<RemoteConfigUpdateProtocol, Error>) -> Void) -> (RemoteConfigListenerRegistration))? = nil
    func allKeys(from source: ModaalRemoteConfigSource) -> [String] {
        allKeysCallCount += 1
        if let __allKeysHandler = self.allKeysHandler {
            return __allKeysHandler(source)
        }
        return []
    }
    var allKeysCallCount: Int = 0
    var allKeysHandler: ((_ source: ModaalRemoteConfigSource) -> ([String]))? = nil
    func configValue(forKey key: String) -> RemoteConfigValueProtocol {
        configValueCallCount += 1
        if let __configValueHandler = self.configValueHandler {
            return __configValueHandler(key)
        }
        fatalError("configValueHandler expected to be set.")
    }
    var configValueCallCount: Int = 0
    var configValueHandler: ((_ key: String) -> (RemoteConfigValueProtocol))? = nil
    func fetch(completionHandler: @escaping (Result<ModaalRemoteConfigFetchStatus, Error>) -> Void) {
        fetchCallCount += 1
        if let __fetchHandler = self.fetchHandler {
            __fetchHandler(completionHandler)
        }
    }
    var fetchCallCount: Int = 0
    var fetchHandler: ((_ completionHandler: @escaping (Result<ModaalRemoteConfigFetchStatus, Error>) -> Void) -> ())? = nil
    func fetchAndActivate(completionHandler: @escaping (Result<ModaalRemoteConfigFetchAndActivateStatus, Error>) -> Void) {
        fetchAndActivateCallCount += 1
        if let __fetchAndActivateHandler = self.fetchAndActivateHandler {
            __fetchAndActivateHandler(completionHandler)
        }
    }
    var fetchAndActivateCallCount: Int = 0
    var fetchAndActivateHandler: ((_ completionHandler: @escaping (Result<ModaalRemoteConfigFetchAndActivateStatus, Error>) -> Void) -> ())? = nil
    func setDefaults(_ defaults: [String: NSObject]?) {
        setDefaultsCallCount += 1
        if let __setDefaultsHandler = self.setDefaultsHandler {
            __setDefaultsHandler(defaults)
        }
    }
    var setDefaultsCallCount: Int = 0
    var setDefaultsHandler: ((_ defaults: [String: NSObject]?) -> ())? = nil
}

// MARK: - RemoteConfigListenerRegistration
class RemoteConfigListenerRegistrationMock: RemoteConfigListenerRegistration {

    // MARK: - Methods
    func remove() {
        removeCallCount += 1
        if let __removeHandler = self.removeHandler {
            __removeHandler()
        }
    }
    var removeCallCount: Int = 0
    var removeHandler: (() -> ())? = nil
}

// MARK: - RemoteConfigUpdateProtocol
class RemoteConfigUpdateProtocolMock: RemoteConfigUpdateProtocol {

    // MARK: - Variables
    var updatedKeys: Set<String> = Set()
}

// MARK: - RemoteConfigValueProtocol
class RemoteConfigValueProtocolMock: RemoteConfigValueProtocol {

    // MARK: - Variables
    var boolValue: Bool = false
    var dataValue: Data
    var jsonValue: Any? = nil
    var numberValue: NSNumber
    var source: ModaalRemoteConfigSource
    var stringValue: String = ""

    // MARK: - Initializer
    init(dataValue: Data, numberValue: NSNumber, source: ModaalRemoteConfigSource) {
        self.dataValue = dataValue
        self.numberValue = numberValue
        self.source = source
    }
}
