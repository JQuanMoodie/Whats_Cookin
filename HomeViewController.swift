//
//  HomeViewController.swift
//  what'sCookin
//
//  Created by Raisa Methila on 7/12/24.
//

import UIKit

class HomeViewController: UIViewController, UITabBarDelegate, UITabBarControllerDelegate {

    // MARK: - UI Elements

    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let profileButton: UIButton = {
        let button = UIButton(type: .system) // Added type for system button style
        button.setTitle("Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "What's cookin"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search recipes with name or description"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let popularRecipesView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = "Popular recipes"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()

    private let recommendationsView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = "Customized recommendations, depending on what the user has searched or liked before"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)

        // Add subviews
        view.addSubview(menuButton)
        view.addSubview(profileButton)
        view.addSubview(titleLabel)
        view.addSubview(searchTextField)
        view.addSubview(searchButton)
        view.addSubview(popularRecipesView)
        view.addSubview(recommendationsView)
        view.addSubview(tabBar)

        // Layout constraints
        setupConstraints()

        // Add targets
        profileButton.addTarget(self, action: #selector(navigateToProfileView), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(navigateToSearchViewController), for: .touchUpInside)
    }

    @objc private func navigateToProfileView() {
        let profileViewController = ProfileViewController()
        navigationController?.pushViewController(profileViewController, animated: true)
    }

    @objc private func navigateToSearchViewController() {
        let searchViewController = SearchViewController() // Create SearchViewController instance
        navigationController?.pushViewController(searchViewController, animated: true)
    }

    // MARK: - Constraints Setup

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Menu Button Constraints
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Profile Button Constraints
            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Title Label Constraints
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

            // Search TextField Constraints
            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchTextField.heightAnchor.constraint(equalToConstant: 40),

            // Search Button Constraints
            searchButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 100),
            searchButton.heightAnchor.constraint(equalToConstant: 40),

            // Popular Recipes View Constraints
            popularRecipesView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 20),
            popularRecipesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            popularRecipesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            popularRecipesView.heightAnchor.constraint(equalToConstant: 150),

            // Recommendations View Constraints
            recommendationsView.topAnchor.constraint(equalTo: popularRecipesView.bottomAnchor, constant: 20),
            recommendationsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recommendationsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recommendationsView.heightAnchor.constraint(equalToConstant: 150),

            // TabBar Constraints
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

