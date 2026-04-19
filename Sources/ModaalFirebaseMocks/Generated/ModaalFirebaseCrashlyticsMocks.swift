// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
@testable import ModaalFirebaseCrashlytics

// MARK: - FirebaseCrashlyticsProtocol
class FirebaseCrashlyticsProtocolMock: FirebaseCrashlyticsProtocol {

    // MARK: - Methods
    func log(_ message: String) {
        logCallCount += 1
        if let __logHandler = self.logHandler {
            __logHandler(message)
        }
    }
    var logCallCount: Int = 0
    var logHandler: ((_ message: String) -> ())? = nil
    func record(error: Error, userInfo: [String: Any]?) {
        recordCallCount += 1
        if let __recordHandler = self.recordHandler {
            __recordHandler(error, userInfo)
        }
    }
    var recordCallCount: Int = 0
    var recordHandler: ((_ error: Error, _ userInfo: [String: Any]?) -> ())? = nil
    func setCustomValue(_ value: Any?, forKey key: String) {
        setCustomValueCallCount += 1
        if let __setCustomValueHandler = self.setCustomValueHandler {
            __setCustomValueHandler(value, key)
        }
    }
    var setCustomValueCallCount: Int = 0
    var setCustomValueHandler: ((_ value: Any?, _ key: String) -> ())? = nil
    func setUserID(_ userID: String?) {
        setUserIDCallCount += 1
        if let __setUserIDHandler = self.setUserIDHandler {
            __setUserIDHandler(userID)
        }
    }
    var setUserIDCallCount: Int = 0
    var setUserIDHandler: ((_ userID: String?) -> ())? = nil
}
