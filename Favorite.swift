

//  FavoritesViewController.swift
//  WhatsCookin
//
//  Created by J’Quan Moodie on 7/13/24.
//  Edited by Raisa Methila
//  Edited by Jevon Williams

import UIKit
import FirebaseAuth

class FavoritesViewController: UIViewController {
    private let recipeService = RecipeService()
    var tableView = UITableView()
    var favRecipes: [Recipee] = []
    var searchedRecipes: [Recipee] = []
    private var sideMenuViewController: SidebarViewController!
    private var isSideMenuVisible = false

    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search Favorites Using The Title"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let profileButton: UIButton = {
        let button = UIButton()
        button.setTitle("Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "What's Cookin'"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
        setupUI()
        fetchFavoriteRecipes()
    }

    private func setupUI() {
        view.addSubview(searchTextField)
        view.addSubview(searchButton)
        view.addSubview(profileButton)
        view.addSubview(titleLabel)
        configureTableView()
        setupConstraints()
        
        // Add targets
        profileButton.addTarget(self, action: #selector(navigateToProfileView), for: .touchUpInside)
        
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: searchTextField.topAnchor),
            searchButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: 5),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchButton.bottomAnchor.constraint(equalTo: searchTextField.bottomAnchor),

            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tag = 1
        tableView.rowHeight = 100
        tableView.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
        tableView.register(RecipeCell.self, forCellReuseIdentifier: "RecipeCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }

    private func fetchFavoriteRecipes() {
    guard let userId = Auth.auth().currentUser?.uid else {
        print("User is not authenticated")
        return
    }

    print("Fetching favorite recipes for user: \(userId)")

    recipeService.fetchFavoriteRecipes(userId: userId) { [weak self] result in
        switch result {
        case .success(let recipes):
            print("Fetched recipes: \(recipes)")
            DispatchQueue.main.async {
                self?.favRecipes = recipes
                self?.tableView.reloadData()
            }
        case .failure(let error):
            print("Failed to fetch recipes: \(error)")
        }
    }
}

    @objc private func navigateToProfileView() {
        let profileViewController = ProfileViewController()
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    @objc private func searchButtonTapped() {
        let search = searchTextField.text ?? ""
        let searchTableView = UITableView()
        tableView.removeFromSuperview()
        searchedRecipes = []
        if search != ""
        {
            for recipe in favRecipes
            {
                if recipe.title.contains(search)
                {
                    searchedRecipes.append(recipe)
                }
            }
            searchTableView.translatesAutoresizingMaskIntoConstraints = false
            searchTableView.rowHeight = 100
            searchTableView.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
            searchTableView.register(RecipeCell.self, forCellReuseIdentifier: "RecipeCell")
            searchTableView.showsVerticalScrollIndicator = false
            searchTableView.delegate = self
            searchTableView.dataSource = self
            view.addSubview(searchTableView)
            NSLayoutConstraint.activate([
                searchTableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
                searchTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                searchTableView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor),
                searchTableView.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor),
            ])
        }
        else
        {
            configureTableView()
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor),
            ])
        }
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1
        {
            return favRecipes.count
        }
        else
        {
            return searchedRecipes.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
            let recipe = favRecipes[indexPath.row]

            cell.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
            cell.set(recipee: recipe, isFavorited: true)

            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
            let recipe = searchedRecipes[indexPath.row]

            cell.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
            cell.set(recipee: recipe, isFavorited: true)

            return cell
        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1
        {
            let recipeDetailVC = RecipeDetailViewController()
            recipeDetailVC.recipe = favRecipes[indexPath.row]
            navigationController?.pushViewController(recipeDetailVC, animated: true)
        }
        else
        {
            let recipeDetailVC = RecipeDetailViewController()
            recipeDetailVC.recipe = searchedRecipes[indexPath.row]
            navigationController?.pushViewController(recipeDetailVC, animated: true)
        }
        
    }
}
