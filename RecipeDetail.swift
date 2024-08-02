//
//  RecipeDetail.swift
//  What'sCookin
//
//  Created by Raisa Methila on 7/29/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class RecipeDetailViewController: UIViewController {
    var recipe: Recipee?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let servingsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let readyInMinutesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let instructionsTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Favorite", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(servingsLabel)
        view.addSubview(readyInMinutesLabel)
        view.addSubview(instructionsTextView)
        view.addSubview(favoriteButton)
        
        setupConstraints()
        setupData()
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        updateFavoriteButtonTitle()
    }

    private func setupData() {
        guard let recipe = recipe else { return }
        titleLabel.text = recipe.title
        if let imageUrl = URL(string: recipe.image) {
            imageView.load(url: imageUrl)
        }
        servingsLabel.text = "Servings: \(recipe.servings ?? 0)"
        readyInMinutesLabel.text = "Ready in: \(recipe.readyInMinutes ?? 0) minutes"
        instructionsTextView.text = recipe.instructions
    }

    @objc private func favoriteButtonTapped() {
        guard let recipe = recipe else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated")
            return
        }

        let recipeRef = db.collection("users").document(userId).collection("favoriteRecipes").document("\(recipe.id)")
        
        recipeRef.getDocument { document, error in
            if let document = document, document.exists {
                // Unfavorite the recipe
                recipeRef.delete { error in
                    if let error = error {
                        print("Error removing favorite recipe: \(error.localizedDescription)")
                    } else {
                        print("Recipe removed from favorites")
                        NotificationCenter.default.post(name: .recipeUnfavorited, object: recipe)
                        self.navigateToFavoritesView()
                    }
                }
            } else {
                // Favorite the recipe
                let favoriteRecipeData: [String: Any] = [
                    "id": recipe.id,
                    "title": recipe.title,
                    "image": recipe.image,
                    "servings": recipe.servings ?? 0,
                    "readyInMinutes": recipe.readyInMinutes ?? 0,
                    "ingredients": recipe.ingredients?.map { [
                        "id": $0.id.uuidString,
                        "name": $0.name,
                        "amount": $0.amount,
                        "unit": $0.unit
                    ] } ?? [],
                    "instructions": recipe.instructions ?? ""
                ]
                
                recipeRef.setData(favoriteRecipeData) { error in
                    if let error = error {
                        print("Error saving favorite recipe: \(error.localizedDescription)")
                    } else {
                        print("Recipe saved as favorite")
                        NotificationCenter.default.post(name: .recipeFavorited, object: recipe)
                        self.navigateToFavoritesView()
                    }
                }
            }
        }
    }

    private func updateFavoriteButtonTitle() {
        guard let recipe = recipe else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let recipeRef = db.collection("users").document(userId).collection("favoriteRecipes").document("\(recipe.id)")

        recipeRef.getDocument { document, error in
            if let document = document, document.exists {
                self.favoriteButton.setTitle("Unfavorite", for: .normal)
            } else {
                self.favoriteButton.setTitle("Favorite", for: .normal)
            }
        }
    }

    private func navigateToFavoritesView() {
        // Assuming FavoritesViewController is the view controller that displays favorite recipes
        let favoritesViewController = FavoritesViewController()
        navigationController?.pushViewController(favoritesViewController, animated: true)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            servingsLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            servingsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            readyInMinutesLabel.topAnchor.constraint(equalTo: servingsLabel.bottomAnchor, constant: 10),
            readyInMinutesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            instructionsTextView.topAnchor.constraint(equalTo: readyInMinutesLabel.bottomAnchor, constant: 20),
            instructionsTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionsTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            instructionsTextView.bottomAnchor.constraint(equalTo: favoriteButton.topAnchor, constant: -20),
            
            favoriteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            favoriteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension UIColor {
    static var customBackground: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        }
    }

    static var customLabel: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
    }

    static var customButton: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemBlue
        }
    }
}

extension Notification.Name {
    static let recipeFavorited = Notification.Name("recipeFavorited")
    static let recipeUnfavorited = Notification.Name("recipeUnfavorited")
}
