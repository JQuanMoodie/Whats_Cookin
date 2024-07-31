//
//  RecipeDetailView.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/30/24.
//

import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(servingsLabel)
        view.addSubview(readyInMinutesLabel)
        view.addSubview(instructionsTextView)
        
        setupConstraints()
        
        if let recipe = recipe {
            titleLabel.text = recipe.title
            if let imageUrl = URL(string: recipe.image) {
                imageView.load(url: imageUrl)
            }
            servingsLabel.text = "Servings: \(recipe.servings ?? 0)"
            readyInMinutesLabel.text = "Ready in: \(recipe.readyInMinutes ?? 0) minutes"
            instructionsTextView.text = recipe.instructions
        }
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
            instructionsTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
