//
//  LoginViewController.swift
//  what'sCookin
//
//  Created by Raisa Methila on 7/4/24.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol LoginViewControllerDelegate: AnyObject {
    func didLoginSuccessfully(username: String)
}

class LoginViewController: UIViewController {

    weak var delegate: LoginViewControllerDelegate?

    //background image 
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "loginpage3.png"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 0.7, alpha: 1.0) // Peachy color
        textField.textColor = .black // Set text color to black 
        textField.translatesAutoresizingMaskIntoConstraints = false

        //placeholder text color
        let placeholderText = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        textField.attributedPlaceholder = placeholderText

        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 0.7, alpha: 1.0) // Peachy color
        textField.textColor = .black // Set text color to black
        textField.translatesAutoresizingMaskIntoConstraints = false

        //placeholder text color
        let placeholderText = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        textField.attributedPlaceholder = placeholderText

        return textField
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        //login button white
        //button.backgroundColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5

        button.backgroundColor = UIColor.lightGray // Set background color to light gray
        button.layer.cornerRadius = 25 // Set a higher value for a more rounded button
        button.clipsToBounds = true // Ensure subviews are clipped to the bounds

        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        //sign up button white
        //button.backgroundColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5

        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        //view.backgroundColor = .white
        //updated background image
        view.addSubview(backgroundImageView)

        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // Background image constraints
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            //width
            usernameTextField.widthAnchor.constraint(equalToConstant: 250),
            //usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            //usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            //width
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),
            //passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            //passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            //rounded 
            loginButton.widthAnchor.constraint(equalTo: usernameTextField.widthAnchor, multiplier: 0.5), // Set width to half of the username text field
            loginButton.heightAnchor.constraint(equalToConstant: 50), // Set height for consistent rounding


            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),
        ])
    }

    @objc private func loginButtonTapped() {
        guard let email = usernameTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter both email and password.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                self.showAlert(message: "Error signing in.")
                return
            }

            // If login is successful
            if let user = authResult?.user {
                self.fetchUsername(userID: user.uid) { username in
                    self.handleLoginSuccess(username: username)
                }
            }
        }
    }

    private func fetchUsername(userID: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                print("Error fetching username: \(error.localizedDescription)")
                completion("Unknown")
                return
            }

            let username = document?.data()?["username"] as? String ?? "Unknown"
            completion(username)
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

    private func handleLoginSuccess(username: String) {
        // Inform the delegate about the successful login
        delegate?.didLoginSuccessfully(username: username)
        
        // Navigate to the main view controller
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            let mainViewController = HomeViewController() // Replace with your main view controller
            mainViewController.modalPresentationStyle = .fullScreen
            window.rootViewController = mainViewController
            window.makeKeyAndVisible()
        }
    }
}