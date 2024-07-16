//
//  ProfileUIView.swift
//  UserProfile
//
//  Created by Jevon Williams on 7/9/24.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let bioTextField = UITextField()
    private let statusLabel = UILabel()
    private let statusButton = UIButton()
    private let navigateButton = UIButton(type: .system)
    private var isOnline: Bool = UserDefaults.standard.bool(forKey: "isOnlineStatus")
    private var bioInput: String = UserDefaults.standard.string(forKey: "userInput") ?? ""

    let viewModel = ProfileViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        // Setup initial values
        nameLabel.text = "John Doe"
        bioTextField.text = bioInput
        updateStatusLabel()

        // Load the profile image and apply it to the image view
        viewModel.loadProfileImage()
        if let profileImage = viewModel.profileImage {
            profileImageView.image = profileImage
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        profileImageView.isUserInteractionEnabled = true

        bioTextField.addTarget(self, action: #selector(bioTextFieldDidChange(_:)), for: .editingChanged)
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

        navigateButton.setTitle("Go to Detail View", for: .normal)
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

            navigateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            navigateButton.topAnchor.constraint(equalTo: statusButton.bottomAnchor, constant: 20)
        ])
    }

    @objc private func bioTextFieldDidChange(_ textField: UITextField) {
        bioInput = textField.text ?? ""
        UserDefaults.standard.set(bioInput, forKey: "userInput")
    }

    @objc private func selectProfileImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    @objc private func statusButtonTapped() {
        isOnline.toggle()
        UserDefaults.standard.set(isOnline, forKey: "isOnlineStatus")
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.set(bioTextField.text, forKey: "userInput")
        if let image = profileImageView.image {
            viewModel.saveProfileImage(image: image)
        }
    }
}

extension ProfileViewController {
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


#Preview{
    ProfileViewController()
}


