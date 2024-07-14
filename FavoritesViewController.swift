//
//  FavoritesViewController.swift
//  WhatsCookin
//
//  Created by J’Quan Moodie on 7/13/24.
//

import UIKit

class FavoritesViewController: UIViewController{
    
    //View of the table representing the favorite recipes
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
    
    //Creating Menu button
    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Creating the Search Text Box
    private let searchTextField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "Search Through Your Favorite Recipes"
            textField.borderStyle = .roundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            return textField
        }()
    
    //Creating the Profile Button
    private let profileButton: UIButton = {
        let button = UIButton()
        button.setTitle("Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Creating the app title
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "What's Cookin'"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //Creating the bottom tab
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
        
        //Grab Dummy Data For Testing
        favRecipes = fetchData()
        
        // Set Up the Page Elements
        setUpPage()
        
        // Layout Constraints
        setupConstraints()
    }
    
    //Adds all page elemeents to the screen
    private func setUpPage(){
        view.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
        view.addSubview(menuButton)
        view.addSubview(searchTextField)
        view.addSubview(profileButton)
        view.addSubview(titleLabel)
        view.addSubview(tabBar)
        configureTableView()
    }
    
    //Aligns the table with the rest of the elements
    func configureTableView(){
        view.addSubview(tableView)
        setTableViewDelegate()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100;
        tableView.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
        tableView.register(RecipeCell.self, forCellReuseIdentifier: "RecipeCell")
        tableView.showsVerticalScrollIndicator = false
    }
    
    func setTableViewDelegate(){
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource{
    
    //Setting the number of rows for the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return favRecipes.count
    }
    
    //Setting the data for each data cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeCell
        let recipe = favRecipes[indexPath.row]
        
        cell.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
        cell.set(recipe: recipe)
        
        let action = UIAction{action in
            self.removeFavRecipe(recipe: recipe)
        }
        cell.button.addAction(action, for: .touchUpInside)
        
        return cell
    }
    
    //Setting the Action for when the user clicks the table cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//Dummy Data for Testing
extension FavoritesViewController{
    func fetchData() -> [Recipe] {
        let recipe1 = Recipe(name: "Jamaican Oxtail with Rices and Peas")
        let recipe2 = Recipe(name: "Chef Tini's Famous Baked Macaroni & Cheese")
        let recipe3 = Recipe(name: "Southern Style Deep Fried Chicken")
        let recipe4 = Recipe(name: "Cilantro White Rice")
        let recipe5 = Recipe(name: "Nacho Chips with Spicy Guacamole")
        let recipe6 = Recipe(name: "Carne Asada Tacos with Cheese")
        let recipe7 = Recipe(name: "Chicago Style Deep Dish Pizza")
        let recipe8 = Recipe(name: "Smashed Cheeseburger with Fries")
        let recipe9 = Recipe(name: "Fettuccine Alfredo with Grilled Chicken")
        let recipe10 = Recipe(name: "New York Style Cheesecake")
        
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

#Preview {
    FavoritesViewController()
}
