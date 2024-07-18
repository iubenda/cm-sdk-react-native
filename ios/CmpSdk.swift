import Foundation
import CmpSdk
import React

@objc(ConsentManager)
class ConsentManager: CmpEventEmitter {

    var cmpManager: CmpManager?

    override func supportedEvents() -> [String]! {
        return ["onOpen", "onClose", "onNotOpened", "onError", "onButtonClicked", "onGoogleConsentUpdated"]
    }

    override static func moduleName() -> String! {
        return "Consentmanager"
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc(createInstance:domain:appName:language:)
    func createInstance(_ id: String, domain: String, appName: String, language: String) {
        let config = CmpConfig.shared.setup(withId: id, domain: domain, appName: appName, language: language)
        config.sdkPlatform = "rn"
        DispatchQueue.main.async {
            self.cmpManager = CmpManager(cmpConfig: config)
            self.addEventListeners()
        }
    }

    @objc(createInstanceByConfig:)
    func createInstanceByConfig(_ config: NSDictionary) {
        guard let cmpConfig = CmpConfigManager.setupConfig(from: config) else {
            print("Invalid or incomplete configuration data. 'id', 'domain', 'appName', and 'language' are required.")
            return
        }
        DispatchQueue.main.async {
            self.cmpManager = CmpManager(cmpConfig: cmpConfig)
            self.addEventListeners()
            if let screenConfigString = config["screenConfig"] as? String {
                self.configureConsentLayer(screenConfigString)
            }
            if let presentationStyleString = config["presentationStyle"] as? String {
                self.setPresentationStyle(style: presentationStyleString)
            }
        }
    }

    @objc(importCmpString:resolver:rejecter:)
    func importCmpString(cmpString: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.cmpManager?.importCmpString(cmpString, completion: { success, message in
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
            self.cmpManager?.openConsentLayerOnCheck()
        }
    }

    @objc(getLastATTRequestDate:rejecter:)
    func getLastATTRequestDate(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if let date = self.cmpManager?.getLastATTRequestDate() {
            let timeStamp = date.timeIntervalSince1970
            resolve(timeStamp)
        } else {
            reject("NO_DATE", "Date not available", nil)
        }
    }

    @objc(requestATTPermission)
    func requestATTPermission() {
        if #available(iOS 14, *) {
            self.cmpManager?.requestATTPermission(completion: { status in
                print(status)
            })
        } else {
            print("iOS < 14.0")
        }
    }

    @objc(initializeCmp)
    func initializeCmp() {
        DispatchQueue.main.async {
            self.cmpManager?.initialize()
        }
    }

    @objc(open)
    func open() {
        DispatchQueue.main.async {
            self.cmpManager?.openConsentLayer()
        }
    }

    @objc(hasVendor:defaultReturn:resolver:rejecter:)
    func hasVendor(id: String, defaultReturn: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let hasVendor = cmpManager?.hasVendor(id, defaultReturn: defaultReturn)
        resolve(hasVendor)
    }

    @objc(hasPurpose:defaultReturn:resolver:rejecter:)
    func hasPurpose(id: String, defaultReturn: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let hasPurpose = cmpManager?.hasPurpose(id, defaultReturn: defaultReturn)
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

    @objc(hasConsent:rejecter:)
    func hasConsent(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let hasConsent = cmpManager?.hasConsent()
        resolve(hasConsent)
    }

    @objc(getAllVendors:rejecter:)
    func getAllVendors(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let list = cmpManager?.getAllVendorList()
        resolve(list)
    }

    @objc(getAllPurposes:rejecter:)
    func getAllPurposes(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let list = cmpManager?.getAllPurposesList()
        resolve(list)
    }

    @objc(getEnabledVendors:rejecter:)
    func getEnabledVendors(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let list = cmpManager?.getEnabledVendorList()
        resolve(list)
    }

    @objc(getEnabledPurposes:rejecter:)
    func getEnabledPurposes(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let list = cmpManager?.getEnabledPurposeList()
        resolve(list)
    }

    @objc(getDisabledVendors:rejecter:)
    func getDisabledVendors(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let list = cmpManager?.getDisabledVendorList()
        resolve(list)
    }

    @objc(getDisabledPurposes:rejecter:)
    func getDisabledPurposes(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let list = cmpManager?.getDisabledPurposeList()
        resolve(list)
    }

    @objc(getUSPrivacyString:rejecter:)
    func getUSPrivacyString(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let usPrivacyString = cmpManager?.getUSPrivacyString()
        resolve(usPrivacyString)
    }

    @objc(getGoogleACString:rejecter:)
    func getGoogleACString(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let googleAC = cmpManager?.getGoogleACString()
        resolve(googleAC)
    }

    @objc(configureConsentLayer:)
    func configureConsentLayer(_ screenConfig: String) {
        guard let config = ScreenConfig(fromString: screenConfig) else {
            print("Invalid screen configuration: \(screenConfig)")
            return
        }

        configureScreen(config)
    }

    @objc(configurePresentationStyle:resolver:rejecter:)
    func configurePresentationStyle(_ style: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard let consentManager = cmpManager else {
            reject("ERROR", "ConsentManager is not initialized", nil)
            return
        }

        consentManager.withCmpViewControllerConfigurationBlock { viewController in
            guard let style = PresentationStyle(rawValue: style) else {
                reject("ERROR", "Invalid presentation style", nil)
                return
            }
            viewController?.modalPresentationStyle = style.toUIModalPresentationStyle()
            resolve(nil)
        }
    }

    private func setPresentationStyle(style: String) {
        cmpManager?.withCmpViewControllerConfigurationBlock { viewController in
            guard let style = PresentationStyle(rawValue: style) else {
                return
            }
            viewController?.modalPresentationStyle = style.toUIModalPresentationStyle()
        }
    }

    private func configureScreen(_ config: ScreenConfig) {
        cmpManager?.withCmpViewConfigurationBlock({ uiView in
            guard let uiView = uiView, let superview = uiView.superview else { return }
            uiView.translatesAutoresizingMaskIntoConstraints = false
            switch config {
            case .fullScreen:
                NSLayoutConstraint.activate([
                    uiView.topAnchor.constraint(equalTo: superview.topAnchor),
                    uiView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    uiView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    uiView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            case .halfScreenBottom:
                NSLayoutConstraint.activate([
                    uiView.heightAnchor.constraint(equalToConstant: superview.frame.size.height / 2),
                    uiView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    uiView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    uiView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            case .halfScreenTop:
                NSLayoutConstraint.activate([
                    uiView.heightAnchor.constraint(equalToConstant: superview.frame.size.height / 2),
                    uiView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    uiView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    uiView.topAnchor.constraint(equalTo: superview.topAnchor)
                ])
            case .centerScreen:
                NSLayoutConstraint.activate([
                    uiView.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.9),
                    uiView.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.8),
                    uiView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                    uiView.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
                ])
            case .smallCenterScreen:
                NSLayoutConstraint.activate([
                    uiView.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.8),
                    uiView.heightAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.4),
                    uiView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                    uiView.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
                ])
            case .largeTopScreen:
                NSLayoutConstraint.activate([
                    uiView.topAnchor.constraint(equalTo: superview.topAnchor),
                    uiView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    uiView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    uiView.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.75)
                ])
            case .largeBottomScreen:
                NSLayoutConstraint.activate([
                    uiView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                    uiView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    uiView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    uiView.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.75)
                ])
            }
        })
    }
}
