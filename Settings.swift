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
        button.setTitle("Change Password", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(changePasswordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let fontSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "Font Size:"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.label
        return label
    }()
    
    private let fontSizeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Small", "Medium", "Large"])
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.tintColor = UIColor.systemBlue
        return segmentedControl
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.systemRed, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Account", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.systemRed, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground // Dynamic color for background
        
        setupSubviews()
        setupConstraints()
        updateEmailLabel()
        
        fontSizeSegmentedControl.addTarget(self, action: #selector(fontSizeChanged), for: .valueChanged)
        updateFontSize()
    }
    
    private func setupSubviews() {
        let settingsStackView = UIStackView(arrangedSubviews: [
            emailLabel,
            changePasswordButton,
            fontSizeLabel,
            fontSizeSegmentedControl,
            logoutButton,
            deleteAccountButton
        ])
        settingsStackView.axis = .vertical
        settingsStackView.alignment = .center
        settingsStackView.spacing = 20
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emailLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            changePasswordButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            fontSizeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            fontSizeSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            logoutButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            deleteAccountButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            
            view.subviews.first!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            view.subviews.first!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteUserAccount()
        })
        present(alert, animated: true, completion: nil)
    }
    
   private func deleteUserAccount() {
    guard let user = Auth.auth().currentUser else { return }
    let db = Firestore.firestore()
    
    let userID = user.uid
    
    // Example collections and subcollections
    let collectionsToDelete = [
        "posts",
        "groceryItems",
        "following",
        "followers",
        "shoppingCartItems",
        "savedRecipes",
        "favoriteRecipes"
    ]
    
    let userDocument = db.collection("users").document(userID)
    let batch = db.batch()
    
    // Function to delete a collection
    func deleteCollection(_ collectionPath: String, completion: @escaping (Error?) -> Void) {
        let collectionRef = db.collection("users").document(userID).collection(collectionPath)
        
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(nil)
                return
            }
            
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            completion(nil)
        }
    }
    
    // Delete all collections in batch
    let dispatchGroup = DispatchGroup()
    
    for collection in collectionsToDelete {
        dispatchGroup.enter()
        deleteCollection(collection) { error in
            if let error = error {
                self.showErrorAlert(message: "Error deleting \(collection): \(error.localizedDescription)")
            }
            dispatchGroup.leave()
        }
    }
    
    // After all collections are deleted, delete the user document and commit the batch
    dispatchGroup.notify(queue: .main) {
        batch.deleteDocument(userDocument)
        
        batch.commit { error in
            if let error = error {
                self.showErrorAlert(message: "Error deleting user data: \(error.localizedDescription)")
                return
            }
            
            // Delete user account
            user.delete { error in
                if let error = error {
                    self.showErrorAlert(message: "Error deleting account: \(error.localizedDescription)")
                } else {
                    self.navigateToLoginView()
                }
            }
        }
    }
}


    
    private func navigateToLoginView() {
        let loginViewController = LoginViewController()
        loginViewController.modalPresentationStyle = .fullScreen
        present(loginViewController, animated: true, completion: nil)
    }

    @objc private func fontSizeChanged(_ sender: UISegmentedControl) {
        updateFontSize()
    }
    
    private func updateFontSize() {
        let selectedSegmentIndex = fontSizeSegmentedControl.selectedSegmentIndex
        let fontSize: CGFloat
        
        switch selectedSegmentIndex {
        case 0:
            fontSize = 14.0
        case 1:
            fontSize = 17.0
        case 2:
            fontSize = 20.0
        default:
            fontSize = 17.0
        }
        
        emailLabel.font = UIFont.systemFont(ofSize: fontSize)
        changePasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        fontSizeLabel.font = UIFont.systemFont(ofSize: fontSize)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        deleteAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
    }
}
