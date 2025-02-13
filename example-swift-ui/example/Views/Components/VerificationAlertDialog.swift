import SwiftUI

struct VerificationAlertDialog: View {
    let title: String
    let isLoading: Bool
    let phoneNumber: String?
    let loadingMessage: String?
    let onDismiss: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Color.black.opacity(0.3)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.top)
                    
                    if isLoading {
                        ProgressView()
                            .padding()
                        if let message = loadingMessage {
                            Text(message)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    } else if let number = phoneNumber {
                        Text("Your verified phone number is:")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(.top)
                        Text(number)
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(.vertical)
                    }
                    
                    Button("OK") {
                        onDismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .frame(maxWidth: 300)
                .background(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
                .cornerRadius(12)
                .shadow(radius: 10)
                .padding()
            )
    }
} 