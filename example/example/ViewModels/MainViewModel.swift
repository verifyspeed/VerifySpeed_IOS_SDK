import Foundation
import VerifySpeed_IOS

@MainActor
class MainViewModel: ObservableObject {
    let verifySpeedService = VerifySpeedService()
    
    @Published var methods: [MethodModel] = []
    @Published var isLoading = true
    @Published var countryCode: String?
    
    func initialize() {
        Task {
            methods = try await verifySpeedService.initialize()
            isLoading = false
        }
    }
    
    func getCountry() {
        Task {
            let result = await verifySpeedService.getCountry()
            if case .success(let code) = result {
                countryCode = code
            }
        }
    }
} 
