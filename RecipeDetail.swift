//
//  RecipeDetailViewController.swift
//  What's Cookin'
//
//  Created by Jevon Williams  on 7/30/24.
//  Edited by Jose Vasquez
//  Edited by J'Quan Moodie

import UIKit
import FirebaseFirestore
import FirebaseAuth

extension NSNotification.Name {
    static let recipeFavorited = NSNotification.Name("recipeFavorited")
    static let recipeUnfavorited = NSNotification.Name("recipeUnfavorited")
    static let recipeCategorized = NSNotification.Name("recipeCategorized")
}

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
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post to Feed", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveUnderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Under", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.customBackground
        
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(servingsLabel)
        view.addSubview(readyInMinutesLabel)
        view.addSubview(instructionsTextView)
        view.addSubview(favoriteButton)
        view.addSubview(postButton)
        view.addSubview(shareButton)
        view.addSubview(saveUnderButton)
        
        setupConstraints()
        setupData()
        
        AppData.shared.addVisited(recipe: recipe!)
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        saveUnderButton.addTarget(self, action: #selector(saveUnderButtonTapped), for: .touchUpInside)
        updateFavoriteButtonTitle()
    }

    private func setupData() {
        guard let recipe = recipe else { return }
        titleLabel.text = recipe.title
        titleLabel.textColor = .customLabel
        if let imageUrl = URL(string: recipe.image) {
            imageView.load(url: imageUrl)
        }
        servingsLabel.text = "Servings: \(recipe.servings ?? 0)"
        servingsLabel.textColor = .customLabel
        readyInMinutesLabel.text = "Ready in: \(recipe.readyInMinutes ?? 0) minutes"
        readyInMinutesLabel.textColor = .customLabel
        
        instructionsTextView.text = recipe.instructions
        instructionsTextView.backgroundColor = .customBackground
        instructionsTextView.textColor = .customLabel
    }

    @objc private func favoriteButtonTapped() {
        guard let recipe = recipe else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(message: "User is not authenticated")
            return
        }

        let recipeRef = db.collection("users").document(userId).collection("favoriteRecipes").document("\(recipe.id)")
        
        recipeRef.getDocument { document, error in
            if let document = document, document.exists {
                // Unfavorite the recipe
                recipeRef.delete { error in
                    if let error = error {
                        self.showAlert(message: "Error removing favorite recipe: \(error.localizedDescription)")
                    } else {
                        NotificationCenter.default.post(name: .recipeUnfavorited, object: recipe)
                        self.updateFavoriteButtonTitle()
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
                        self.showAlert(message: "Error saving favorite recipe: \(error.localizedDescription)")
                    } else {
                        NotificationCenter.default.post(name: .recipeFavorited, object: recipe)
                        self.updateFavoriteButtonTitle()
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
                self.favoriteButton.setTitleColor(.systemRed, for: .normal)
            } else {
                self.favoriteButton.setTitle("Favorite", for: .normal)
                self.favoriteButton.setTitleColor(.customButton, for: .normal)
            }
        }
    }

    @objc private func postButtonTapped() {
    guard let recipe = recipe else { return }
    guard let currentUserID = Auth.auth().currentUser?.uid else {
        showAlert(message: "User not logged in.")
        return
    }

    let db = Firestore.firestore()
    let userRef = db.collection("users").document(currentUserID)
    
    userRef.getDocument { [weak self] (document, error) in
        if let error = error {
            self?.showAlert(message: "Error fetching user data: \(error.localizedDescription)")
            return
        }
        
        guard let document = document, document.exists,
              let userData = document.data(),
              let username = userData["username"] as? String else {
            self?.showAlert(message: "Error fetching username.")
            return
        }

        let newPostRef = db.collection("users").document(currentUserID).collection("posts").document()
        let postData: [String: Any] = [
            "title": recipe.title,
            "image": recipe.image,
            "servings": recipe.servings ?? 0,
            "readyInMinutes": recipe.readyInMinutes ?? 0,
            "instructions": recipe.instructions,
            "timestamp": Timestamp(),
            "likesCount": 0,
            "likedUsers": [],
            "authorUsername": username // Add the username here
        ]

        newPostRef.setData(postData) { [weak self] error in
            if let error = error {
                self?.showAlert(message: "Error posting: \(error.localizedDescription)")
            } else {
                self?.showAlert(message: "Post created successfully.")
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}


    @objc private func shareButtonTapped() {
        guard let recipe = recipe else { return }
        
        let recipeDetails = """
        Check out this recipe: \(recipe.title)

        Servings: \(recipe.servings ?? 0)
        Ready in: \(recipe.readyInMinutes ?? 0) minutes

        Ingredients:
        \(recipe.ingredients?.map { "\($0.name): \($0.amount) \($0.unit)" }.joined(separator: "\n") ?? "No ingredients available.")

        Instructions:
        \(recipe.instructions ?? "No instructions available.")
        """

        var items: [Any] = [recipeDetails]
        if let imageUrl = URL(string: recipe.image) {
            items.append(imageUrl)
        }
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }

    @objc private func saveUnderButtonTapped() {
        let alertController = UIAlertController(title: "Save Under", message: "Select a category", preferredStyle: .actionSheet)
        let categories = ["Breakfast", "Lunch", "Dinner", "Dessert"]

        for category in categories {
            let action = UIAlertAction(title: category, style: .default) { _ in
                self.saveRecipeUnderCategory(category: category)
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    private func saveRecipeUnderCategory(category: String) {
        guard let recipe = recipe else { return }
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(message: "User is not authenticated")
            return
        }

        let categoryRef = db.collection("users").document(userId).collection("recipeCategories").document(category)
        categoryRef.setData(["recipes": FieldValue.arrayUnion([recipe.id])], merge: true) { error in
            if let error = error {
                self.showAlert(message: "Error saving recipe under \(category): \(error.localizedDescription)")
            } else {
                self.showAlert(message: "Recipe saved under \(category).")
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            servingsLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            servingsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            servingsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            readyInMinutesLabel.topAnchor.constraint(equalTo: servingsLabel.bottomAnchor, constant: 8),
            readyInMinutesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            readyInMinutesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            instructionsTextView.topAnchor.constraint(equalTo: readyInMinutesLabel.bottomAnchor, constant: 16),
            instructionsTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionsTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            instructionsTextView.heightAnchor.constraint(equalToConstant: 150),

            favoriteButton.topAnchor.constraint(equalTo: instructionsTextView.bottomAnchor, constant: 16),
            favoriteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            postButton.topAnchor.constraint(equalTo: favoriteButton.bottomAnchor, constant: 8),
            postButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            postButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            shareButton.topAnchor.constraint(equalTo: postButton.bottomAnchor, constant: 8),
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            saveUnderButton.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: 8),
            saveUnderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveUnderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

// UIColor extension for custom colors
extension UIColor {
    static var customBackground: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        }
    }

    static var customLabel: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .lightGray : .black
        }
    }

    static var customButton: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .lightGray : .systemBlue
        }
    }
}
