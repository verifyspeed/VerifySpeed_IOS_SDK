import Foundation

class OtpViewModel {
    private(set) var otpCode = ""
    private(set) var isLoading = false
    private(set) var phoneNumber: String?
    
    private let verifySpeedService = VerifySpeedService()
    
    // Callbacks for UI updates
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String?) -> Void)?
    
    func setOtpCode(_ code: String) {
        otpCode = code
    }
    
    @MainActor
    func validateOtp(verificationKey: String) async {
        isLoading = true
        onLoadingChanged?(true)
        
        do {
            let token = try await verifySpeedService.validateOtp(
                otpCode: otpCode,
                verificationKey: verificationKey
            )
            
            // Start loading phone number
            do {
                let number = try await verifySpeedService.getPhoneNumber(token: token)
                phoneNumber = number
                onSuccess?(number)
            } catch {
                onError?("Failed to get phone number: \(error.localizedDescription)")
            }
        } catch {
            onError?(error.localizedDescription)
        }
        
        isLoading = false
        onLoadingChanged?(false)
    }
} 
