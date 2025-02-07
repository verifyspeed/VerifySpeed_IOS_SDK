import Foundation
import VerifySpeed_IOS
import PhoneNumberKit

class VerifySpeedService {
    private let baseURL = "YOUR_BASE_URL"
    private let phoneUtil = PhoneNumberUtility()
    
    func getVerificationKey(methodName: String) async throws -> VerificationKeyModel {
        let url = URL(string: "\(baseURL)/YOUR_ENDPOINT")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["methodName": methodName]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(VerificationKeyModel.self, from: data)
    }
    
    func verifyPhoneNumberWithOtp(verificationKey: String, phoneNumber: String) {
        //* TIP: Verify phone number with OTP
        VerifySpeed.shared.verifyPhoneNumberWithOtp(
            phoneNumber: phoneNumber,
            verificationKey: verificationKey,
            completion: { _ in }
        )
    }
    
    func validateOtp(otpCode: String, verificationKey: String) async throws -> String {
        return await withCheckedContinuation { continuation in
            let listener = VerifySpeedListenerHandler()
            
            listener.onSuccess = { token in
                continuation.resume(returning: token)
            }
            
            listener.onFailure = { error in
                continuation.resume(throwing: (error as NSError) as! Never)
            }
            
            //* TIP: Validate OTP
            VerifySpeed.shared.validateOTP(
                otpCode: otpCode,
                verificationKey: verificationKey,
                callBackListener: listener
            )
        }
    }
    
    func getPhoneNumber(token: String) async throws -> String {
        let url = URL(string: "\(baseURL)/YOUR_ENDPOINT")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["token": token]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        struct LoginResponse: Codable {
            let phoneNumber: String
            
            enum CodingKeys: String, CodingKey {
                case phoneNumber = "phoneNumber"
            }
        }
        
        let response = try JSONDecoder().decode(LoginResponse.self, from: data)
        return response.phoneNumber
    }
    
    func getCountry() async -> Result<String, Error> {
        do {
            let url = URL(string: "https://api.country.is")!
            let request = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: request)
            
            struct CountryResponse: Codable {
                let country: String
            }
            
            let response = try JSONDecoder().decode(CountryResponse.self, from: data)
            let isoCountryCode = response.country
            if let countryCode = phoneUtil.countryCode(for: isoCountryCode) {
                return .success("+\(countryCode)")
            }
            return .success("US")
        } catch {
            return .failure(error)
        }
    }
    
    func initialize() async throws -> [MethodModel] {
        return await withCheckedContinuation { continuation in
            do {
                //* TIP: Initialize to get available methods
                try VerifySpeed.shared.initialize { methods in
                    continuation.resume(returning: methods)
                }
            } catch {
                continuation.resume(throwing: error as! Never)
            }
        }
    }
} 

class VerifySpeedListenerHandler: VerifySpeedListener {
    var onSuccess: ((String) -> Void)?
    var onFailure: ((VerifySpeedError) -> Void)?
    
    func onFail(error: VerifySpeed_IOS.VerifySpeedError) {
        onFailure?(error)
    }
    
    func onSuccess(token: String) {
        onSuccess?(token)
    }
}
