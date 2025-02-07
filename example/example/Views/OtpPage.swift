import SwiftUI

struct OtpPage: View {
    let verificationKey: String
    @Binding var navigationPath: [Screen]
    @StateObject private var viewModel = OtpViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                TextField("Enter 6-digit OTP", text: $viewModel.otpCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding()
                
                Button("Verify OTP") {
                    Task {
                        await viewModel.validateOtp(verificationKey: verificationKey)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.otpCode.isEmpty || viewModel.otpCode.count != 6)
                
                if viewModel.isLoading && !viewModel.showSuccessDialog {
                    ProgressView()
                }
            }
            .padding()
            
            if viewModel.showSuccessDialog {
                VerificationAlertDialog(
                    title: "Verification Successful",
                    isLoading: viewModel.isLoading,
                    phoneNumber: viewModel.phoneNumber,
                    loadingMessage: "Loading phone number...",
                    onDismiss: { navigationPath.removeAll() }
                )
            }
        }
        .navigationTitle("OTP Verification")
        .alert(
            "Error",
            isPresented: .init(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            ),
            actions: { Button("OK", role: .cancel) { } },
            message: { Text(viewModel.error ?? "Verification failed") }
        )
    }
} 
