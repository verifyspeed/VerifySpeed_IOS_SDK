import UIKit
import VerifySpeed_IOS

class OtpViewController: UIViewController {
    private let verificationKey: String
    private let stackView = UIStackView()
    private let otpTextField = UITextField()
    private let verifyButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private var viewModel: OtpViewModel!
    
    init(verificationKey: String) {
        self.verificationKey = verificationKey
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
    }
    
    private func setupUI() {
        title = "OTP Verification"
        view.backgroundColor = .systemBackground
        
        // Configure stack view
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Configure OTP text field
        otpTextField.placeholder = "Enter 6-digit OTP"
        otpTextField.borderStyle = .roundedRect
        otpTextField.keyboardType = .numberPad
        otpTextField.addTarget(self, action: #selector(otpTextChanged), for: .editingChanged)
        
        // Configure verify button
        verifyButton.setTitle("Verify OTP", for: .normal)
        verifyButton.backgroundColor = .systemBlue
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.cornerRadius = 8
        verifyButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        verifyButton.isEnabled = false
        
        // Configure activity indicator
        activityIndicator.hidesWhenStopped = true
        
        // Add views to stack
        stackView.addArrangedSubview(otpTextField)
        stackView.addArrangedSubview(verifyButton)
        stackView.addArrangedSubview(activityIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            otpTextField.heightAnchor.constraint(equalToConstant: 50),
            verifyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupViewModel() {
        viewModel = OtpViewModel()

        viewModel.onSuccess = { [weak self] phoneNumber in
            self?.showSuccessDialog(phoneNumber: phoneNumber)
        }
        
        viewModel.onError = { [weak self] error in
            self?.showAlert(title: "Error", message: error)
        }
        
        viewModel.onLoadingChanged = { [weak self] isLoading in
            self?.updateLoadingState(isLoading)
        }
    }
    
    @objc private func otpTextChanged() {
        verifyButton.isEnabled = otpTextField.text?.count == 6
    }
    
    @objc private func verifyButtonTapped() {
        guard let otp = otpTextField.text else { return }
        
        viewModel.setOtpCode(otp)

        Task {
            await viewModel.validateOtp(verificationKey: verificationKey)
        }
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            verifyButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            verifyButton.isEnabled = otpTextField.text?.count == 6
        }
    }
    
    private func showSuccessDialog(phoneNumber: String?) {
        let alert = UIAlertController(
            title: "Verification Successful",
            message: phoneNumber != nil ? "Phone number: \(phoneNumber!)" : nil,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })

        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 
