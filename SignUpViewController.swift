//
//  SignUpViewController.swift
//  what'sCookin
//
//  Created by Raisa Methila on 7/4/24.
//


import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    // UI Elements

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
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


    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // Add subviews
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(signUpButton)
        view.addSubview(cancelButton)

        // Layout constraints
        setupConstraints()
    }

    // Constraints Setup

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Email TextField Constraints
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Password TextField Constraints
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Confirm Password TextField Constraints
            confirmPasswordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Sign Up Button Constraints
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 20),

            // Cancel Button Constraints
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 10),
        ])
    }

    // Actions

    @objc private func signUpButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            // Show an alert if any field is empty
            showAlert(message: "Please fill out all fields.")
            return
        }

        guard password == confirmPassword else {
            // Show an alert if passwords do not match
            showAlert(message: "Passwords do not match.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showAlert(message: error.localizedDescription)
                return
            }

            // Handle sign up success
            self?.dismiss(animated: true, completion: nil)
        }
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

