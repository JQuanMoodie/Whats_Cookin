//
//  SearchResultViewController.swift
//  WhatsCookin
//
//  Created by J’Quan Moodie on 7/29/24.
//

import UIKit

class SearchResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var query: String?
    var exclude: String?
    var onlyInclude = true
    var recipes: [Recipee] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RecipeCell.self, forCellReuseIdentifier: "RecipeCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let recipeService = RecipeService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        fetchRecipes()
    }
    
    private func fetchRecipes() {
        let includeIngredients = onlyInclude ? query : nil
        let excludeIngredients = onlyInclude ? exclude : nil
        
        recipeService.fetchRecipes(query: query, includeIngredients: includeIngredients, excludeIngredients: excludeIngredients) { [weak self] result in
            switch result {
            case .success(let recipes):
                DispatchQueue.main.async {
                    print("Recipes fetched successfully: \(recipes)")
                    self?.recipes = recipes
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error fetching recipes: \(error)")
                    self?.showAlert(message: "Failed to fetch recipes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as? RecipeCell else {
            return UITableViewCell()
        }
        
        let recipe = recipes[indexPath.row]
        cell.set(recipee: recipe, isFavorited: false)  // Update this based on your app's logic for favorited state
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let detailViewController = RecipeDetailViewController()
        detailViewController.recipe = recipes[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

