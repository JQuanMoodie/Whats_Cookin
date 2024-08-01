//  HomeViewController.swift
//  what'sCookin
//
//  Created by Raisa Methila on 7/12/24.
//  Edited : Jevon Williams
//
//import UIKit
//
//class HomeViewController: UIViewController, UITabBarDelegate, UITabBarControllerDelegate {
//
//    // MARK: - UI Elements
//
//    private let menuButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    private let profileButton: UIButton = {
//        let button = UIButton(type: .system) // Added type for system button style
//        button.setTitle("Profile", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    private let searchButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Search", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "What's cookin"
//        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let searchTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Search recipes with name or description"
//        textField.borderStyle = .roundedRect
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        return textField
//    }()
//
//    private let popularRecipesView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .lightGray
//        view.translatesAutoresizingMaskIntoConstraints = false
//        let label = UILabel()
//        label.text = "Random recipe"
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(label)
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//        return view
//    }()
//
//    private let recommendationsView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .lightGray
//        view.translatesAutoresizingMaskIntoConstraints = false
//        let label = UILabel()
//        label.text = "Random recipe"
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(label)
//        NSLayoutConstraint.activate([
//            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
//            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//        return view
//    }()
//
//    private let tabBar: UITabBar = {
//        let tabBar = UITabBar()
//        let homeItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
//        let favItem = UITabBarItem(title: "Fav", image: UIImage(systemName: "star"), tag: 1)
//        let historyItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock"), tag: 2)
//        let searchItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 3)
//        let settingsItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 4)
//        tabBar.items = [homeItem, favItem, historyItem, searchItem, settingsItem]
//        tabBar.translatesAutoresizingMaskIntoConstraints = false
//        return tabBar
//    }()
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
//
//        // Add subviews
//        view.addSubview(menuButton)
//        view.addSubview(profileButton)
//        view.addSubview(titleLabel)
//        view.addSubview(searchTextField)
//        view.addSubview(searchButton)
//        view.addSubview(popularRecipesView)
//        view.addSubview(recommendationsView)
//        view.addSubview(tabBar)
//
//        // Layout constraints
//        setupConstraints()
//
//        // Add targets
//        profileButton.addTarget(self, action: #selector(navigateToProfileView), for: .touchUpInside)
//        searchButton.addTarget(self, action: #selector(navigateToSearchViewController), for: .touchUpInside)
//
//        // Set tab bar delegate
//        tabBar.delegate = self
//    }
//
//    @objc private func navigateToProfileView() {
//        let profileViewController = ProfileViewController()
//        navigationController?.pushViewController(profileViewController, animated: true)
//    }
//
//    @objc private func navigateToSearchViewController() {
//        let searchViewController = SearchViewController() // Create SearchViewController instance
//        navigationController?.pushViewController(searchViewController, animated: true)
//    }
//
//    // MARK: - Tab Bar Delegate Method
//
//    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        switch item.tag {
//        case 0:
//            navigationController?.popToRootViewController(animated: true)
//        case 1:
//            let favoritesViewController = FavoritesViewController()
//            navigationController?.pushViewController(favoritesViewController, animated: true)
//        case 2:
//            let historyViewController = HistoryViewController()
//            navigationController?.pushViewController(historyViewController, animated: true)
//        case 3:
//            let searchViewController = SearchViewController()
//            navigationController?.pushViewController(searchViewController, animated: true)
//        case 4:
//            let settingsViewController = SettingsViewController()
//            navigationController?.pushViewController(settingsViewController, animated: true)
//        default:
//            break
//        }
//    }
//
//    // MARK: - Constraints Setup
//
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // Menu Button Constraints
//            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//
//            // Profile Button Constraints
//            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//
//            // Title Label Constraints
//            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//
//            // Search TextField Constraints
//            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
//            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            searchTextField.heightAnchor.constraint(equalToConstant: 40),
//
//            // Search Button Constraints
//            searchButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
//            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            searchButton.widthAnchor.constraint(equalToConstant: 100),
//            searchButton.heightAnchor.constraint(equalToConstant: 40),
//
//            // Popular Recipes View Constraints
//            popularRecipesView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 20),
//            popularRecipesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            popularRecipesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            popularRecipesView.heightAnchor.constraint(equalToConstant: 150),
//
//            // Recommendations View Constraints
//            recommendationsView.topAnchor.constraint(equalTo: popularRecipesView.bottomAnchor, constant: 20),
//            recommendationsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            recommendationsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            recommendationsView.heightAnchor.constraint(equalToConstant: 150),
//
//            // TabBar Constraints
//            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//    }
//}
//


import UIKit

class HomeViewController: UIViewController, UITabBarDelegate, UITabBarControllerDelegate {

    // MARK: - UI Elements

    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()

    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
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
        return view
    }()

    private let recommendationsView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    private var sideMenuViewController: SidebarViewController!
    private var isSideMenuVisible = false

    // MARK: - Properties

    private var randomRecipes: [Recipee] = []
    private let recipeService = RecipeService() // Create instance of RecipeService

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
        
        // Setup side menu
        setupSideMenu()

        // Layout constraints
        setupConstraints()

        // Add swipe gesture recognizer
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        swipeLeft.direction = .left
        sideMenuViewController.view.addGestureRecognizer(swipeLeft)

        // Add targets
        profileButton.addTarget(self, action: #selector(navigateToProfileView), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(navigateToSearchViewController), for: .touchUpInside)

        // Set tab bar delegate
        tabBar.delegate = self

        // Add tap gestures
        let popularTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPopularRecipe))
        popularRecipesView.addGestureRecognizer(popularTapGesture)
        popularRecipesView.isUserInteractionEnabled = true

        let recommendationTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapRecommendation))
        recommendationsView.addGestureRecognizer(recommendationTapGesture)
        recommendationsView.isUserInteractionEnabled = true

        // Fetch random recipes
        fetchRandomRecipes()
    }
    
    private func setupSideMenu() {
        sideMenuViewController = SidebarViewController()
        addChild(sideMenuViewController)
        view.addSubview(sideMenuViewController.view)
        sideMenuViewController.didMove(toParent: self)

        // Set the initial frame for the side menu off-screen
        sideMenuViewController.view.frame = CGRect(x: -view.frame.width * 1, y: 0, width: view.frame.width * 1, height: view.frame.height)
        sideMenuViewController.view.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
    }

    @objc private func menuButtonTapped() {
        toggleSideMenu()
    }

    private func toggleSideMenu() {
        let targetPosition: CGFloat = isSideMenuVisible ? -view.frame.width * 1 : 0
        UIView.animate(withDuration: 0.3, animations: {
            self.sideMenuViewController.view.frame.origin.x = targetPosition
        }) { _ in
            self.isSideMenuVisible.toggle()
        }
    }

    @objc private func handleSwipeLeft(_ gesture: UISwipeGestureRecognizer) {
        if isSideMenuVisible {
            toggleSideMenu()
        }
    }

    // MARK: - Navigation

    @objc private func navigateToProfileView() {
        let profileViewController = ProfileViewController()
        navigationController?.pushViewController(profileViewController, animated: true)
    }

    @objc private func navigateToSearchViewController() {
        let searchViewController = SearchViewController()
        navigationController?.pushViewController(searchViewController, animated: true)
    }

    @objc private func navigateToFavoriteViewController() {
        let favViewController = FavoritesViewController()
        navigationController?.pushViewController(favViewController, animated: true)
    }

    @objc private func navigateToHistoryViewController() {
        let hisViewController = HistoryViewController()
        navigationController?.pushViewController(hisViewController, animated: true)
    }

    @objc private func navigateToSettingsViewController() {
        let settingsViewController = SettingsViewController()
        navigationController?.pushViewController(settingsViewController, animated: true)
    }

    @objc private func didTapPopularRecipe() {
        guard let randomRecipe = randomRecipes.first else { return }
        let detailVC = RecipeDetailViewController()
        detailVC.recipe = randomRecipe
        navigationController?.pushViewController(detailVC, animated: true)
    }

    @objc private func didTapRecommendation() {
        guard randomRecipes.count > 1 else { return }
        let randomRecipe = randomRecipes[1]
        let detailVC = RecipeDetailViewController()
        detailVC.recipe = randomRecipe
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // MARK: - API Fetching

    private func fetchRandomRecipes() {
        recipeService.fetchRandomRecipes { result in
            switch result {
            case .success(let recipes):
                DispatchQueue.main.async {
                    self.randomRecipes = recipes
                    self.updateUIWithRandomRecipes()
                }
            case .failure(let error):
                print("Failed to fetch random recipes:", error)
            }
        }
    }

    private func updateUIWithRandomRecipes() {
        // Clear previous subviews
        popularRecipesView.subviews.forEach { $0.removeFromSuperview() }
        recommendationsView.subviews.forEach { $0.removeFromSuperview() }
        
        // Populate popularRecipesView
        if let firstRecipe = randomRecipes.first {
            let imageView = createRecipeImageView(for: firstRecipe)
            popularRecipesView.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: popularRecipesView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: popularRecipesView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: popularRecipesView.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: popularRecipesView.bottomAnchor)
            ])
        }

        // Populate recommendationsView
        if randomRecipes.count > 1 {
            let secondRecipe = randomRecipes[1]
            let imageView = createRecipeImageView(for: secondRecipe)
            recommendationsView.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: recommendationsView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: recommendationsView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: recommendationsView.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: recommendationsView.bottomAnchor)
            ])
        }
    }

    private func createRecipeImageView(for recipe: Recipee) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let url = URL(string: recipe.image) {
            imageView.load(url: url)
        }
        return imageView
    }

    // MARK: - Tab Bar Delegate Method

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            // Already on Home
            break
        case 1:
            navigateToFavoriteViewController()
        case 2:
            navigateToHistoryViewController()
        case 3:
            navigateToSearchViewController()
        case 4:
            navigateToSettingsViewController()
        default:
            break
        }
    }

    // MARK: - Constraints

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),

            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),

            titleLabel.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -10),

            searchButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            popularRecipesView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            popularRecipesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            popularRecipesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            popularRecipesView.heightAnchor.constraint(equalToConstant: 200),

            recommendationsView.topAnchor.constraint(equalTo: popularRecipesView.bottomAnchor, constant: 20),
            recommendationsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recommendationsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recommendationsView.heightAnchor.constraint(equalToConstant: 200),

            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// UIImageView extension to load images from URL
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
