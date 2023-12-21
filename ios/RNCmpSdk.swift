// Ensure you import the necessary React modules
import Foundation
import CmpSdk
import React

@objc(Consentmanager)
class Consentmanager: RCTEventEmitter {

    var consentManager: CMPConsentTool?

    override func supportedEvents() -> [String]! {
        return ["onOpen", "onClose", "onNotOpened", "onError", "onButtonClicked"]
    }

    override static func moduleName() -> String! {
        return "Consentmanager"
    }

    @objc(createInstance:domain:appName:language:)
    func createInstance(_ id: String, domain: String, appName: String, language: String) {
       let config = CmpConfig.shared .setup(withId: id, domain: domain, appName: appName, language: language)
        // Configure CMPConfig here
        DispatchQueue.main.async {
            self.consentManager = CMPConsentTool.init(cmpConfig: config)
            self.setCallbacks()
        }
    }

    @objc(createInstanceByConfig:)
    func createInstanceByConfig(_ config: NSDictionary) {
        guard let id = config["id"] as? String,
              let domain = config["domain"] as? String,
              let appName = config["appName"] as? String,
              let language = config["language"] as? String else {
            print("Invalid or incomplete configuration data. 'id', 'domain', 'appName', and 'language' are required.")
            return
        }

        let cmpConfig = CmpConfig.shared
        cmpConfig.setup(withId: id, domain: domain, appName: appName, language: language)


        if let timeout = config["timeout"] as? NSNumber {
            cmpConfig.timeout = timeout.intValue // Assuming 'timeout' is an Int in your CmpConfig
        }
        // Optional values
        if let idfaOrGaid = config["idfaOrGaid"] as? String {
            cmpConfig.idfa = idfaOrGaid
        }
        if let jumpToSettingsPage = config["jumpToSettingsPage"] as? Bool {
            cmpConfig.isJumpToSettingsPage = jumpToSettingsPage
        }
        if let designId = config["designId"] as? String {
            cmpConfig.designId = designId
        }
        if let isDebugMode = config["isDebugMode"] as? Bool {
            cmpConfig.isDebugMode = isDebugMode
            cmpConfig.logLevel = CmpLogLevel.verbose
        }
        if let isAutomaticATTrackingRequest = config["isAutomaticATTrackingRequest"] as? Bool {
            cmpConfig.isAutomaticATTRequest = isAutomaticATTrackingRequest
        }
        DispatchQueue.main.async {
            self.consentManager = CMPConsentTool.init(cmpConfig: cmpConfig)
            self.setCallbacks()
        }
    }

    @objc(importCmpString:resolver:rejecter:)
    func importCmpString(cmpString: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.consentManager?.importCmpString(cmpString, completion: { success, message in
                if success {
                    let payload: [String: Any] = ["success": success, "message": message ?? "No message"]
                    resolver(payload)
                } else {
                    let error = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: message ?? "No Message"])
                    rejecter("E_IMPORT_FAILED", message, error)
                }

            })
        }
      }

    @objc(openConsentLayerOnCheck)
    func openConsentLayerOnCheck() {
        DispatchQueue.main.async {
            self.consentManager?.checkAndOpenConsentLayer()
        }
    }

    @objc(getLastATTRequestDate:rejecter:)
    func getLastATTRequestDate(_ resolve: @escaping RCTPromiseResolveBlock,
                               rejecter reject: @escaping RCTPromiseRejectBlock) {
        if let date = self.consentManager?.getLastATTRequestDate() {
            // Convert Date to TimeInterval (timestamp) and then to Double
            let timeStamp = date.timeIntervalSince1970
            resolve(timeStamp)
        } else {
            // Handle the case where date is nil
            reject("NO_DATE", "Date not available", nil)
        }
    }

    @objc(requestATTPermission)
    func requestATTPermission() {
        if #available(iOS 14, *) {
            self.consentManager?.requestATTPermission(completion: { status in
                print(status)
            })
        } else {
            print("iOS < 14.0")
        }
    }

    @objc(initializeCmp)
    func initializeCmp() {
        DispatchQueue.main.async {
            self.consentManager?.initialize()
        }
    }

    @objc(open)
    func open() {
        DispatchQueue.main.async {
            self.consentManager?.openView()
        }
    }

    @objc(setCallbacks)
    func setCallbacks() {
        // Setup your consent manager callbacks here
        consentManager?.withOpenListener(
            {
                self.sendEvent(withName: "onOpen", body: nil)
            }
        )
        consentManager?.withCloseListener(
            { self.sendEvent(withName: "onClose", body: nil)
            }
        )
        consentManager?.withOnCMPNotOpenedListener(
            {
                self.sendEvent(withName: "onNotOpened", body: nil)
            }
        )
        consentManager?.withErrorListener(
            { type, message in
                let typeString : String = self.stringFromErrorType(type: type)
                let errorInfo: [String: Any] = ["type": typeString, "message": message ?? "unknown Error"]
                self.sendEvent(withName: "onError", body: errorInfo)
            })
        consentManager?.withOnCmpButtonClickedCallback({ type in
            let typeString : String = self.stringFromCmpButtonEvent(type: type)
            let buttonInfo: [String: Any] = ["buttonType": typeString]
            self.sendEvent(withName: "onButtonClicked", body: buttonInfo)
        })
    }

    @objc(hasVendor:resolver:rejecter:)
    func hasVendor(id: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let hasVendor = consentManager?.hasVendorConsent(id)
        resolve(hasVendor)
    }

    @objc(hasPurpose:resolver:rejecter:)
    func hasPurpose(id: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let hasPurpose = consentManager?.hasPurposeConsent(id)
        resolve(hasPurpose)
    }

    @objc(reset)
    func reset() {
        CMPConsentTool.reset()
    }

    @objc(exportCmpString:rejecter:)
    func exportCmpString(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let cmpString = CMPConsentTool.exportCmpString()
        resolve(cmpString)
    }

    //pragma mark Getter

    @objc(hasConsent:rejecter:)
    func hasConsent(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let hasConsent = consentManager?.hasConsent()
        resolve(hasConsent)
    }

    @objc(getAllVendors:rejecter:)
    func getAllVendors(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let list = consentManager?.getAllVendorList()
        resolve(list)
    }

    @objc(getAllPurposes:rejecter:)
    func getAllPurposes(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let list = consentManager?.getAllPurposesList()
        resolve(list)
    }

    @objc(getEnabledVendors:rejecter:)
    func getEnabledVendors(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let list = consentManager?.getEnabledVendorList()
        resolve(list)
    }

    @objc(getEnabledPurposes:rejecter:)
    func getEnabledPurposes(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let list = consentManager?.getEnabledPurposeList()
        resolve(list)
    }

    @objc(getDisabledVendors:rejecter:)
    func getDisabledVendors(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let list = consentManager?.getDisabledVendorList()
        resolve(list)
    }

    @objc(getDisabledPurposes:rejecter:)
    func getDisabledPurposes(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let list = consentManager?.getDisabledPurposeList()
        resolve(list)
    }

    @objc(getUSPrivacyString:rejecter:)
    func getUSPrivacyString(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let usPrivacyString = consentManager?.getUSPrivacyString()
        resolve(usPrivacyString)
    }


    @objc(getGoogleACString:rejecter:)
    func getGoogleACString(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let googleAC = consentManager?.getGoogleACString()
        resolve(googleAC)
    }


    // This method is required to be exported by React Native
    @objc
    override static func requiresMainQueueSetup() -> Bool {
      return true
    }

    private func stringFromCmpButtonEvent(type: CmpButtonEvent) -> String {
        switch type {
        case .unknown:
            return "unknown"
        case .acceptAll:
            return "acceptAll"
        case .rejectAll:
            return "rejectAll"
        case .save:
            return "save"
        case .close:
            return "close"
        @unknown default:
            return "unknown"
        }
    }

    private func stringFromErrorType(type: CmpErrorType) -> String {
        switch type {
        case .consentDataReadWriteError:
            return "consentDataReadWriteError"
        case .networkError:
            return "networkError"
        case .timeoutError:
            return "timeoutError"
        case .unknownError:
            return "unknownError"
        @unknown default:
            return "unkonwnError"
        }
    }
}
