//Grocery List View Controller
// 7/17/2024
// Rachel Wu 


import UIKit
import FirebaseFirestore
import FirebaseAuth

class GroceryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        tableView.delegate = self // Set delegate
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
    guard let userId = Auth.auth().currentUser?.uid else { 
        print("User not authenticated.")
        return 
    }
    let newItem: [String: Any] = ["name": name]
    db.collection("users").document(userId).collection("groceryItems").addDocument(data: newItem) { [weak self] error in
        if let error = error {
            print("Error adding document: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Error", message: "Failed to add item. Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        } else {
            self?.fetchItems()
        }
    }
}

    
    @objc func importMissingIngredients() {
        let recipeIngredients = recipes.flatMap { $0.ingredients }
        let missingIngredients = determineMissingIngredients(from: recipeIngredients)
        importIngredients(ingredients: missingIngredients)
    }
    
    func determineMissingIngredients(from recipeIngredients: [Ingredient]) -> [Ingredient] {
        return recipeIngredients.filter { recipeIngredient in
            !availableIngredients.contains(where: { $0.name == recipeIngredient.name })
        }
    }
    
    func importIngredients(ingredients: [Ingredient]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let batch = db.batch()
        for ingredient in ingredients {
            let newItemRef = db.collection("users").document(userId).collection("groceryItems").document()
            batch.setData(["name": ingredient.name], forDocument: newItemRef)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let ingredient = ingredients[indexPath.row]
        shopForIngredient(ingredient: ingredient)
    }
    
    // Enable swipe-to-delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ingredient = ingredients[indexPath.row]
            deleteItem(name: ingredient)
        }
    }
    
    func deleteItem(name: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).collection("groceryItems").whereField("name", isEqualTo: name).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error deleting document: \(error)")
                return
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error removing document: \(error)")
                        } else {
                            self?.fetchItems()
                        }
                    }
                }
            }
        }
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
    
    func shopForIngredient(ingredient: String) {
        let apiKey = "4797a64albcc4191b17e6da86f903914"
        let query = ingredient.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.spoonacular.com/food/products/search?query=\(query)&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let products = json["products"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.showProducts(products: products)
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
    func showProducts(products: [[String: Any]]) {
        let alert = UIAlertController(title: "Products Found", message: nil, preferredStyle: .actionSheet)
        for product in products {
            if let title = product["title"] as? String {
                alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                    if let productId = product["id"] as? Int {
                        self.openProductInBrowser(productId: productId)
                    }
                }))
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func openProductInBrowser(productId: Int) {
        let urlString = "https://spoonacular.com/food-products/\(productId)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}