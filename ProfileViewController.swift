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
        view.backgroundColor = .systemGray
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
        loadProfileDataFromFirestore() // Ensure the profile data is loaded every time the view appears
    }

    private func setupViews() {
        // Setup code for views ...

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 40
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .systemGray4

        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textColor = .label // Adjusts to dark mode

        bioTextField.placeholder = "Bio"
        bioTextField.font = .systemFont(ofSize: 20)
        bioTextField.borderStyle = .roundedRect
        bioTextField.backgroundColor = .secondarySystemBackground // Adjusts to dark mode
        bioTextField.textColor = .label // Adjusts to dark mode

        statusLabel.font = .systemFont(ofSize: 20)
        statusLabel.textColor = .systemRed

        statusButton.titleLabel?.font = .systemFont(ofSize: 20)
        statusButton.setTitleColor(.white, for: .normal)
        statusButton.layer.cornerRadius = 10
        statusButton.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)

        navigateButton.setTitle("Followings and Followers", for: .normal)
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

            navigateButton.topAnchor.constraint(equalTo: statusButton.bottomAnchor, constant: 20),
            navigateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            navigateButton.widthAnchor.constraint(equalToConstant: 200),
            navigateButton.heightAnchor.constraint(equalToConstant: 65), // Adjust height as needed
            
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
        statusButton.backgroundColor = isOnline ? .blue : .red
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
            "profileImageURL": viewModel.profileImageURL ?? "" // Save the URL of the profile image
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
                    self?.viewModel.profileImageURL = profileImageURL // Update the view model's profileImageURL
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
            viewModel.saveProfileImage(image: image) // Save the image using the view model
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
