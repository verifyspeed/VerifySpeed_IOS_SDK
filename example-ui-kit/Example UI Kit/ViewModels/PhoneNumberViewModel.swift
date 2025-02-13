import Foundation
import VerifySpeed_IOS

class PhoneNumberViewModel {
    private let mainViewModel: MainViewModel
    private(set) var isLoading = false
    
    // Callbacks for UI updates
    var onVerificationKeyReceived: ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    @MainActor
    func verifyPhoneNumber(method: String, phoneNumber: String) async {
        isLoading = true
        onLoadingChanged?(true)
        
        do {
            let verificationKeyModel = try await mainViewModel.verifySpeedService.getVerificationKey(methodName: method)
            
            mainViewModel.verifySpeedService.verifyPhoneNumberWithOtp(
                verificationKey: verificationKeyModel.verificationKey,
                phoneNumber: phoneNumber
            )

            onVerificationKeyReceived?(verificationKeyModel.verificationKey)
        } catch {
            onError?(error.localizedDescription)
        }
        
        isLoading = false
        onLoadingChanged?(false)
    }
    
    func getInitialCountryCode() async -> String? {
        let result = await mainViewModel.verifySpeedService.getCountry()
        switch result {
        case .success(let code):
            return code
        case .failure:
            return nil
        }
    }
}
