import Foundation
import CmpSdk

class CmpConfigManager {
    static func setupConfig(from config: NSDictionary) -> CmpConfig {
        let cmpConfig = CmpConfig.shared
        guard let id = config["id"] as? String,
              let domain = config["domain"] as? String,
              let appName = config["appName"] as? String,
              let language = config["language"] as? String else {
            fatalError("Invalid or incomplete configuration data. 'id', 'domain', 'appName', and 'language' are required.")
        }

        cmpConfig.setup(withId: id, domain: domain, appName: appName, language: language)
        cmpConfig.sdkPlatform = "rn"

        if let timeout = config["timeout"] as? NSNumber {
            cmpConfig.timeout = timeout.intValue
        }
        if let idfaOrGaid = config["idfaOrGaid"] as? String {
            cmpConfig.idfa = idfaOrGaid
        }
        if let jumpToSettingsPage = config["jumpToSettingsPage"] as? Bool {
            cmpConfig.isJumpToSettingsPage = jumpToSettingsPage
        }
        if let isDebugMode = config["isDebugMode"] as? Bool {
            cmpConfig.isDebugMode = isDebugMode
            cmpConfig.logLevel = .verbose
        }
        if let isAutomaticATTrackingRequest = config["isAutomaticATTrackingRequest"] as? Bool {
            cmpConfig.isAutomaticATTRequest = isAutomaticATTrackingRequest
        }

        return cmpConfig
    }
}
