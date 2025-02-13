import SwiftUI
import VerifySpeed_IOS

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var navigationPath = [Screen]()
    @State private var showInterruptedSessionDialog = false
    @State private var verifiedPhoneNumber: String?
    @State private var isLoadingPhoneNumber = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.methods.isEmpty {
                    Text("Please check your client key set and correct to display available methods")
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.methods, id: \.methodName) { method in
                                MethodButton(method: method, navigationPath: $navigationPath)
                            }
                        }
                        .padding()
                    }
                }
                
                if showInterruptedSessionDialog {
                    VerificationAlertDialog(
                        title: "Interrupted Session Found",
                        isLoading: isLoadingPhoneNumber,
                        phoneNumber: verifiedPhoneNumber,
                        loadingMessage: nil,
                        onDismiss: { showInterruptedSessionDialog = false }
                    )
                }
            }
            .navigationTitle("Methods")
            .background(
                ForEach(navigationPath, id: \.self) { screen in
                    NavigationLink(
                        destination: destinationView(for: screen),
                        isActive: Binding(
                            get: { navigationPath.contains(screen) },
                            set: { isActive in
                                if !isActive {
                                    navigationPath.removeAll { $0 == screen }
                                }
                            }
                        ),
                        label: { EmptyView() }
                    )
                }
            )
        }
        .navigationViewStyle(.stack)
        .onAppear {
            //* TIP: Check for interrupted session
            VerifySpeed.shared.checkInterruptedSession(
                completion: { token in
                    if let token = token {
                        handleInterruptedSession(token: token)
                    }
                }
            )
            
            //* TIP: Set your client key
            VerifySpeed.shared.setClientKey("YOUR_CLIENT_KEY")

            viewModel.initialize()

            viewModel.getCountry()
        }
    }
    
    @ViewBuilder
    private func destinationView(for screen: Screen) -> some View {
        switch screen {
        case .methods:
            EmptyView()
        case .phoneNumber(let method):
            PhoneNumberPage(method: method, navigationPath: $navigationPath, mainViewModel: viewModel)
        case .otp(let verificationKey):
            OtpPage(verificationKey: verificationKey, navigationPath: $navigationPath)
        case .message(let method):
            MessagePage(method: method, navigationPath: $navigationPath)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Message Verification")
        }
    }
    
    private func handleInterruptedSession(token: String) {
        showInterruptedSessionDialog = true
        isLoadingPhoneNumber = true
        
        Task {
            do {
                let phoneNumber = try await viewModel.verifySpeedService.getPhoneNumber(token: token)
                await MainActor.run {
                    verifiedPhoneNumber = phoneNumber
                    isLoadingPhoneNumber = false
                }
            } catch {
                print("Failed to get phone number: \(error.localizedDescription)")
                await MainActor.run {
                    isLoadingPhoneNumber = false
                }
            }
        }
    }
}

struct MethodButton: View {
    let method: MethodModel
    @Binding var navigationPath: [Screen]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            handleMethodSelection(method)
        }) {
            Text("Sign in with \(method.displayName)")
                .foregroundColor(colorScheme == .dark ?  Color.black : Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(colorScheme == .dark ?  Color.white : Color.black)
                .cornerRadius(5)
        }
    }
    
    private func handleMethodSelection(_ method: MethodModel) {
        let isOtp = method.displayName.lowercased().contains("otp")
        let isMessage = method.displayName.lowercased().contains("message")
        
        if isOtp {
            navigationPath.append(.phoneNumber(method: method.methodName))
        } else if isMessage {
            navigationPath.append(.message(method: method.methodName))
        }
    }
}

#Preview {
    ContentView()
}
