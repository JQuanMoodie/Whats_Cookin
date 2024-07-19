//
//  Settings.swift
//  what'sCookin
//
//  Created by Raisa Methila on 7/19/24.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {

    // UI Elements
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email: name@gmail.com"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let changePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change password", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(changePasswordButtonTapped), for: .touchUpInside)
        return button
    }()

    private let fontSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "Font size:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let fontSizeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["small", "medium", "large"])
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log out", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray

        // Add subviews
        view.addSubview(emailLabel)
        view.addSubview(changePasswordButton)
        view.addSubview(fontSizeLabel)
        view.addSubview(fontSizeSegmentedControl)
        view.addSubview(logoutButton)

        // Layout constraints
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Email Label Constraints
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Change Password Button Constraints
            changePasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changePasswordButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            changePasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            changePasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Font Size Label Constraints
            fontSizeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fontSizeLabel.topAnchor.constraint(equalTo: changePasswordButton.bottomAnchor, constant: 20),

            // Font Size Segmented Control Constraints
            fontSizeSegmentedControl.centerYAnchor.constraint(equalTo: fontSizeLabel.centerYAnchor),
            fontSizeSegmentedControl.leadingAnchor.constraint(equalTo: fontSizeLabel.trailingAnchor, constant: 10),
            fontSizeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Logout Button Constraints
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: fontSizeSegmentedControl.bottomAnchor, constant: 40),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // Actions
    @objc private func changePasswordButtonTapped() {
        // Handle change password button tap
    }

    @objc private func logoutButtonTapped() {
        // Handle logout button tap
    }
}
