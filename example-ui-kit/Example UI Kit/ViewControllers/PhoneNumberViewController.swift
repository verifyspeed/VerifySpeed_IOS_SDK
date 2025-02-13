import UIKit
import PhoneNumberKit
import VerifySpeed_IOS

class PhoneNumberViewController: UIViewController {
    private let method: String
    private let stackView = UIStackView()
    private let phoneContainer = UIStackView()
    private let countryCodeTextField = UITextField()
    private let phoneNumberTextField = UITextField()
    private let continueButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let phoneNumberKit = PhoneNumberUtility()
    private var viewModel: PhoneNumberViewModel!
    
    init(method: String, mainViewModel: MainViewModel) {
        self.method = method
        super.init(nibName: nil, bundle: nil)
        self.viewModel = PhoneNumberViewModel(mainViewModel: mainViewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        fetchInitialCountryCode()
    }
    
    private func setupUI() {
        title = "Phone Number"
        view.backgroundColor = .systemBackground
        
        // Configure stack views
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        phoneContainer.axis = .horizontal
        phoneContainer.spacing = 8
        phoneContainer.distribution = .fill
        
        // Configure country code text field
        countryCodeTextField.placeholder = "Code"
        countryCodeTextField.borderStyle = .roundedRect
        countryCodeTextField.keyboardType = .phonePad
        countryCodeTextField.text = "+1"
        countryCodeTextField.addTarget(self, action: #selector(countryCodeChanged), for: .editingChanged)
        
        // Configure phone number text field
        phoneNumberTextField.placeholder = "Phone Number"
        phoneNumberTextField.borderStyle = .roundedRect
        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberChanged), for: .editingChanged)
        
        // Configure continue button
        continueButton.setTitle("Continue", for: .normal)
        continueButton.backgroundColor = .systemBlue
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 8
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        // Configure activity indicator
        activityIndicator.hidesWhenStopped = true
        
        // Add views to container
        phoneContainer.addArrangedSubview(countryCodeTextField)
        phoneContainer.addArrangedSubview(phoneNumberTextField)
        
        // Set country code width constraint
        countryCodeTextField.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        // Add views to stack
        stackView.addArrangedSubview(phoneContainer)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(activityIndicator)
        
        // Add validation message label
        let validationLabel = UILabel()
        validationLabel.textColor = .systemRed
        validationLabel.font = .systemFont(ofSize: 12)
        validationLabel.numberOfLines = 0
        validationLabel.isHidden = true
        stackView.addArrangedSubview(validationLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            phoneContainer.heightAnchor.constraint(equalToConstant: 50),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupViewModel() {
        viewModel.onVerificationKeyReceived = { [weak self] verificationKey in
            let otpVC = OtpViewController(verificationKey: verificationKey)

            self?.navigationController?.pushViewController(otpVC, animated: true)
        }
        
        viewModel.onError = { [weak self] error in
            self?.showAlert(title: "Error", message: error)
        }
        
        viewModel.onLoadingChanged = { [weak self] isLoading in
            self?.updateLoadingState(isLoading)
        }
    }
    
    private func fetchInitialCountryCode() {
        Task {
            if let countryCode = await viewModel.getInitialCountryCode() {
                DispatchQueue.main.async {
                    self.countryCodeTextField.text = countryCode
                }
            }
        }
    }
    
    @objc private func countryCodeChanged() {
        var text = countryCodeTextField.text ?? ""
        if !text.hasPrefix("+") {
            text = "+\(text)"
        }
        text = String(text.prefix(4))
        countryCodeTextField.text = text
        validatePhoneNumber()
    }
    
    @objc private func phoneNumberChanged() {
        if let text = phoneNumberTextField.text {
            let filtered = text.filter { $0.isNumber || $0 == " " || $0 == "-" }
            phoneNumberTextField.text = String(filtered.prefix(15))
        }
        validatePhoneNumber()
    }
    
    private func validatePhoneNumber() {
        guard let countryCode = countryCodeTextField.text,
              let phoneNumber = phoneNumberTextField.text,
              !phoneNumber.isEmpty else {
            updateValidationState(isValid: false, message: "Please enter a phone number")
            return
        }
        
        let fullNumber = "\(countryCode)\(phoneNumber)".replacingOccurrences(
            of: "[^+\\d]",
            with: "",
            options: .regularExpression
        )
        
        do {
            // Just trying to parse the number is enough for validation
            _ = try phoneNumberKit.parse(fullNumber)
            updateValidationState(isValid: true, message: nil)
        } catch {
            updateValidationState(isValid: false, message: "Invalid phone number format")
        }
    }
    
    private func updateValidationState(isValid: Bool, message: String?) {
        continueButton.isEnabled = isValid
        
        // Update validation label
        if let validationLabel = stackView.arrangedSubviews.last as? UILabel {
            validationLabel.text = message
            validationLabel.isHidden = message == nil
        }
    }
    
    @objc private func continueButtonTapped() {
        guard let countryCode = countryCodeTextField.text,
              let phoneNumber = phoneNumberTextField.text else { return }
        
        let fullNumber = "\(countryCode)\(phoneNumber)".replacingOccurrences(
            of: "[^+\\d]",
            with: "",
            options: .regularExpression
        )
        
        do {
            // If we can parse the number, it's valid
            let parsedNumber = try phoneNumberKit.parse(fullNumber)

            let formattedNumber = phoneNumberKit.format(parsedNumber, toType: .e164)
            Task {
                await viewModel.verifyPhoneNumber(method: method, phoneNumber: formattedNumber)
            }
        } catch {
            showAlert(title: "Invalid Format", message: "Please check the phone number format")
        }
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            continueButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            updateContinueButtonState()
        }
    }
    
    private func updateContinueButtonState() {
        continueButton.isEnabled = !(phoneNumberTextField.text?.isEmpty ?? true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 
