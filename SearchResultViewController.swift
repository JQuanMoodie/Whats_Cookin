//
//  SearchResultViewController.swift
//  WhatsCookin
//
//  Created by J’Quan Moodie on 7/29/24.
//

import UIKit

class SearchResultViewController: UIViewController {

    // View of the table representing the results of the search
    var tableView = UITableView()

    // String representing the user's search
    var des: String?

    // An instance of the recipe API
    private let recipeService = RecipeService()

    // An array of the results of the search
    var recipes: [Recipee] = []

    // Creating the page title
    private let includeLabel: UILabel = {
        let label = UILabel()
        label.text = "Search Results"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            // Title Constraints
            includeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            includeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Table Constraints
            tableView.topAnchor.constraint(equalTo: includeLabel.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Grab Search Results
        if let query = des {
            fetchRecipesFromAPI(query: query)
        }

        // Set Up Page Elements
        view.backgroundColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1.0)
        view.addSubview(includeLabel)
        configureTableView()

        // Layout constraints
        setUpConstraints()
    }

    // Aligns the table with the rest of the elements
    func configureTableView() {
        view.addSubview(tableView)
        setTableViewDelegate()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100
        tableView.backgroundColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1.0)
        tableView.register(RecipeCell.self, forCellReuseIdentifier: "RecipeCell")
        tableView.showsVerticalScrollIndicator = false
    }

    func setTableViewDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    // Implementing API from RecipeAPIService.swift
    func fetchRecipesFromAPI(query: String) {
        recipeService.fetchRecipes(query: query) { [weak self] result in
            switch result {
            case .success(let recipes):
                self?.recipes = recipes
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                print("Fetched recipes: \(recipes)")
            case .failure(let error):
                print("Error fetching recipes: \(error)")
            }
        }
    }
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {

    // Setting the number of rows for the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    // Setting the data for each data cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        let recipe = recipes[indexPath.row]
        cell.set(recipee: recipe)
        cell.backgroundColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1.0)
        return cell
    }

    // Setting the action for when the user clicks the table cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle table cell selection
    }
}

