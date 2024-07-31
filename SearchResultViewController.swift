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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        
        if onlyInclude {
            recipeService.fetchRecipes(query: query, includeIngredients: nil, excludeIngredients: nil) { [weak self] result in
                switch result {
                case .success(let recipes):
                    DispatchQueue.main.async {
                        self?.recipes = recipes
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    print("Failed to fetch recipes: \(error)")
                }
            }
        } else {
            recipeService.fetchRecipes(query: query, includeIngredients: query, excludeIngredients: exclude) { [weak self] result in
                switch result {
                case .success(let recipes):
                    DispatchQueue.main.async {
                        self?.recipes = recipes
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    print("Failed to fetch recipes: \(error)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let recipe = recipes[indexPath.row]
        cell.textLabel?.text = recipe.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let detailViewController = RecipeDetailViewController()
        detailViewController.recipe = recipes[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
