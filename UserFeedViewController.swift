//
//  UserFeedViewController.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/24/24.
//

import UIKit
import FirebaseFirestore

class UserFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    var recipes: [Recipes] = [] // Changed to handle multiple recipes
    let apiKey = "4797a64a1bcc4191b17e6da86f903914"
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchRecipes() // Fetch multiple recipes
    }

    func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecipeCell")
        view.addSubview(tableView)
    }

    func fetchRecipes() {
        // Adjust the API URL to fetch multiple recipes or a list
        let urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=\(apiKey)&number=10"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            // Print the raw JSON response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON Response: \(jsonString)")
            }

            do {
                let recipeResponse = try JSONDecoder().decode(RecipesResponse.self, from: data)
                self.recipes = recipeResponse.results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count // Show the number of recipes
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath)
        let recipe = recipes[indexPath.row]
        cell.textLabel?.text = recipe.title

        // Optionally set up image view or additional details
        if let imageUrl = URL(string: recipe.image) {
            URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                        cell.setNeedsLayout()
                    }
                }
            }.resume()
        }
        return cell
    }

    @objc func repostButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        let recipeToRepost = recipes[indexPath.row]

        let repostVC = RepostViewController()
        repostVC.recipe = recipeToRepost
        repostVC.db = db
        navigationController?.pushViewController(repostVC, animated: true)
    }
}

// Update Recipe struct based on the API response
struct Recipes: Codable {
    let id: Int
    let title: String
    let image: String
    // Add any additional fields based on the API response
}

struct RecipesResponse: Codable {
    let results: [Recipes]
}
