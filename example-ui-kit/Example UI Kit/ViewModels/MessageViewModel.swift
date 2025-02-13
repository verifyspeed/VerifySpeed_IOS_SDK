import Foundation
import VerifySpeed_IOS

class MessageViewModel {
    private(set) var isLoading = false
    private(set) var phoneNumber: String?
    
    private let verifySpeedService = VerifySpeedService()
    
    // Callbacks for UI updates
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String?) -> Void)?
    
    @MainActor
    func verifyWithMessage(method: String) async {
        isLoading = true
        onLoadingChanged?(true)
        
        do {
            let verificationKeyModel = try await verifySpeedService.getVerificationKey(methodName: method)
            let listener = VerifySpeedListenerHandler()
            
            // Create a continuation to wait for the callback
            try await withCheckedThrowingContinuation { continuation in
                listener.onSuccess = { [weak self] token in
                    Task { [weak self] in
                        guard let self = self else { return }
                        do {
                            let number = try await self.verifySpeedService.getPhoneNumber(token: token)
                            await MainActor.run {
                                self.phoneNumber = number
                                self.onSuccess?(number)
                            }
                            continuation.resume()
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                }
                
                listener.onFailure = { error in
                    continuation.resume(throwing: error)
                }
                
                //* TIP: Verify phone number with Deep Link
                VerifySpeed.shared.verifyPhoneNumberWithDeepLink(
                    deeplink: verificationKeyModel.deepLink ?? "",
                    verificationKey: verificationKeyModel.verificationKey,
                    callBackListener: listener
                )
            }
        } catch {
            await MainActor.run {
                self.onError?(error.localizedDescription)
            }
        }
        
        await MainActor.run {
            isLoading = false
            onLoadingChanged?(false)
        }
    }
}
