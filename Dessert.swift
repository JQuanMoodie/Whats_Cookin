//
//  DessertViewController.swift
//  capstoneproj
//
//  Created by Raisa Methila on 08/07/24.
//

import UIKit

class DessertViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var collectionView: UICollectionView!
    private var dessertRecipes: [Recipee] = []
    private let recipeService = RecipeService()
    private let maxRecipes = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemPink // Dessert-themed background color

        setupTitleLabel()
        setupDescriptionLabel()
        setupCollectionView()
        fetchDessertRecipes()
    }

    private func setupTitleLabel() {
        titleLabel.text = "Dessert Delight!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 36)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupDescriptionLabel() {
        descriptionLabel.text = "Indulge in our sweet treats and desserts. Discover a variety of delectable desserts to satisfy your sweet tooth and end your meal on a sweet note."
        descriptionLabel.font = UIFont.systemFont(ofSize: 18)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
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

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

    private func fetchDessertRecipes() {
        fetchRecipesRecursively()
    }

    private func fetchRecipesRecursively() {
        guard dessertRecipes.count < maxRecipes else {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            return
        }

        recipeService.fetchRandomDessertRecipes { [weak self] result in
            switch result {
            case .success(let recipes):
                self?.dessertRecipes.append(contentsOf: recipes)
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
                DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                    self?.fetchRecipesRecursively()
                }
            case .failure(let error):
                print("Failed to fetch dessert recipes: \(error)")
                DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                    self?.fetchRecipesRecursively()
                }
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dessertRecipes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCollectionViewCell.identifier, for: indexPath) as! RecipeCollectionViewCell
        let recipe = dessertRecipes[indexPath.item]
        cell.configure(with: recipe)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 32) / 2
        return CGSize(width: width, height: width + 40)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRecipe = dessertRecipes[indexPath.item]
        let detailVC = RecipeDetailViewController()
        detailVC.recipe = selectedRecipe
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
