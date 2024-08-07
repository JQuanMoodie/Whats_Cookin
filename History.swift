//
//  History.swift
//  What'sCookin
//
//  Created by Raisa Methila on 7/21/24.
//  Edited by J'Quan Moodie
//


import Foundation
import UIKit

class AppData {
    static let shared = AppData()
    var visitedRecipes: [String] = []
    var visitedRecipeObjects: [Recipee] = []

    func addVisited(recipe: Recipee){
        var found = false
        var index = 0
        for i in 0..<visitedRecipes.count{
            if visitedRecipes[i] == recipe.title
            {
                found = true
                index = i
            }
        }
        if visitedRecipes.count == 10
        {
            if found
            {
                visitedRecipes.remove(at: index)
                visitedRecipes.insert(recipe.title, at: 0)
                visitedRecipeObjects.remove(at: index)
                visitedRecipeObjects.insert(recipe, at: 0)
            }
            else
            {
                visitedRecipes.insert(recipe.title, at: 0)
                visitedRecipes.remove(at: 10)
                visitedRecipeObjects.insert(recipe, at: 0)
                visitedRecipeObjects.remove(at: 10)
            }
        }
        else
        {
            if found
            {
                visitedRecipes.remove(at: index)
                visitedRecipes.insert(recipe.title, at: 0)
                visitedRecipeObjects.remove(at: index)
                visitedRecipeObjects.insert(recipe, at: 0)
            }
            else
            {
                visitedRecipes.insert(recipe.title, at: 0)
                visitedRecipeObjects.insert(recipe, at: 0)
            }
        }
    }
    
    private init() {} // Prevents others from creating instances
}

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
        view.addSubview(profileButton)
        view.addSubview(titleLabel)
        setupTableView()
        
        NSLayoutConstraint.activate([
            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        profileButton.addTarget(self, action: #selector(navigateToProfileView), for: .touchUpInside)

    }
    
    func setupTableView() {
        //tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let headerLabel = UILabel()
        headerLabel.text = "Recently Viewed Recipes"
        headerLabel.textAlignment = .center
        headerLabel.backgroundColor = UIColor.systemOrange
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        headerLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 50) // Set frame size for header
        
        tableView.tableHeaderView = headerLabel
        
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppData.shared.visitedRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        cell.recipeLabel.text = AppData.shared.visitedRecipes[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipeDetailVC = RecipeDetailViewController()
        recipeDetailVC.recipe = AppData.shared.visitedRecipeObjects[indexPath.row]
        navigationController?.pushViewController(recipeDetailVC, animated: true)
    }
    
    @objc private func navigateToProfileView() {
        let profileViewController = ProfileViewController()
        navigationController?.pushViewController(profileViewController, animated: true)
    }
}

class Cell: UITableViewCell {
    
    let historyIcon: UIImageView
    let recipeLabel: UILabel
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        historyIcon = UIImageView(image: UIImage(systemName: "clock"))
        recipeLabel = UILabel()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        historyIcon.translatesAutoresizingMaskIntoConstraints = false
        recipeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(historyIcon)
        contentView.addSubview(recipeLabel)
        
        // Customize cell background and selection color
        contentView.backgroundColor = UIColor(red: 1.0, green: 0.745, blue: 0.631, alpha: 1.0)
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 0.9, green: 0.6, blue: 0.4, alpha: 1.0)
        self.selectedBackgroundView = selectedBackgroundView
        
        NSLayoutConstraint.activate([
            historyIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            historyIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            historyIcon.widthAnchor.constraint(equalToConstant: 20),
            historyIcon.heightAnchor.constraint(equalToConstant: 20),
            
            recipeLabel.leadingAnchor.constraint(equalTo: historyIcon.trailingAnchor, constant: 15),
            recipeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            recipeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
