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
        // Configure CMPConfig here
        DispatchQueue.main.async {
            // It is crucial that all UI related code be called on the main thread
             self.consentManager = CMPConsentTool
            // self.setCallbacks()
        }
    }

    @objc(initialize)
    func initialize() {
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
    @objc func setCallbacks() {
        // Setup your consent manager callbacks here
        consentManager?.openListener = { [weak self] in
            self?.sendEvent(withName: "onOpen", body: nil)
        }
        consentManager?.closeListener = { [weak self] in
            self?.sendEvent(withName: "onClose", body: nil)
        }
        consentManager?.onCMPNotOpenedListener = { [weak self] in
            self?.sendEvent(withName: "onNotOpened", body: nil)
        }
        consentManager?.errorListener = { [weak self] type, message in
            let typeString : String = self?.stringFromErrorType(type: type) ?? "unknownError"
            let errorInfo: [String: Any] = ["type": typeString, "message": message ?? "unknown Error"]
            self?.sendEvent(withName: "onError", body: errorInfo)
        }
        consentManager?.onCmpButtonClickedCallback = { [weak self] type in
            let typeString : String = self?.stringFromCmpButtonEvent(type: type) ?? "unknown"
            let buttonInfo: [String: Any] = ["buttonType": typeString]
            self?.sendEvent(withName: "onButtonClicked", body: buttonInfo)
        }
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
