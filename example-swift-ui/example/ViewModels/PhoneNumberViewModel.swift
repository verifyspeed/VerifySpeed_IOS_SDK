import Foundation

@MainActor
class PhoneNumberViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedCountry: String?
    
    let verifySpeedService = VerifySpeedService()
    private let mainViewModel: MainViewModel
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        self.selectedCountry = mainViewModel.countryCode
    }
    
    func verifyPhoneNumber(method: String, phoneNumber: String) async -> String? {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await verifySpeedService.getVerificationKey(methodName: method)
            try await verifySpeedService.verifyPhoneNumberWithOtp(
                verificationKey: response.verificationKey,
                phoneNumber: phoneNumber
            )

            return response.verificationKey
        } catch {
            // Handle error appropriately
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
} 
