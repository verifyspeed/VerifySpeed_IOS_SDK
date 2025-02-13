import SwiftUI

struct PhoneNumberPage: View {
    let method: String
    @Binding var navigationPath: [Screen]
    @StateObject private var viewModel: PhoneNumberViewModel
    @State private var phoneNumber = ""
    @State private var countryCode = "+1" // Default value
    
    init(method: String, navigationPath: Binding<[Screen]>, mainViewModel: MainViewModel) {
        self.method = method
        self._navigationPath = navigationPath
        self._viewModel = StateObject(wrappedValue: PhoneNumberViewModel(mainViewModel: mainViewModel))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Country code and phone number input row
            HStack(spacing: 8) {
                // Country code input
                TextField("Code", text: $countryCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                    .frame(width: 80)
                    .onChange(of: countryCode) { newValue in
                        // Always ensure + prefix exists
                        var updatedValue = newValue
                        if updatedValue.isEmpty {
                            updatedValue = "+"
                        } else if !updatedValue.hasPrefix("+") {
                            updatedValue = "+\(updatedValue)"
                        }
                        
                        // Filter and limit length
                        let filtered = String(updatedValue.filter { $0.isNumber || $0 == "+" })
                        if filtered.count <= 4 {
                            countryCode = filtered
                        } else {
                            countryCode = String(filtered.prefix(4))
                        }
                    }
                    .onAppear {
                        // Ensure + prefix on initial load
                        if !countryCode.hasPrefix("+") {
                            countryCode = "+\(countryCode)"
                        }
                    }
                
                // Phone number input field
                TextField("Phone Number", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                    .onChange(of: phoneNumber) { newValue in
                        // Allow only digits, spaces, and hyphens
                        let filtered = newValue.filter { $0.isNumber || $0 == " " || $0 == "-" }
                        if filtered.count <= 15 {
                            phoneNumber = filtered
                        } else {
                            phoneNumber = String(filtered.prefix(15))
                        }
                    }
            }
            .padding(.horizontal)
            
            Button("Continue") {
                Task {
                    let fullNumber = "\(countryCode)\(phoneNumber)".replacingOccurrences(
                        of: "[^+\\d]",
                        with: "",
                        options: .regularExpression
                    )
                    if let verificationKey = await viewModel.verifyPhoneNumber(
                        method: method,
                        phoneNumber: fullNumber
                    ) {
                        navigationPath.append(.otp(verificationKey: verificationKey))
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(phoneNumber.isEmpty || viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .padding()
        .navigationTitle("Phone Number")
        .task {
            // Fetch and set initial country code
            let result = await viewModel.verifySpeedService.getCountry()
            if case .success(let code) = result {
                countryCode = code
            }
        }
    }
} 
