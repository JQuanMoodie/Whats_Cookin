//
//  RecipeDetail.swift
//  What'sCookin
//
//  Created by Raisa Methila on 7/29/24.
//  Edited by Jevon Williams
//  Edited by Jose Vasquez
//  Edited by J'Quan Moodie
//  Edited by Rachel Wu


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
        label.numberOfLines = 0 // Allow label to wrap text
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
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .customButton
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.customButton.cgColor
        button.layer.borderWidth = 1
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.backgroundColor = UIColor.darkerColor(for: .customButton) // Use the darkerColor method
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.cyan.cgColor
        button.layer.borderWidth = 1
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share", for: .normal)
        button.backgroundColor = UIColor.darkerColor(for: .customButton) // Use the darkerColor method
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.cyan.cgColor
        button.layer.borderWidth = 1
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let db = Firestore.firestore()

    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.customBackground
        
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(servingsLabel)
        view.addSubview(readyInMinutesLabel)
        view.addSubview(instructionsTextView)
        view.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(favoriteButton)
        buttonStackView.addArrangedSubview(postButton)
        buttonStackView.addArrangedSubview(shareButton)
        
        setupConstraints()
        setupData()
        
        AppData.shared.addVisited(recipe: recipe!)
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
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

        if let rawInstructions = recipe.instructions {
            let cleanedInstructions = formatInstructions(rawInstructions)
            instructionsTextView.text = cleanedInstructions
        } else {
            instructionsTextView.text = "No instructions available."
        }

        instructionsTextView.backgroundColor = .customBackground
        instructionsTextView.textColor = .customLabel
    }

    // Add the formatInstructions function here
    private func formatInstructions(_ rawInstructions: String) -> String {
        // Remove HTML tags and format the instructions
        let instructionSteps = rawInstructions
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }

        // Format the steps with numbers and add line gaps
        var formattedInstructions = ""
        for (index, step) in instructionSteps.enumerated() {
            formattedInstructions += "\(index + 1). \(step.trimmingCharacters(in: .whitespacesAndNewlines))\n\n"
        }

        return formattedInstructions.trimmingCharacters(in: .whitespacesAndNewlines)
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
                self.favoriteButton.setTitleColor(.white, for: .normal)
                self.favoriteButton.backgroundColor = .systemRed
            } else {
                self.favoriteButton.setTitle("Favorite", for: .normal)
                self.favoriteButton.setTitleColor(.white, for: .normal)
                self.favoriteButton.backgroundColor = .customButton
            }
        }
    }

    @objc private func postButtonTapped() {
        guard let recipe = recipe else { return }
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            showAlert(message: "User not logged in.")
            return
        }
        
        // Fetch the current user's document to get the username
        let userRef = db.collection("users").document(currentUserID)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let username = document.data()?["username"] as? String ?? "Unknown"
                
                let userPostsRef = self.db.collection("users").document(currentUserID).collection("posts")
                
                let newPost: [String: Any] = [
                    "title": recipe.title,
                    "image": recipe.image,
                    "servings": recipe.servings ?? 0,
                    "readyInMinutes": recipe.readyInMinutes ?? 0,
                    "instructions": recipe.instructions ?? "",
                    "content": "\(recipe.title) recipe.",
                    "timestamp": FieldValue.serverTimestamp(),
                    "authorID": currentUserID,
                    "authorUsername": username,
                    "isRepost": false,
                    "likesCount": 0
                ]
                
                userPostsRef.addDocument(data: newPost) { error in
                    if let error = error {
                        self.showAlert(message: "Error posting to feed: \(error.localizedDescription)")
                    } else {
                        NotificationCenter.default.post(name: .recipeCategorized, object: recipe)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                self.showAlert(message: "User data not found.")
            }
        }
    }

    @objc private func shareButtonTapped() {
        guard let recipe = recipe else { return }
        
        let shareText = "Check out this recipe: \(recipe.title)"
        let shareURL = URL(string: recipe.image) ?? URL(string: "https://www.example.com")!
        
        let activityViewController = UIActivityViewController(activityItems: [shareText, shareURL], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact]
        
        present(activityViewController, animated: true, completion: nil)
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
            instructionsTextView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),

            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}



extension UIColor {
    static var customBackground: UIColor {
        return UIColor(named: "CustomBackground") ?? UIColor.systemBackground
    }
    
    static var customLabel: UIColor {
        return UIColor(named: "CustomLabel") ?? UIColor.label
    }
    
    static var customButton: UIColor {
        return UIColor(named: "CustomButton") ?? UIColor.systemBlue
    }
    
    static func darkerColor(for color: UIColor) -> UIColor {
        guard let components = color.cgColor.components, components.count >= 3 else {
            return color
        }
        
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        return UIColor(red: red * 0.8, green: green * 0.8, blue: blue * 0.8, alpha: 1.0)
    }
}