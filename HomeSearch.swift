//
//  HomeSearch.swift
//  What'sCookin
//
//  Created by Raisa Methila on 8/1/24.
//
import UIKit

class HomeSearchResultViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    private var collectionView: UICollectionView!
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Modify your search"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let modifySearchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(modifySearchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var searchResults: [Recipee] = []
    var searchQuery: String? // Add this property to receive the search query
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 240/255, green: 180/255, blue: 150/255, alpha: 1)
        
        setupSearchTextField()
        setupModifySearchButton()
        setupCollectionView()
        setupConstraints()
        
        // Perform the search when the view loads
        if let query = searchQuery {
            searchRecipes(query: query)
        }
    }

    private func setupSearchTextField() {
        view.addSubview(searchTextField)
        searchTextField.delegate = self
    }
    
    private func setupModifySearchButton() {
        view.addSubview(modifySearchButton)
    }
    
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
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: modifySearchButton.leadingAnchor, constant: -10),
            
            modifySearchButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            modifySearchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func modifySearchButtonTapped() {
        guard let query = searchTextField.text, !query.isEmpty else {
            print("Search query is empty")
            return
        }
        
        searchRecipes(query: query)
    }
    
    private func searchRecipes(query: String) {
        let recipeService = RecipeService() // Assuming RecipeService is a service class for fetching recipes
        recipeService.fetchRecipes(query: query, includeIngredients: nil, excludeIngredients: nil) { [weak self] result in
            switch result {
            case .success(let recipes):
                DispatchQueue.main.async {
                    self?.searchResults = recipes
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print("Failed to search recipes: \(error)")
            }
        }
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let query = textField.text, !query.isEmpty {
            searchRecipes(query: query)
        }
        return true
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCollectionViewCell.identifier, for: indexPath) as! RecipeCollectionViewCell
        let recipe = searchResults[indexPath.item]
        cell.configure(with: recipe)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 32) / 2
        return CGSize(width: width, height: width + 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRecipe = searchResults[indexPath.item]
        let detailVC = RecipeDetailViewController()
        detailVC.recipe = selectedRecipe
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
