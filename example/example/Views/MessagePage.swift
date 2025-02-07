import SwiftUI
import VerifySpeed_IOS

struct MessagePage: View {
    let method: String
    @Binding var navigationPath: [Screen]
    @StateObject private var viewModel = MessageViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Button {
                    Task {
                        await viewModel.verifyWithMessage(method: method)
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(Color.white)
                    } else {
                        Text("Verify with Message")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .padding()
            
            if viewModel.showSuccessDialog {
                VerificationAlertDialog(
                    title: "Verification Successful",
                    isLoading: viewModel.isLoading,
                    phoneNumber: viewModel.phoneNumber,
                    loadingMessage: nil,
                    onDismiss: { navigationPath.removeAll() }
                )
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                //* TIP: Notify VerifySpeed when the app resumes
                VerifySpeed.shared.notifyOnResumed()
            }
        }
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
