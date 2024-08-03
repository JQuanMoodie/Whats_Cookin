//  Settings.swift
//  what'sCookin
//
//  Created by Raisa Methila on 7/19/24.
// Edited by Jevon 

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController {

    // UI Elements
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.label // Dynamic color for text
        return label
    }()
    
    private let changePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change password", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.systemBlue, for: .normal) // Dynamic color for button title
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(changePasswordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let fontSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "Font size:"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.label // Dynamic color for text
        return label
    }()
    
    private let fontSizeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["small", "medium", "large"])
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.tintColor = UIColor.systemBlue // Dynamic color for segmented control
        return segmentedControl
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log out", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.systemRed, for: .normal) // Dynamic color for button title
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Account", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.systemRed, for: .normal) // Dynamic color for button title
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground // Dynamic color for background
        
        view.addSubview(emailLabel)
        view.addSubview(changePasswordButton)
        view.addSubview(fontSizeLabel)
        view.addSubview(fontSizeSegmentedControl)
        view.addSubview(logoutButton)
        view.addSubview(deleteAccountButton)
        
        setupConstraints()
        updateEmailLabel()
        
        // Set up the segmented control action
        fontSizeSegmentedControl.addTarget(self, action: #selector(fontSizeChanged), for: .valueChanged)
        
        // Set initial font size
        updateFontSize()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            changePasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changePasswordButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            
            fontSizeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fontSizeLabel.topAnchor.constraint(equalTo: changePasswordButton.bottomAnchor, constant: 20),
            
            fontSizeSegmentedControl.centerYAnchor.constraint(equalTo: fontSizeLabel.centerYAnchor),
            fontSizeSegmentedControl.leadingAnchor.constraint(equalTo: fontSizeLabel.trailingAnchor, constant: 10),
            fontSizeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: fontSizeSegmentedControl.bottomAnchor, constant: 40),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            deleteAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteAccountButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20),
            deleteAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deleteAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func updateEmailLabel() {
        if let user = Auth.auth().currentUser {
            emailLabel.text = "Email: \(user.email ?? "No email available")"
        } else {
            emailLabel.text = "Email: Not logged in"
        }
    }
    
    @objc private func changePasswordButtonTapped() {
        let alert = UIAlertController(title: "Change Password", message: "Enter your new password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "New Password"
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let newPassword = alert.textFields?.first?.text, !newPassword.isEmpty else {
                self?.showErrorAlert(message: "New password cannot be empty.")
                return
            }
            self?.reauthenticateAndChangePassword(newPassword: newPassword)
        }
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func reauthenticateAndChangePassword(newPassword: String) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            showErrorAlert(message: "User not logged in or email not available.")
            return
        }

        let alert = UIAlertController(title: "Re-authenticate", message: "Please enter your current password to proceed.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Current Password"
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let currentPassword = alert.textFields?.first?.text, !currentPassword.isEmpty else {
                self?.showErrorAlert(message: "Current password cannot be empty.")
                return
            }

            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            user.reauthenticate(with: credential) { [weak self] result, error in
                if let error = error as NSError? {
                    // Use the raw error code directly for comparison
                    switch error.code {
                    case AuthErrorCode.invalidCredential.rawValue:
                        self?.showErrorAlert(message: "The provided credentials are invalid. Please check your email and password.")
                    case AuthErrorCode.requiresRecentLogin.rawValue:
                        self?.showErrorAlert(message: "The credentials are too old. Please sign in again.")
                    default:
                        self?.showErrorAlert(message: "Error reauthenticating: \(error.localizedDescription)")
                    }
                } else {
                    user.updatePassword(to: newPassword) { error in
                        if let error = error {
                            self?.showErrorAlert(message: "Error updating password: \(error.localizedDescription)")
                        } else {
                            self?.showSuccessAlert(message: "Password updated successfully.")
                        }
                    }
                }
            }
        }
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            navigateToLoginView()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    @objc private func deleteAccountButtonTapped() {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performAccountDeletion()
        }
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func performAccountDeletion() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Step 1: Delete user data from Firestore
        deleteUserData(userId: user.uid) { [weak self] success in
            if success {
                // Step 2: Delete the user account
                user.delete { error in
                    if let error = error {
                        print("Error deleting account: \(error.localizedDescription)")
                    } else {
                        print("Account deleted successfully")
                        
                        // Step 3: Log out the user
                        do {
                            try Auth.auth().signOut()
                            
                            // Navigate to LoginViewController
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = scene.windows.first {
                                let loginViewController = LoginViewController()
                                loginViewController.modalPresentationStyle = .fullScreen
                                window.rootViewController = loginViewController
                                window.makeKeyAndVisible()
                            }
                        } catch let signOutError as NSError {
                            print("Error signing out: %@", signOutError)
                        }
                    }
                }
            } else {
                print("Failed to delete user data.")
            }
        }
    }
    
    private func deleteUserData(userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user data: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User data deleted successfully")
                completion(true)
            }
        }
    }
    
    @objc private func fontSizeChanged() {
        updateFontSize()
    }
    
    private func updateFontSize() {
        let fontSize: CGFloat
        switch fontSizeSegmentedControl.selectedSegmentIndex {
        case 0:
            fontSize = 14
        case 1:
            fontSize = 18
        case 2:
            fontSize = 22
        default:
            fontSize = 18
        }
        emailLabel.font = UIFont.systemFont(ofSize: fontSize)
        changePasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        fontSizeLabel.font = UIFont.systemFont(ofSize: fontSize)
        fontSizeSegmentedControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: fontSize)], for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        deleteAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    private func navigateToLoginView() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            let loginViewController = LoginViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            window.rootViewController = loginViewController
            window.makeKeyAndVisible()
        }
    }
}


