//  RecipeCell.swift
//  WhatsCookin
//
//  Created by J’Quan Moodie on 7/14/24.
//  Edited by: Raisa Methila
// Edited by: Jevon Williams


import UIKit

class RecipeCell: UITableViewCell {
    let titleLabel = UILabel()
    let recipeImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Add subviews and set up constraints
        contentView.addSubview(titleLabel)
        contentView.addSubview(recipeImageView)
        
        // Set up constraints for titleLabel and recipeImageView
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recipeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            recipeImageView.widthAnchor.constraint(equalToConstant: 100),
            recipeImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
        ])
    }

    func set(recipee: Recipee, isFavorited: Bool) {
        titleLabel.text = recipee.title
        if let imageUrl = URL(string: recipee.image) {
            recipeImageView.load(url: imageUrl)
        }
        // No button to set title for
    }
}
