//
//  SearchViewController.swift
//  what'sCookin
//
//  Created by Raisa Methila on 7/12/24.
//  Edited by J'Quan Moodie

import UIKit

class SearchViewController: UIViewController {
    private let recipeService = RecipeService()
    var onlyInclude = true

    private let includeLabel: UILabel = {
        let label = UILabel()
        label.text = "Search With Ingredients"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let includeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Use Commas to Separate Ingredients"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 1, alpha: 0.5)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let selectOneLabel: UILabel = {
        let label = UILabel()
        label.text = "Excluding Ingredients"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let orButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("No", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let andButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Yes", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let excludeLabel: UILabel = {
        let label = UILabel()
        label.text = "List Them Here"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let excludeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Use Commas to Separate Ingredients"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 1, alpha: 0.5)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(includeLabel)
        view.addSubview(includeTextField)
        view.addSubview(selectOneLabel)
        view.addSubview(orButton)
        view.addSubview(andButton)
        view.addSubview(excludeLabel)
        view.addSubview(excludeTextField)
        view.addSubview(searchButton)
        
        setupConstraints()
        
        orButton.addTarget(self, action: #selector(handleButtonClick), for: .touchUpInside)
        andButton.addTarget(self, action: #selector(handleButtonClick), for: .touchUpInside)
    }

    @objc private func handleButtonClick(_ sender: UIButton) {
        if sender == orButton {
            onlyInclude = true
            orButton.backgroundColor = .gray
            andButton.backgroundColor = .white
        } else {
            onlyInclude = false
            orButton.backgroundColor = .white
            andButton.backgroundColor = .gray
        }
    }

    @objc private func didTapSearchButton() {
        let searchResultVC = SearchResultViewController()
        searchResultVC.query = includeTextField.text
        searchResultVC.exclude = excludeTextField.text
        searchResultVC.onlyInclude = onlyInclude
        navigationController?.pushViewController(searchResultVC, animated: true)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            includeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            includeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            includeTextField.topAnchor.constraint(equalTo: includeLabel.bottomAnchor, constant: 10),
            includeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            includeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            selectOneLabel.topAnchor.constraint(equalTo: includeTextField.bottomAnchor, constant: 20),
            selectOneLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            orButton.topAnchor.constraint(equalTo: selectOneLabel.bottomAnchor, constant: 10),
            orButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            orButton.widthAnchor.constraint(equalToConstant: 100),
            
            andButton.topAnchor.constraint(equalTo: selectOneLabel.bottomAnchor, constant: 10),
            andButton.leadingAnchor.constraint(equalTo: orButton.trailingAnchor, constant: 10),
            andButton.widthAnchor.constraint(equalToConstant: 100),
            
            excludeLabel.topAnchor.constraint(equalTo: andButton.bottomAnchor, constant: 20),
            excludeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            excludeTextField.topAnchor.constraint(equalTo: excludeLabel.bottomAnchor, constant: 10),
            excludeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            excludeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchButton.topAnchor.constraint(equalTo: excludeTextField.bottomAnchor, constant: 20),
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
}

