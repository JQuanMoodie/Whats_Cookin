//
//  PostViewController.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/26/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class PostViewController: UIViewController {

    private let postTextField = UITextField()
    private let postButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
    }

    private func setupViews() {
        postTextField.placeholder = "Enter your post content"
        postTextField.borderStyle = .roundedRect
        postTextField.autocapitalizationType = .sentences
        postTextField.returnKeyType = .done
        postTextField.delegate = self
        
        postButton.setTitle("Post", for: .normal)
        postButton.addTarget(self, action: #selector(handlePostButtonTapped), for: .touchUpInside)
        
        view.addSubview(postTextField)
        view.addSubview(postButton)

        postTextField.translatesAutoresizingMaskIntoConstraints = false
        postButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            postTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            postTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            postTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            postButton.topAnchor.constraint(equalTo: postTextField.bottomAnchor, constant: 20),
            postButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

   @objc private func handlePostButtonTapped() {
    guard let content = postTextField.text, !content.isEmpty,
          let currentUserID = Auth.auth().currentUser?.uid else {
        showAlert(message: "Post content is empty or user not logged in.")
        return
    }

    let db = Firestore.firestore()
    let userRef = db.collection("users").document(currentUserID)
    
    userRef.getDocument { [weak self] (document, error) in
        if let error = error {
            self?.showAlert(message: "Error fetching user data: \(error.localizedDescription)")
            return
        }
        
        guard let document = document, document.exists,
              let userData = document.data(),
              let username = userData["username"] as? String else {
            self?.showAlert(message: "Error fetching username.")
            return
        }

        let newPostRef = db.collection("users").document(currentUserID).collection("posts").document()
        let postData: [String: Any] = [
            "content": content,
            "timestamp": Timestamp(),
            "likesCount": 0, // Initialize likesCount to 0
            "likedUsers": [], // Initialize likedUsers as an empty array
            "authorUsername": username // Add the username here
        ]

        newPostRef.setData(postData) { [weak self] error in
            if let error = error {
                self?.showAlert(message: "Error posting: \(error.localizedDescription)")
            } else {
                self?.showAlert(message: "Post created successfully.") { [weak self] in
                    self?.postTextField.text = ""
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension PostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handlePostButtonTapped()
        return true
    }
}


