//
//  RecipeCell.swift
//  WhatsCookin
//
//  Created by J’Quan Moodie on 7/14/24.
//

import UIKit

struct Recipe{
    var name: String
    var ingredients: [String] = []
    var favorited: Bool = false
}

class RecipeCell: UITableViewCell{
    
    //Recipe Name
    var recipeTitleLabel = UILabel()
    //Button for favoriting/unfavoriting
    let button = UIButton()
    
    //Organizes how the table cell looks
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(recipeTitleLabel)
        contentView.addSubview(button)
        
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        configureTitleLabel()
        setTitleLabelConstraints()
    }
    
    //Grabs the name of the recipe to display in the table
    func set(recipe: Recipe)
    {
        recipeTitleLabel.text = recipe.name
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }

    //Sets up of the name of the recipe will look
    func configureTitleLabel(){
        recipeTitleLabel.numberOfLines = 0
        recipeTitleLabel.adjustsFontSizeToFitWidth = true
    }
    
    //Aligns the name of the recipe in the table cell
    func setTitleLabelConstraints() {
        recipeTitleLabel.translatesAutoresizingMaskIntoConstraints                              = false
        recipeTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive              = true
        recipeTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
        recipeTitleLabel.heightAnchor.constraint(equalToConstant: 80).isActive                  = true
        recipeTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive            = true

    }
}
