//
//  RecipeCell.swift
//  WhatsCookin
//
//  Created by J’Quan Moodie on 7/14/24.
//

import UIKit

class RecipeCell: UITableViewCell{
    
    var recipeImageView = UIImageView()
    var recipeTitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(recipeImageView)
        addSubview(recipeTitleLabel)
        
        configureImageView()
        configureTitleLabel()
        setImageConstraints()
        setTitleLabelConstraints()
    }
    
    func set(recipe: Recipe)
    {
        recipeTitleLabel.text = recipe.name
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureImageView(){
        recipeImageView.layer.cornerRadius = 10
        recipeImageView.clipsToBounds = true
    }
    
    func configureTitleLabel(){
        recipeTitleLabel.numberOfLines = 0
        recipeTitleLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setImageConstraints(){
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        recipeImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        recipeImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        recipeImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        recipeImageView.widthAnchor.constraint(equalTo: recipeImageView.heightAnchor, multiplier: 16/9).isActive = true
    }
    
    func setTitleLabelConstraints() {
        recipeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        recipeTitleLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 20).isActive = true
        recipeTitleLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        recipeTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true

    }
}
