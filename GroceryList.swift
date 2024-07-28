//Grocery List View Controller
// 7/17/2024
// Rachel Wu 


import UIKit
import FirebaseFirestore
import FirebaseAuth

class GroceryListViewController: UIViewController, UITableViewDataSource {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let db = Firestore.firestore()
    private let recipeService = RecipeService()
    
    var ingredients = [String]()
    var recipes = [Recipee]()
    var availableIngredients: [Ingredient] = [] // Store available ingredients
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grocery List"
        view.addSubview(tableView)
        tableView.dataSource = self
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(fetchItems), for: .valueChanged)
        tableView.refreshControl = control
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        fetchItems()
        
        // Button for importing missing items
        let importButton = UIButton(type: .system)
        importButton.setTitle("Import Ingredients", for: .normal)
        importButton.addTarget(self, action: #selector(importMissingIngredients), for: .touchUpInside)
        importButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        importButton.center = view.center
        view.addSubview(importButton)
        
        // Button for navigating to shopping cart
        let cartButton = UIButton(type: .system)
        cartButton.setTitle("Shopping Cart", for: .normal)
        cartButton.addTarget(self, action: #selector(openShoppingCart), for: .touchUpInside)
        cartButton.frame = CGRect(x: 0, y: 60, width: 200, height: 50)
        cartButton.center = CGPoint(x: view.center.x, y: view.center.y + 60)
        view.addSubview(cartButton)
        
        // Fetch recipes from API
        fetchRecipesFromAPI()
    }
    
    @objc func fetchItems() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        tableView.refreshControl?.beginRefreshing()
        db.collection("users").document(userId).collection("groceryItems").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            } else {
                self?.ingredients = querySnapshot?.documents.compactMap { $0.get("name") as? String } ?? []
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    @objc func didTapAdd() {
        let alert = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Enter Item..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            if let field = alert.textFields?.first, let text = field.text, !text.isEmpty {
                self?.saveItem(name: text)
            }
        }))
        present(alert, animated: true)
    }
    
    @objc func saveItem(name: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let newItem: [String: Any] = ["name": name]
        db.collection("users").document(userId).collection("groceryItems").addDocument(data: newItem) { [weak self] error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                self?.fetchItems()
            }
        }
    }
    
    @objc func importMissingIngredients() {
        let recipeIngredients = recipes.flatMap { $0.ingredients }
        let missingIngredients = determineMissingIngredients(from: recipeIngredients)
        importIngredients(ingredientNames: missingIngredients.map { $0.name })
    }
    
    func determineMissingIngredients(from recipeIngredients: [Ingredient]) -> [Ingredient] {
        return recipeIngredients.filter { recipeIngredient in
            !availableIngredients.contains(where: { $0.name == recipeIngredient.name })
        }
    }
    
    func importIngredients(ingredientNames: [String]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let batch = db.batch()
        for name in ingredientNames {
            let newItemRef = db.collection("users").document(userId).collection("groceryItems").document()
            batch.setData(["name": name], forDocument: newItemRef)
        }
        batch.commit { [weak self] error in
            if let error = error {
                print("Error writing batch: \(error)")
            } else {
                self?.fetchItems()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = ingredients[indexPath.row]
        return cell
    }
    
    func fetchRecipesFromAPI() {
        recipeService.fetchRecipes(query: "pasta") { [weak self] result in
            switch result {
            case .success(let recipes):
                self?.recipes = recipes
                print("Fetched recipes: \(recipes)")
            case .failure(let error):
                print("Error fetching recipes: \(error)")
            }
        }
    }
    
    @objc func openShoppingCart() {
        let shoppingCartVC = ShoppingCartViewController()
        navigationController?.pushViewController(shoppingCartVC, animated: true)
    }
}
