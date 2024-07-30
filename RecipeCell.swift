//
//  RecipeCell.swift
//  WhatsCookin
//
//  Created by J’Quan Moodie on 7/14/24.
//  Edited by: Raisa Methila

//import UIKit
//
//struct Recipe{
//    var name: String
//    var ingredients: [String] = []
//    var favorited: Bool = false
//}
//
//class RecipeCell: UITableViewCell{
//    
//    //Recipe Name
//    var recipeTitleLabel = UILabel()
//    //Button for favoriting/unfavoriting
//    let button = UIButton()
//    
//    //Organizes how the table cell looks
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        addSubview(recipeTitleLabel)
//        contentView.addSubview(button)
//        
//        button.setImage(UIImage(systemName: "star"), for: .normal)
//        button.isUserInteractionEnabled = true
//        button.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            button.centerYAnchor.constraint(equalTo: centerYAnchor)
//        ])
//        
//        configureTitleLabel()
//        setTitleLabelConstraints()
//    }
//    
//    //Grabs the name of the recipe to display in the table
//    func set(recipe: Recipe)
//    {
//        recipeTitleLabel.text = recipe.name
//    }
//    
//    required init?(coder: NSCoder){
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    //Sets up of the name of the recipe will look
//    func configureTitleLabel(){
//        recipeTitleLabel.numberOfLines = 0
//        recipeTitleLabel.adjustsFontSizeToFitWidth = true
//    }
//    
//    //Aligns the name of the recipe in the table cell
//    func setTitleLabelConstraints() {
//        recipeTitleLabel.translatesAutoresizingMaskIntoConstraints                              = false
//        recipeTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive              = true
//        recipeTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
//        recipeTitleLabel.heightAnchor.constraint(equalToConstant: 80).isActive                  = true
//        recipeTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive            = true
//
//    }
//}


import UIKit

class RecipeCell: UITableViewCell {
    static let identifier = "RecipeCell"

    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(recipeImageView)
        contentView.addSubview(titleLabel)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            recipeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            recipeImageView.widthAnchor.constraint(equalToConstant: 60),
            recipeImageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    func configure(with recipe: Recipe) {
        titleLabel.text = recipe.title
        if let imageUrl = recipe.image, let url = URL(string: imageUrl) {
            recipeImageView.load(url: url)
        } else {
            recipeImageView.image = nil
        }
    }
}

// Extension to load images from URL
//extension UIImageView {
//    func load(url: URL) {
//        DispatchQueue.global().async { [weak self] in
//            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self?.image = image
//                }
//            }
//        }
//    }
//}
