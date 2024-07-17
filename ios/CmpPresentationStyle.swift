import UIKit

enum CmpPresentationStyle: String {
    case fullScreen
    case pageSheet
    case formSheet
    case currentContext
    case overFullScreen
    case overCurrentContext
    case popover
    case none

    func toUIModalPresentationStyle() -> UIModalPresentationStyle {
        switch self {
        case .fullScreen:
            return .fullScreen
        case .pageSheet:
            return .pageSheet
        case .formSheet:
            return .formSheet
        case .currentContext:
            return .currentContext
        case .overFullScreen:
            return .overFullScreen
        case .overCurrentContext:
            return .overCurrentContext
        case .popover:
            return .popover
        case .none:
            return .none
        }
    }
}
