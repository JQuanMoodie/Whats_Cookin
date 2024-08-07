import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine

class ProfileViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties

    var username: String? {
        didSet {
            nameLabel.text = username ?? "John Doe"
        }
    }

    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    private let bioTextField = UITextField()
    private let statusLabel = UILabel()
    private let statusButton = UIButton()
    private let navigateButton = UIButton(type: .system)
    private var isOnline: Bool = false
    private var bioInput: String = ""
    
    let viewModel = ProfileViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        loadProfileDataFromFirestore()

        viewModel.$profileImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.profileImageView.image = image
            }
            .store(in: &cancellables)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        profileImageView.isUserInteractionEnabled = true

        bioTextField.addTarget(self, action: #selector(bioTextFieldDidChange(_:)), for: .editingChanged)
        bioTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfileDataFromFirestore()
    }

    private func setupViews() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .systemGray4

        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .label

        bioTextField.placeholder = "Write something about yourself..."
        bioTextField.font = .systemFont(ofSize: 18)
        bioTextField.borderStyle = .roundedRect
        bioTextField.backgroundColor = .systemGray6
        bioTextField.textColor = .label
        bioTextField.textAlignment = .center

        statusLabel.font = .systemFont(ofSize: 18)
        statusLabel.textColor = .label
        statusLabel.textAlignment = .center

        statusButton.titleLabel?.font = .systemFont(ofSize: 18)
        statusButton.setTitleColor(.white, for: .normal)
        statusButton.layer.cornerRadius = 10
        statusButton.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
        
        // Set initial button background color based on isOnline state
        updateStatusLabel()

        navigateButton.setTitle("View Followings & Followers", for: .normal)
        navigateButton.titleLabel?.font = .systemFont(ofSize: 18)
        navigateButton.addTarget(self, action: #selector(navigateToDetailView), for: .touchUpInside)

        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(bioTextField)
        view.addSubview(statusLabel)
        view.addSubview(statusButton)
        view.addSubview(navigateButton)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        bioTextField.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        navigateButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 15),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            bioTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            bioTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bioTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bioTextField.heightAnchor.constraint(equalToConstant: 40),

            statusLabel.topAnchor.constraint(equalTo: bioTextField.bottomAnchor, constant: 15),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statusButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 15),
            statusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusButton.widthAnchor.constraint(equalToConstant: 200),
            statusButton.heightAnchor.constraint(equalToConstant: 44),

            navigateButton.topAnchor.constraint(equalTo: statusButton.bottomAnchor, constant: 30),
            navigateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            navigateButton.widthAnchor.constraint(equalToConstant: 200),
            navigateButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func bioTextFieldDidChange(_ textField: UITextField) {
        bioInput = textField.text ?? ""
        saveProfileDataToFirestore()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func selectProfileImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    @objc private func statusButtonTapped() {
        isOnline.toggle()
        saveProfileDataToFirestore()
        updateStatusLabel()
    }

    private func updateStatusLabel() {
        statusLabel.text = isOnline ? "Ready To Cook!" : "Offline"
        statusButton.setTitle(isOnline ? "Offline" : "Ready To Cook!", for: .normal)
        statusButton.backgroundColor = isOnline ? .systemBlue : .systemRed
    }

    @objc private func navigateToDetailView() {
        let detailViewController = DetailViewController()
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func saveProfileDataToFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(userId)
        let profileData: [String: Any] = [
            "username": username ?? "",
            "bio": bioInput,
            "isOnline": isOnline,
            "profileImageURL": viewModel.profileImageURL ?? ""
        ]
        userRef.setData(profileData, merge: true) { error in
            if let error = error {
                print("Error saving profile data: \(error)")
            }
        }
    }

    func loadProfileDataFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Error loading profile data: \(error)")
            } else if let document = document, document.exists {
                let data = document.data()
                self?.username = data?["username"] as? String
                self?.bioInput = data?["bio"] as? String ?? ""
                self?.isOnline = data?["isOnline"] as? Bool ?? false
                if let profileImageURL = data?["profileImageURL"] as? String {
                    self?.viewModel.loadProfileImage(from: profileImageURL)
                    self?.viewModel.profileImageURL = profileImageURL
                }
                DispatchQueue.main.async {
                    self?.nameLabel.text = self?.username
                    self?.bioTextField.text = self?.bioInput
                    self?.updateStatusLabel()
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveProfileDataToFirestore()
    }
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
        nameLabel.text = username
    }
}
