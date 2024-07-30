//
//  SearchViewController.swift
//  what'sCookin
//
//  Created by Raisa Methila on 7/12/24.
//  Edited by J'Quan Moodie

import UIKit

class SearchViewController: UIViewController {

    private let recipeService = RecipeService()
    var ingredients = [String]()
    var recipes = [Recipee]()
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
        
        // Layout constraints
        setupConstraints()
        
        searchButton.addTarget(self, action: #selector(navigateToSearchResultViewController), for: .touchUpInside)
        orButton.addTarget(self, action: #selector(updateOr), for: .touchUpInside)
        andButton.addTarget(self, action: #selector(updateAnd), for: .touchUpInside)
    }
    
    //Update the user's choice to or
    @objc private func updateOr() {
        onlyInclude = true;
        orButton.backgroundColor = UIColor.gray
        andButton.backgroundColor = UIColor.white
    }
    
    //Update the user's choice to and
    @objc private func updateAnd() {
        onlyInclude = false;
        orButton.backgroundColor = UIColor.white
        andButton.backgroundColor = UIColor.gray
    }
    
    //Change the view to the results of the recipe search
    @objc private func navigateToSearchResultViewController() {
        // Create SearchResultViewController instance
        let searchResultViewController = SearchResultViewController()
        
        //Checking if the or button or and button is clicked
        if onlyInclude
        {
            //Checking to see if the include text box is empty and alerting if it is
            if includeTextField.text == nil || includeTextField.text == ""
            {
                let alert = UIAlertController(title: "Problem", message: "Empty Search Value", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                searchResultViewController.des = includeTextField.text!
                navigationController?.pushViewController(searchResultViewController, animated: true)
            }
        }
        else
        {
            //Checking to see if the include and exclude text box is empty and alerting if it is
            if includeTextField.text == nil || includeTextField.text == "" || excludeTextField.text == nil || excludeTextField.text == ""
            {
                let alert = UIAlertController(title: "Problem", message: "Empty Search Value", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                searchResultViewController.des = includeTextField.text!
                navigationController?.pushViewController(searchResultViewController, animated: true)
            }
        }
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
        ])
    }
}

#Preview {
    SearchViewController()
}
