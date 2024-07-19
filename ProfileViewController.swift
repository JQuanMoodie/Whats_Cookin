import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController, UITextFieldDelegate {

    var username: String? {
        didSet {
            nameLabel.text = username ?? "John Doe"
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let bioTextField = UITextField()
    private let statusLabel = UILabel()
    private let statusButton = UIButton()
    private let followButton = UIButton(type: .system)
    private let navigateButton = UIButton(type: .system)
    private var isOnline: Bool = UserDefaults.standard.bool(forKey: "isOnlineStatus")
    private var bioInput: String = UserDefaults.standard.string(forKey: "userInput") ?? ""
    private var isFollowing: Bool = UserDefaults.standard.bool(forKey: "isFollowingStatus")

    let viewModel = ProfileViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        // Fetch username from UserDefaults and display it
        if let savedUsername = UserDefaults.standard.string(forKey: "username") {
            username = savedUsername
        }

        bioTextField.text = bioInput
        updateStatusLabel()
        //updateFollowButton()

        viewModel.loadProfileImage()
        if let profileImage = viewModel.profileImage {
            profileImageView.image = profileImage
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        profileImageView.isUserInteractionEnabled = true

        bioTextField.addTarget(self, action: #selector(bioTextFieldDidChange(_:)), for: .editingChanged)
        bioTextField.delegate = self

        /*Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.checkFollowingStatus(for: user.uid)
            } else {
                self?.followButton.isHidden = true
            }
        }*/
    }

    private func setupViews() {
        view.backgroundColor = .white

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 40
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .systemGray4

        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textColor = .black

        bioTextField.placeholder = "Bio"
        bioTextField.font = .systemFont(ofSize: 20)
        bioTextField.borderStyle = .roundedRect
        bioTextField.backgroundColor = .clear

        statusLabel.font = .systemFont(ofSize: 20)
        statusLabel.textColor = .red

        statusButton.titleLabel?.font = .systemFont(ofSize: 20)
        statusButton.setTitleColor(.white, for: .normal)
        statusButton.layer.cornerRadius = 10
        statusButton.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)

        /*followButton.titleLabel?.font = .systemFont(ofSize: 20)
        followButton.setTitle("Follow", for: .normal)
        followButton.addTarget(self, action: #selector(handleFollowButtonTapped), for: .touchUpInside)
        followButton.backgroundColor = .blue
        followButton.setTitleColor(.white, for: .normal)
        followButton.layer.cornerRadius = 10*/

        navigateButton.setTitle("Go to Detail View", for: .normal)
        navigateButton.addTarget(self, action: #selector(navigateToDetailView), for: .touchUpInside)

        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(bioTextField)
        view.addSubview(statusLabel)
        view.addSubview(statusButton)
        //view.addSubview(followButton)
        view.addSubview(navigateButton)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        bioTextField.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        //followButton.translatesAutoresizingMaskIntoConstraints = false
        navigateButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            bioTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            bioTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bioTextField.widthAnchor.constraint(equalToConstant: 300),
            bioTextField.heightAnchor.constraint(equalToConstant: 40),

            statusLabel.topAnchor.constraint(equalTo: bioTextField.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statusButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            statusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusButton.widthAnchor.constraint(equalToConstant: 200),
            statusButton.heightAnchor.constraint(equalToConstant: 44),

            /*followButton.topAnchor.constraint(equalTo: statusButton.bottomAnchor, constant: 20),
            followButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            followButton.widthAnchor.constraint(equalToConstant: 200),
            followButton.heightAnchor.constraint(equalToConstant: 50),*/

            navigateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            navigateButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            navigateButton.widthAnchor.constraint(equalToConstant: 200),
            navigateButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    @objc private func bioTextFieldDidChange(_ textField: UITextField) {
        bioInput = textField.text ?? ""
        UserDefaults.standard.set(bioInput, forKey: "userInput")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func selectProfileImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self // Delegate assignment here
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    @objc private func statusButtonTapped() {
        isOnline.toggle()
        UserDefaults.standard.set(isOnline, forKey: "isOnlineStatus")
        updateStatusLabel()
    }

    /*@objc private func handleFollowButtonTapped() {
        guard let user = Auth.auth().currentUser else {
            print("User is not logged in")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        let followedUserId = "someUserId" // Replace with the actual user ID you want to follow

        userRef.collection("following").document(followedUserId).getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                userRef.collection("following").document(followedUserId).delete { error in
                    if let error = error {
                        print("Error unfollowing user: \(error)")
                    } else {
                        self?.isFollowing = false
                        self?.updateFollowButton()
                        UserDefaults.standard.set(self?.isFollowing, forKey: "isFollowingStatus")
                    }
                }
            } else {
                userRef.collection("following").document(followedUserId).setData([:]) { error in
                    if let error = error {
                        print("Error following user: \(error)")
                    } else {
                        self?.isFollowing = true
                        self?.updateFollowButton()
                        UserDefaults.standard.set(self?.isFollowing, forKey: "isFollowingStatus")
                    }
                }
            }
        }
    }*/

    /*private func updateFollowButton() {
        followButton.setTitle(isFollowing ? "Following" : "Follow", for: .normal)
        followButton.backgroundColor = isFollowing ? .gray : .blue
    }*/

    private func updateStatusLabel() {
        statusLabel.text = isOnline ? "Ready To Cook!" : "Offline"
        statusButton.setTitle(isOnline ? "Offline" : "Ready To Cook!", for: .normal)
        statusButton.backgroundColor = isOnline ? .blue : .red
    }

    @objc private func navigateToDetailView() {
        let detailViewController = DetailViewController()
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.set(bioTextField.text, forKey: "userInput")
        if let image = profileImageView.image {
            viewModel.saveProfileImage(image: image)
        }
    }

   /* func checkFollowingStatus(for userId: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)
        let followedUserId = userId

        userRef.collection("following").document(followedUserId).getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                self?.isFollowing = true
            } else {
                self?.isFollowing = false
            }
            self?.updateFollowButton()
        }
    }*/
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage {
            profileImageView.image = image
            viewModel.saveProfileImage(image: image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: LoginViewControllerDelegate {
    func didLoginSuccessfully(username: String) {
        self.username = username
        nameLabel.text = username // Update nameLabel text
        // Additional setup or UI updates based on the username
    }
}


