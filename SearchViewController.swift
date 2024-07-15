//
//  SearchViewController.swift
//  what'sCookin
//
//  Created by Raisa Methila on 7/12/24.
//

import UIKit

class SearchViewController: UIViewController {

    private let includeLabel: UILabel = {
        let label = UILabel()
        label.text = "Include ingredients"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let includeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Use commas to separate ingredients"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 1, alpha: 0.5)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let selectOneLabel: UILabel = {
        let label = UILabel()
        label.text = "Select one"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let orButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("or", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let andButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("and", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let excludeLabel: UILabel = {
        let label = UILabel()
        label.text = "Exclude ingredients"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let excludeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Use commas to separate ingredients"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 1, alpha: 0.5)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.backgroundColor = UIColor(white: 1, alpha: 0.5)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let saveSearchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Search", for: .normal)
        button.backgroundColor = UIColor.blue
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
  private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.backgroundColor = UIColor.blue
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1.0)

        // Add subviews
        view.addSubview(includeLabel)
        view.addSubview(includeTextField)
        view.addSubview(selectOneLabel)
        view.addSubview(orButton)
        view.addSubview(andButton)
        view.addSubview(excludeLabel)
        view.addSubview(excludeTextField)
        view.addSubview(searchButton)
        view.addSubview(saveSearchButton)
        view.addSubview(backButton)

        // Layout constraints
        setupConstraints()
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            includeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            includeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            includeTextField.topAnchor.constraint(equalTo: includeLabel.bottomAnchor, constant: 20),
            includeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            includeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            includeTextField.heightAnchor.constraint(equalToConstant: 40),

            selectOneLabel.topAnchor.constraint(equalTo: includeTextField.bottomAnchor, constant: 20),
            selectOneLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            orButton.topAnchor.constraint(equalTo: selectOneLabel.bottomAnchor, constant: 10),
            orButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            orButton.widthAnchor.constraint(equalToConstant: 60),
            orButton.heightAnchor.constraint(equalToConstant: 40),

            andButton.topAnchor.constraint(equalTo: selectOneLabel.bottomAnchor, constant: 10),
            andButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            andButton.widthAnchor.constraint(equalToConstant: 60),
            andButton.heightAnchor.constraint(equalToConstant: 40),

            excludeLabel.topAnchor.constraint(equalTo: orButton.bottomAnchor, constant: 20),
            excludeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            excludeTextField.topAnchor.constraint(equalTo: excludeLabel.bottomAnchor, constant: 20),
            excludeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            excludeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            excludeTextField.heightAnchor.constraint(equalToConstant: 40),

            searchButton.topAnchor.constraint(equalTo: excludeTextField.bottomAnchor, constant: 20),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 100),
            searchButton.heightAnchor.constraint(equalToConstant: 40),

            saveSearchButton.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 10),
            saveSearchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveSearchButton.widthAnchor.constraint(equalToConstant: 140),
            saveSearchButton.heightAnchor.constraint(equalToConstant: 40),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 100),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

