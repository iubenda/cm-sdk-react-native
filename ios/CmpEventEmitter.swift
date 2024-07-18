import Foundation
import React
import CmpSdk

class CmpEventEmitter: RCTEventEmitter {
    var cmpManager: CmpManager?

    override func supportedEvents() -> [String]! {
        return ["onOpen", "onClose", "onNotOpened", "onError", "onButtonClicked", "onGoogleConsentUpdated"]
    }

    func addEventListeners() {
        cmpManager?.withOpenListener {
            self.sendEvent(withName: "onOpen", body: nil)
        }
        cmpManager?.withCloseListener {
            self.sendEvent(withName: "onClose", body: nil)
        }
        cmpManager?.withOnCMPNotOpenedListener {
            self.sendEvent(withName: "onNotOpened", body: nil)
        }
        cmpManager?.withErrorListener { type, message in
            let typeString = self.stringFromErrorType(type: type)
            let errorInfo: [String: Any] = ["type": typeString, "message": message ?? "unknown Error"]
            self.sendEvent(withName: "onError", body: errorInfo)
        }
        cmpManager?.withOnCmpButtonClickedCallback { type in
            let typeString = self.stringFromCmpButtonEvent(type: type)
            let buttonInfo: [String: Any] = ["buttonType": typeString]
            self.sendEvent(withName: "onButtonClicked", body: buttonInfo)
        }
        cmpManager?.withUpdateGoogleConsent { [weak self] consentMap in
            guard let self = self, let consentMap = consentMap else { return }
            let body: [String: Any] = ["consentMap": consentMap]
            self.sendEvent(withName: "onGoogleConsentUpdated", body: body)
        }
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
}
