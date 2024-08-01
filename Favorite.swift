
//  FavoritesViewController.swift
//  WhatsCookin
//
//  Created by J’Quan Moodie on 7/13/24.
//  Edited by Raisa Methila
//  Edited by Jevon Williams

import UIKit
import FirebaseAuth

protocol FavoritesViewControllerDelegate: AnyObject {
    func homeTabTapped()
}

class FavoritesViewController: UIViewController {

    weak var delegate: FavoritesViewControllerDelegate?
    private let recipeService = RecipeService()
    var tableView = UITableView()
    var favRecipes: [Recipee] = []

    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search Through Your Favorite Recipes"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
        view.addSubview(menuButton)
        view.addSubview(searchTextField)
        view.addSubview(profileButton)
        view.addSubview(titleLabel)
        configureTableView()
        setupConstraints()

        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: searchTextField.trailingAnchor),
        ])
    }

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
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

        recipeService.fetchFavoriteRecipes(userId: userId) { [weak self] result in
            switch result {
            case .success(let recipes):
                DispatchQueue.main.async {
                    self?.favRecipes = recipes
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch recipes: \(error)")
            }
        }
    }

    @objc private func profileButtonTapped() {
        // Handle profile button tap, transition to profile screen
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        let recipe = favRecipes[indexPath.row]

        cell.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
        cell.set(recipee: recipe, isFavorited: true)

        let action = UIAction { _ in
            self.removeFavRecipe(recipe: recipe)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle table cell selection
    }
}

extension FavoritesViewController {
    func addFavRecipe(recipe: Recipee) {
        favRecipes.append(recipe)
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated")
            return
        }
        recipeService.saveRecipeToFavorites(recipe: recipe, userId: userId) { result in
            switch result {
            case .success:
                print("Recipe added to favorites successfully.")
            case .failure(let error):
                print("Failed to add recipe to favorites: \(error)")
            }
        }
    }

    func removeFavRecipe(recipe: Recipee) {
        if let index = favRecipes.firstIndex(where: { $0.id == recipe.id }) {
            favRecipes.remove(at: index)
            guard let userId = Auth.auth().currentUser?.uid else {
                print("User is not authenticated")
                return
            }
            recipeService.removeRecipe(recipeId: recipe.id, userId: userId) { result in
                switch result {
                case .success:
                    print("Recipe removed successfully.")
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print("Error removing recipe: \(error)")
                }
            }
        }
    }
}
