import UIKit
import VerifySpeed_IOS

class ViewController: UIViewController {
    private let stackView = UIStackView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private var viewModel: MainViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        initializeSDK()
    }
    
    private func setupUI() {
        title = "Methods"
        view.backgroundColor = .systemBackground
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Configure content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Configure stack view
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        // Configure loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupViewModel() {
        viewModel = MainViewModel()
        
        viewModel.onMethodsUpdated = { [weak self] methods in
            self?.updateMethodButtons(methods)
        }
        
        viewModel.onLoadingChanged = { [weak self] isLoading in
            self?.updateLoadingState(isLoading)
        }
        
        viewModel.onError = { [weak self] error in
            self?.showAlert(title: "Error", message: error)
        }
    }
    
    private func initializeSDK() {
        //* TIP: Check for interrupted session
        VerifySpeed.shared.checkInterruptedSession { [weak self] token in
            if let token = token {
                self?.handleInterruptedSession(token: token)
            }
        }
        
        //* TIP: Set your client key
        VerifySpeed.shared.setClientKey("YOU_CLIENT_KEY")
        
        // Initialize view model
        viewModel.initialize()
    }
    
    private func updateMethodButtons(_ methods: [MethodModel]) {
        // Remove existing buttons
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new method buttons
        for method in methods {
            let button = createMethodButton(for: method)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func createMethodButton(for method: MethodModel) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Sign in with \(method.displayName)", for: .normal)
        button.backgroundColor = .systemBackground
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.label.cgColor
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        button.addAction(UIAction { [weak self] _ in
            self?.handleMethodSelection(method)
        }, for: .touchUpInside)
        
        return button
    }
    
    private func handleMethodSelection(_ method: MethodModel) {
        let isOtp = method.displayName.lowercased().contains("otp")
        let isMessage = method.displayName.lowercased().contains("message")
        
        if isOtp {
            let phoneNumberVC = PhoneNumberViewController(method: method.methodName, mainViewModel: viewModel)
            navigationController?.pushViewController(phoneNumberVC, animated: true)
        } else if isMessage {
            let messageVC = MessageViewController(method: method.methodName)
            navigationController?.pushViewController(messageVC, animated: true)
        }
    }
    
    private func handleInterruptedSession(token: String) {
        Task {
            do {
                let phoneNumber = try await viewModel.verifySpeedService.getPhoneNumber(token: token)
                await MainActor.run {
                    showInterruptedSessionDialog(phoneNumber: phoneNumber)
                }
            } catch {
                print("Failed to get phone number: \(error.localizedDescription)")
            }
        }
    }
    
    private func showInterruptedSessionDialog(phoneNumber: String?) {
        let alert = UIAlertController(
            title: "Interrupted Session Found",
            message: phoneNumber != nil ? "Phone number: \(phoneNumber!)" : "Loading phone number...",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
