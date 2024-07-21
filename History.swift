//
//  History.swift
//  What'sCookin
//
//  Created by Raisa Methila on 7/21/24.
//


import Foundation
import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let recipes = [
        "Jamaican Oxtail with Rice and Peas",
        "Chef Tini's Famous Baked Macaroni & Cheese",
        "Cilantro White Rice",
        "Nacho Chips with Spicy Guacamole",
        "Carne Asada Tacos with Cheese",
        "Smashed Cheeseburger with Fries"
    ]
    
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 1.0, green: 0.745, blue: 0.631, alpha: 1.0) // Matching background color
        setupNavigationBar()
        setupTableView()
    }

    func setupNavigationBar() {
        self.navigationItem.title = "What's Cookin'"
        let profileButton = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = profileButton
    }
    
    func setupTableView() {
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = UIColor.clear // Match table background to view background
        
        let headerLabel = UILabel()
        headerLabel.text = "You last visited"
        headerLabel.textAlignment = .center
        headerLabel.backgroundColor = UIColor.systemOrange
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        headerLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 50) // Set frame size for header
        tableView.tableHeaderView = headerLabel
        
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        cell.recipeLabel.text = recipes[indexPath.row]
        return cell
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
            historyIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
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
