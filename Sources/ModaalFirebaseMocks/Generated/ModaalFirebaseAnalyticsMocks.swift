// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
@testable import ModaalFirebaseAnalytics

// MARK: - FirebaseAnalyticsProtocol
class FirebaseAnalyticsProtocolMock: FirebaseAnalyticsProtocol {

    // MARK: - Methods
    func logEvent(name: String, parameters: [String: Any]?) {
        logEventCallCount += 1
        if let __logEventHandler = self.logEventHandler {
            __logEventHandler(name, parameters)
        }
    }
    var logEventCallCount: Int = 0
    var logEventHandler: ((_ name: String, _ parameters: [String: Any]?) -> ())? = nil
    func resetAnalyticsData() {
        resetAnalyticsDataCallCount += 1
        if let __resetAnalyticsDataHandler = self.resetAnalyticsDataHandler {
            __resetAnalyticsDataHandler()
        }
    }
    var resetAnalyticsDataCallCount: Int = 0
    var resetAnalyticsDataHandler: (() -> ())? = nil
    func setAnalyticsCollectionEnabled(_ enabled: Bool) {
        setAnalyticsCollectionEnabledCallCount += 1
        if let __setAnalyticsCollectionEnabledHandler = self.setAnalyticsCollectionEnabledHandler {
            __setAnalyticsCollectionEnabledHandler(enabled)
        }
    }
    var setAnalyticsCollectionEnabledCallCount: Int = 0
    var setAnalyticsCollectionEnabledHandler: ((_ enabled: Bool) -> ())? = nil
    func setUserID(_ userID: String?) {
        setUserIDCallCount += 1
        if let __setUserIDHandler = self.setUserIDHandler {
            __setUserIDHandler(userID)
        }
    }
    var setUserIDCallCount: Int = 0
    var setUserIDHandler: ((_ userID: String?) -> ())? = nil
    func setUserProperty(_ value: String?, forName name: String) {
        setUserPropertyCallCount += 1
        if let __setUserPropertyHandler = self.setUserPropertyHandler {
            __setUserPropertyHandler(value, name)
        }
    }
    var setUserPropertyCallCount: Int = 0
    var setUserPropertyHandler: ((_ value: String?, _ name: String) -> ())? = nil
}
