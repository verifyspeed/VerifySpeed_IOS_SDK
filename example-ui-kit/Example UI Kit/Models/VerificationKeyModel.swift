import Foundation

struct VerificationKeyModel: Codable {
    let methodName: String
    let verificationKey: String
    let deepLink: String?
    
    enum CodingKeys: String, CodingKey {
        case methodName = "MethodName"
        case verificationKey
        case deepLink
    }
}
