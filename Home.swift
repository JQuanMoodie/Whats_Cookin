//  HomeViewController.swift
//  what'sCookin
//
//  Created by Raisa Methila on 7/12/24.

import UIKit
import FirebaseFirestore
import FirebaseAuth

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITabBarDelegate, UITabBarControllerDelegate {

    // MARK: - UI Elements

    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()

    private let profileButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
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

    private var collectionView: UICollectionView!
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
        view.addSubview(tabBar)

        // Setup side menu
        setupSideMenu()

        // Setup collection view
        setupCollectionView()

        // Layout constraints
        setupConstraints()

        // Add swipe gesture recognizer
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        swipeLeft.direction = .left
        sideMenuViewController.view.addGestureRecognizer(swipeLeft)

        // Add targets
        profileButton.addTarget(self, action: #selector(navigateToProfileView), for: .touchUpInside)

        // Set tab bar delegate
        tabBar.delegate = self

        // Fetch random recipes
        fetchRandomRecipes()
    }

    private func setupSideMenu() {
        sideMenuViewController = SidebarViewController()
        addChild(sideMenuViewController)
        view.addSubview(sideMenuViewController.view)
        sideMenuViewController.didMove(toParent: self)

        // Set the initial frame for the side menu off-screen
        sideMenuViewController.view.frame = CGRect(x: -view.frame.width * 0.8, y: 0, width: view.frame.width * 0.8, height: view.frame.height)
        sideMenuViewController.view.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
    }

    @objc private func menuButtonTapped() {
        toggleSideMenu()
    }

    private func toggleSideMenu() {
        let targetPosition: CGFloat = isSideMenuVisible ? -view.frame.width * 0.8 : 0
        UIView.animate(withDuration: 0.3, animations: {
            self.sideMenuViewController.view.frame.origin.x = targetPosition
        }) { _ in
            if self.isSideMenuVisible {
                self.view.sendSubviewToBack(self.sideMenuViewController.view)
            } else {
                self.view.bringSubviewToFront(self.sideMenuViewController.view)
            }
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

    // MARK: - API Fetching

    private func fetchRandomRecipes() {
        print("Fetching random recipes...")
        fetchRecipesBatch()
    }

    private func fetchRecipesBatch() {
        recipeService.fetchRandomRecipes { [weak self] result in
            switch result {
            case .success(let recipes):
                DispatchQueue.main.async {
                    print("Fetched batch of recipes: \(recipes)")
                    self?.randomRecipes.append(contentsOf: recipes.prefix(2))
                    self?.collectionView.reloadData()
                    if self?.randomRecipes.count ?? 0 < 10 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Delay to respect API rate limits
                            self?.fetchRecipesBatch()
                        }
                    }
                }
            case .failure(let error):
                print("Failed to fetch random recipes: \(error)")
            }
        }
    }

    private func homeRecipeFetch(query: String) {
        recipeService.fetchRecipes(query: query, includeIngredients: nil, excludeIngredients: nil) { [weak self] result in
            switch result {
            case .success(let recipes):
                DispatchQueue.main.async {
                    let searchVC = HomeSearchViewController()
                    searchVC.updateSearchResults(with: Array(recipes.prefix(10))) // Limit to 10 recipes
                    self?.navigationController?.pushViewController(searchVC, animated: true)
                }
            case .failure(let error):
                print("Failed to fetch recipes: \(error)")
            }
        }
    }

    // MARK: - Collection View

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecipeCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -20)
        ])
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of items in section: \(randomRecipes.count)")
        return randomRecipes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCollectionViewCell.identifier, for: indexPath) as! RecipeCollectionViewCell
        let recipe = randomRecipes[indexPath.item]
        print("Configuring cell with recipe: \(recipe.title)")
        cell.configure(with: recipe)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 32) / 2
        return CGSize(width: width, height: width + 40)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRecipe = randomRecipes[indexPath.item]
        let detailVC = RecipeDetailViewController()
        detailVC.recipe = selectedRecipe
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // MARK: - Constraints

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),

            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: profileButton.bottomAnchor, constant: 16),

            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - UITabBarDelegate

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0: break
        case 1: navigateToFavoriteViewController()
        case 2: navigateToHistoryViewController()
        case 3: navigateToSearchViewController()
        case 4: navigateToSettingsViewController()
        default: break
        }
    }

    // MARK: - UITabBarControllerDelegate

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is HomeViewController {
            // Optionally handle when HomeViewController is selected again
        }
    }
}
