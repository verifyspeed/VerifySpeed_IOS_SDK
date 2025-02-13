import Foundation
import VerifySpeed_IOS

class MainViewModel {
    private(set) var methods: [MethodModel] = []
    private(set) var isLoading = false
    let verifySpeedService = VerifySpeedService()
    
    // Callbacks for UI updates
    var onMethodsUpdated: (([MethodModel]) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    func initialize() {
        Task {
            await fetchMethods()
        }
    }
    
    @MainActor
    private func fetchMethods() async {
        isLoading = true
        onLoadingChanged?(true)
        
        do {
            let result = try await verifySpeedService.initialize()
            methods = result
            onMethodsUpdated?(methods)
        } catch {
            onError?(error.localizedDescription)
        }
        
        isLoading = false
        onLoadingChanged?(false)
    }
}
