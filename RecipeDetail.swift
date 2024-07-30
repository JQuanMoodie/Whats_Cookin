//
//  RecipeDetail.swift
//  What'sCookin
//
//  Created by Raisa Methila on 7/29/24.
//

import UIKit

class RecipeDetailViewController: UIViewController {

    var recipe: Recipe? // This will hold the recipe data passed from the HomeViewController

    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ingredientsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(recipeImageView)
        view.addSubview(titleLabel)
        view.addSubview(ingredientsLabel)

        setupConstraints()
        configureView()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            recipeImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            recipeImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recipeImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recipeImageView.heightAnchor.constraint(equalToConstant: 200),

            titleLabel.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            ingredientsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            ingredientsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ingredientsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func configureView() {
        guard let recipe = recipe else { return }
        
        titleLabel.text = recipe.title
        if let imageUrl = recipe.image, let url = URL(string: imageUrl) {
            recipeImageView.load(url: url)
        }
        ingredientsLabel.text = recipe.ingredients?.joined(separator: ", ") ?? "Ingredients not available"
    }
}

// Extension to load images from URL
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}
