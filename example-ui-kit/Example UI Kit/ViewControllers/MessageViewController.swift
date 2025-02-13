import UIKit
import VerifySpeed_IOS

class MessageViewController: UIViewController {
    private let method: String
    private let stackView = UIStackView()
    private let verifyButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private var viewModel: MessageViewModel!
    
    init(method: String) {
        self.method = method
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        setupNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove notification observer when view is disappearing
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotifications() {        
        // Add observer for when app will enter foreground
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func applicationWillEnterForeground() {
        //* TIP: Notify VerifySpeed when the app resumes
        VerifySpeed.shared.notifyOnResumed()
    }
    
    private func setupUI() {
        title = "Message Verification"
        view.backgroundColor = .systemBackground
        
        // Configure stack view
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Configure verify button
        verifyButton.setTitle("Verify with Message", for: .normal)
        verifyButton.backgroundColor = .systemBlue
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.cornerRadius = 8
        verifyButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        
        // Configure activity indicator
        activityIndicator.hidesWhenStopped = true
        
        // Add views to stack
        stackView.addArrangedSubview(verifyButton)
        stackView.addArrangedSubview(activityIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            verifyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupViewModel() {
        viewModel = MessageViewModel()
        
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
    
    @objc private func verifyButtonTapped() {
        Task {
            await viewModel.verifyWithMessage(method: method)
        }
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            verifyButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            verifyButton.isEnabled = true
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
