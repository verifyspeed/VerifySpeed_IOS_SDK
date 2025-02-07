import Foundation

enum Screen: Hashable {
    case methods
    case message(method: String)
    case phoneNumber(method: String)
    case otp(verificationKey: String)
    
    var title: String {
        switch self {
        case .methods:
            return "Methods"
        case .message:
            return "Message"
        case .phoneNumber:
            return "Phone Number"
        case .otp:
            return "OTP Verification"
        }
    }
} 
