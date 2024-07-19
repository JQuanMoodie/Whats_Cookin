//
//  LoginViewController.swift
//  what'sCookin
//
//  Created by Raisa Methila on 7/4/24.
//


import UIKit
import FirebaseAuth

protocol LoginViewControllerDelegate: AnyObject {
    func didLoginSuccessfully()
}

class LoginViewController: UIViewController {

    // Delegate to handle login success
    weak var delegate: LoginViewControllerDelegate?

    // UI Elements

    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

//    private let passwordTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Password"
//        textField.isSecureTextEntry = true
//        textField.borderStyle = .roundedRect
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        return textField
//    }()
   
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 12.0, *) {
            textField.textContentType = .newPassword // Set it to newPassword to avoid strong password suggestion
        } else {
            textField.textContentType = .none // Fallback for earlier iOS versions
        }
        textField.autocorrectionType = .no // Disable autocorrection
        textField.spellCheckingType = .no // Disable spell checking
        return textField
    }()



    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()

    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // Add subviews
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)

        // Layout constraints
        setupConstraints()
    }

    // Constraints Setup

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Username TextField Constraints
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Password TextField Constraints
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Login Button Constraints
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),

            // Sign Up Button Constraints
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),
        ])
    }

    // Actions

    @objc private func loginButtonTapped() {
        guard let email = usernameTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // Show an alert if email or password is empty
            showAlert(message: "Please enter both email and password.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showAlert(message: error.localizedDescription)
                return
            }

            // Handle login success
            self?.handleLoginSuccess()
        }
    }

    @objc private func signUpButtonTapped() {
        let signUpViewController = SignUpViewController()
        signUpViewController.modalPresentationStyle = .fullScreen
        present(signUpViewController, animated: true, completion: nil)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Call this method when login is successful
    private func handleLoginSuccess() {
        delegate?.didLoginSuccessfully()
    }
}
