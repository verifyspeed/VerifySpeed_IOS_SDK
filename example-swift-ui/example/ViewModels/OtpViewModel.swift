import Foundation
import SwiftUI

@MainActor
class OtpViewModel: ObservableObject {
    @Published var otpCode = ""
    @Published var isLoading = false
    @Published var error: String?
    @Published var phoneNumber: String?
    @Published var showSuccessDialog = false
    
    private let verifySpeedService = VerifySpeedService()
    
    func validateOtp(verificationKey: String) async {
        isLoading = true
        error = nil
        
        do {
            let token = try await verifySpeedService.validateOtp(otpCode: otpCode, verificationKey: verificationKey)
            
            // Show dialog and start loading phone number
            withAnimation {
                showSuccessDialog = true
                isLoading = true
            }
            
            // Fetch phone number
            do {
                let number = try await verifySpeedService.getPhoneNumber(token: token)
                
                // Update UI with phone number
                withAnimation {
                    phoneNumber = number
                    isLoading = false
                }
            } catch {
                withAnimation {
                    self.error = "Failed to get phone number: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        } catch {
            withAnimation {
                self.error = error.localizedDescription
                self.isLoading = false
                showSuccessDialog = false
            }
        }
    }
} 
