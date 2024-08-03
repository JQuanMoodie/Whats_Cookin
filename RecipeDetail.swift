//
//  RecipeDetailView.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/30/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

extension NSNotification.Name {
    static let recipeFavorited = NSNotification.Name("recipeFavorited")
    static let recipeUnfavorited = NSNotification.Name("recipeUnfavorited")
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
        
        setupConstraints()
        setupData()
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
        updateFavoriteButtonTitle()
    }

   private func setupData() {
    guard let recipe = recipe else { return }
    titleLabel.text = recipe.title
    titleLabel.textColor = .customLabel
    if let imageUrl = URL(string: recipe.image) {
        imageView.load(url: imageUrl) // Ensure this method correctly loads images
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

        let newPostRef = db.collection("users").document(currentUserID).collection("posts").document()
        let postData: [String: Any] = [
            "title": recipe.title,
            "image": recipe.image,
            "servings": recipe.servings ?? 0,
            "readyInMinutes": recipe.readyInMinutes ?? 0,
            "instructions": recipe.instructions,
            "timestamp": Timestamp(),
            "likesCount": 0,
            "likedUsers": []
        ]

        newPostRef.setData(postData) { [weak self] error in
            if let error = error {
                self?.showAlert(message: "Error posting: \(error.localizedDescription)")
            } else {
                self?.showAlert(message: "Recipe posted successfully.") { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
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
            
            favoriteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            favoriteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            postButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
