// Ensure you import the necessary React modules
import Foundation
import CmpSdk
import React

@objc(Consentmanager)
class Consentmanager: RCTEventEmitter {

    var consentManager: CmpManager?

    override func supportedEvents() -> [String]! {
        return ["onOpen", "onClose", "onNotOpened", "onError", "onButtonClicked"]
    }

    override static func moduleName() -> String! {
        return "Consentmanager"
    }

    @objc(createInstance:domain:appName:language:)
    func createInstance(_ id: String, domain: String, appName: String, language: String) {
        let config = CmpConfig.shared .setup(withId: id, domain: domain, appName: appName, language: language)
        config.sdkPlatform = "rn"
        // Configure CMPConfig here
        DispatchQueue.main.async {
            self.consentManager = CmpManager.init(cmpConfig: config)
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
        cmpConfig.sdkPlatform = "rn"

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
        if let isDebugMode = config["isDebugMode"] as? Bool {
            cmpConfig.isDebugMode = isDebugMode
            cmpConfig.logLevel = CmpLogLevel.verbose
        }
        if let isAutomaticATTrackingRequest = config["isAutomaticATTrackingRequest"] as? Bool {
            cmpConfig.isAutomaticATTRequest = isAutomaticATTrackingRequest
        }
        DispatchQueue.main.async {
            self.consentManager = CmpManager.init(cmpConfig: cmpConfig)
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
            self.consentManager?.openConsentLayerOnCheck()
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
            self.consentManager?.openConsentLayer()
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

    @objc(hasVendor:defaultReturn:resolver:rejecter:)
    func hasVendor(id: String, defaultReturn: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let hasVendor = consentManager?.hasVendor(id, defaultReturn: defaultReturn)
        resolve(hasVendor)
    }

    @objc(hasPurpose:defaultReturn:resolver:rejecter:)
    func hasPurpose(id: String, defaultReturn: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let hasPurpose = consentManager?.hasPurpose(id, defaultReturn: defaultReturn)
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

    @objc(configureConsentLayer:)
    func configureConsentLayer(_ screenConfig: String) {
        guard let config = ScreenConfig(fromString: screenConfig) else {
            print("Invalid screen configuration: \(screenConfig)")
            return
        }

        switch config {
        case .fullScreen:
            configureFullScreen()
        case .halfScreenBottom:
            configureHalfScreenBottom()
        case .halfScreenTop:
            configureHalfScreenTop()
        case .centerScreen:
            configureCenterScreen()
        case .smallCenterScreen:
            configureSmallCenterScreen()
        case .largeTopScreen:
            configureLargeTopScreen()
        case .largeBottomScreen:
            configureLargeBottomScreen()
        }
    }

    @objc(configurePresentationStyle:resolver:rejecter:)
    func configurePresentationStyle(_ style: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard let consentManager = consentManager else {
            reject("ERROR", "ConsentManager is not initialized", nil)
            return
        }

        consentManager.withCmpViewControllerConfigurationBlock { viewController in
            switch style {
            case "fullScreen":
                viewController?.modalPresentationStyle = .fullScreen
            case "pageSheet":
                viewController?.modalPresentationStyle = .pageSheet
            case "formSheet":
                viewController?.modalPresentationStyle = .formSheet
            case "currentContext":
                viewController?.modalPresentationStyle = .currentContext
            case "overFullScreen":
                viewController?.modalPresentationStyle = .overFullScreen
            case "overCurrentContext":
                viewController?.modalPresentationStyle = .overCurrentContext
            case "popover":
                viewController?.modalPresentationStyle = .popover
            case "none":
                viewController?.modalPresentationStyle = .none
            default:
                reject("ERROR", "Invalid presentation style", nil)
                return
            }
            resolve(nil)
        }
    }


    private func configureFullScreen() {
        consentManager?.withCmpViewControllerConfigurationBlock({ viewController in
            viewController?.modalPresentationStyle = .fullScreen
        })
    }

    private func configureHalfScreenBottom()  {
        consentManager?.withCmpViewConfigurationBlock({ uiView in
            guard let uiView = uiView, let superview = uiView.superview else { return }
            uiView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                uiView.heightAnchor.constraint(equalToConstant: superview.frame.size.height / 2),
                uiView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                uiView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                uiView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        })
    }

    private func configureHalfScreenTop() {
        consentManager?.withCmpViewConfigurationBlock({ uiView in
            guard let uiView = uiView, let superview = uiView.superview else { return }
            uiView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                uiView.heightAnchor.constraint(equalToConstant: superview.frame.size.height / 2),
                uiView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                uiView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                uiView.topAnchor.constraint(equalTo: superview.topAnchor)
            ])
        })
    }

    private func configureCenterScreen(widthRatio: CGFloat = 0.9, heightRatio: CGFloat = 0.8) {
        consentManager?.withCmpViewConfigurationBlock({ uiView in
            guard let uiView = uiView, let superview = uiView.superview else { return }
            uiView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                uiView.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: widthRatio),
                uiView.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: heightRatio),
                uiView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                uiView.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            ])
        })
    }

    private func configureSmallCenterScreen() {
        consentManager?.withCmpViewConfigurationBlock({ uiView in
            guard let uiView = uiView, let superview = uiView.superview else { return }
            let widthRatio: CGFloat = 0.8
            let heightRatio: CGFloat = 0.4 // Assuming a smaller height for "small"
            uiView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                uiView.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: widthRatio),
                uiView.heightAnchor.constraint(equalTo: superview.widthAnchor, multiplier: heightRatio), // Height relative to the width of the superview for consistent aspect ratio
                uiView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                uiView.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            ])
        })
    }

    private func configureLargeTopScreen() {
        consentManager?.withCmpViewConfigurationBlock({ uiView in
            guard let uiView = uiView, let superview = uiView.superview else { return }
            uiView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                uiView.topAnchor.constraint(equalTo: superview.topAnchor),
                uiView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                uiView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                uiView.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.75) // 75% of the superview's height
            ])
        })
    }

    private func configureLargeBottomScreen() {
        consentManager?.withCmpViewConfigurationBlock({ uiView in
            guard let uiView = uiView, let superview = uiView.superview else { return }
            uiView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                uiView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                uiView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                uiView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                uiView.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.75) // 75% of the superview's height
            ])
        })
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
            return "unknownError"
        }
    }

    @objc enum ScreenConfig: Int, CaseIterable {
        case fullScreen
        case halfScreenBottom
        case halfScreenTop
        case centerScreen
        case smallCenterScreen
        case largeTopScreen
        case largeBottomScreen

        init?(fromString: String) {
            switch fromString {
            case "FullScreen":
                self = .fullScreen
            case "HalfScreenBottom":
                self = .halfScreenBottom
            case "HalfScreenTop":
                self = .halfScreenTop
            case "CenterScreen":
                self = .centerScreen
            case "SmallCenterScreen":
                self = .smallCenterScreen
            case "LargeTopScreen":
                self = .largeTopScreen
            case "LargeBottomScreen":
                self = .largeBottomScreen
            default:
                return nil
            }
        }
    }
}
