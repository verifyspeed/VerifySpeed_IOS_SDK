import Foundation
import VerifySpeed_IOS

@MainActor
class MessageViewModel: ObservableObject {
    private let verifySpeedService = VerifySpeedService()
    
    @Published var isLoading = false
    @Published var error: String?
    @Published var phoneNumber: String?
    @Published var showSuccessDialog = false
    
    func verifyWithMessage(method: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await verifySpeedService.getVerificationKey(methodName: method)
            let listener = VerifySpeedListenerHandler()
            
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                listener.onSuccess = { token in
                    Task {
                        await self.showPhoneNumberDialog(token: token)
                        continuation.resume()
                    }
                }
                
                listener.onFailure = { error in
                    self.handleError(message: error.localizedDescription)
                    continuation.resume()
                }
                
                //* TIP: Verify phone number with Deep Link
                VerifySpeed.shared.verifyPhoneNumberWithDeepLink(
                    deeplink: response.deepLink ?? "",
                    verificationKey: response.verificationKey,
                    callBackListener: listener
                )
            }
            
        } catch {
            handleError(message: error.localizedDescription)
        }
        
        isLoading = false
    }
    
    private func showPhoneNumberDialog(token: String) async {
        do {
            isLoading = true
            showSuccessDialog = true
            
            phoneNumber = try await verifySpeedService.getPhoneNumber(token: token)
        } catch {
            handleError(message: "Failed to get phone number")
        }
        
        isLoading = false
    }
    
    private func handleError(message: String) {
        error = message
        print("MessageViewModel: \(message)")
    }
}
