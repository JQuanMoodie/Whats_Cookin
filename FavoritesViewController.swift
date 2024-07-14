//
//  FavoritesViewController.swift
//  WhatsCookin
//
//  Created by J’Quan Moodie on 7/13/24.
//

import UIKit

class FavoritesViewController: UIViewController{
    
    var tableView = UITableView()
    
    //Array of recipes in the favorite list
    var favRecipes: [Recipe] = []
    
    //function to add recipes to the favorites list
    public func addFavRecipe(recipe: Recipe){
        favRecipes.append(recipe)
    }
    
    //function to remove a recipe from the favorites list
    public func removeFavRecipe(recipe: Recipe){
        let target = recipe.name
        if let index = favRecipes.firstIndex(where: {$0.name == target}) {
            favRecipes.remove(at: index)
        }
    }
    
    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let favRecipe: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 100
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        return button
    }()
    
    private let starButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.backgroundColor = UIColor.black
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private let searchTextField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "Search Through Your Favorite Recipes"
            textField.borderStyle = .roundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            return textField
        }()
    
    private let buttonTextField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "Recipe Name"
        textField.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
            textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.zPosition = 1;
            return textField
        }()
    
    private let profileButton: UIButton = {
        let button = UIButton()
        button.setTitle("Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "What's Cookin'"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tabBar: UITabBar = {
        let tabBar = UITabBar()
        let homeItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        let favItem = UITabBarItem(title: "Fav", image: UIImage(systemName: "star"), tag: 1)
        let historyItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock"), tag: 2)
        let searchItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 3)
        let settingsItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 4)
        tabBar.items = [homeItem, favItem, historyItem, searchItem, settingsItem]
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Menu Button Constraints
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Profile Button Constraints
            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Search TextField Constraints
            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Title Label Constraints
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            // TabBar Constraints
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Table Constraints
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: searchTextField.trailingAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Grab Data
        favRecipes = fetchData()
        
        // Set Up the Page Elements
        setUpPage()
        
        // Layout Constraints
        setupConstraints()
    }
    
    private func setUpPage(){
        view.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
        view.addSubview(menuButton)
        view.addSubview(searchTextField)
        view.addSubview(profileButton)
        view.addSubview(titleLabel)
        view.addSubview(tabBar)
        configureTableView()
    }
    
    func configureTableView(){
        view.addSubview(tableView)
        setTableViewDelegate()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100;
        tableView.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
        tableView.register(RecipeCell.self, forCellReuseIdentifier: "RecipeCell")
    }
    
    func setTableViewDelegate(){
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return favRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeCell
        cell.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
        let recipe = favRecipes[indexPath.row]
        cell.set(recipe: recipe)
        //cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
    }
}

//Dummy Data
extension FavoritesViewController{
    func fetchData() -> [Recipe] {
        let recipe1 = Recipe(name: "Jamaican Oxtail with Rices and Peas")
        let recipe2 = Recipe(name: "Chef Tini's Famous Baked Macaroni and Cheese")
        let recipe3 = Recipe(name: "Southern Style Deep Fried Chicken")
        let recipe4 = Recipe(name: "Cilantro White Rice")
        let recipe5 = Recipe(name: "Nacho Chips with Spicy Guacamole")
        let recipe6 = Recipe(name: "Carne Asada Tacos with Cheese")
        let recipe7 = Recipe(name: "Black Rice with Pikliz")
        let recipe8 = Recipe(name: "Cheeseburger with Fries")
        let recipe9 = Recipe(name: "Chopped Cheese with Doritos Chips")
        let recipe10 = Recipe(name: "Heart Attack and a Kelly Tech")
        
        addFavRecipe(recipe: recipe1)
        addFavRecipe(recipe: recipe2)
        addFavRecipe(recipe: recipe3)
        addFavRecipe(recipe: recipe4)
        addFavRecipe(recipe: recipe5)
        addFavRecipe(recipe: recipe6)
        addFavRecipe(recipe: recipe7)
        addFavRecipe(recipe: recipe8)
        addFavRecipe(recipe: recipe9)
        addFavRecipe(recipe: recipe10)
        removeFavRecipe(recipe: recipe3)
        removeFavRecipe(recipe: recipe7)
        removeFavRecipe(recipe: recipe10)
        
        return favRecipes
    }
}

#Preview{
    let vc = FavoritesViewController()
    
    return vc
}
