//Grocery List View Controller
// 7/17/2024
// Rachel Wu 

import UIKit
import FirebaseFirestore
import FirebaseAuth

// GroceryListViewController managing the table view
class GroceryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(GroceryListCell.self, forCellReuseIdentifier: "GroceryListCell")
        tableView.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0) // Peach color
        return tableView
    }()
    
    private let db = Firestore.firestore()
    
    var ingredients = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grocery List"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(fetchItems), for: .valueChanged)
        tableView.refreshControl = control
        
        // Add Edit and Cart buttons to the navigation bar
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd)),
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditing))
        ]
        
        fetchItems()
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
    
    // Toggle editing mode for the table view
    @objc func toggleEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    // Handle selecting a row to either edit or purchase the item
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let ingredient = ingredients[indexPath.row]
        presentPurchaseOrEditOption(for: ingredient, at: indexPath)
    }
    
    // Present options to either edit or purchase the item
    func presentPurchaseOrEditOption(for ingredient: String, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Options", message: "Would you like to edit or purchase this item?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
            self?.presentEditItemAlert(for: ingredient, at: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Purchase", style: .default, handler: { [weak self] _ in
            self?.confirmAndMoveItemToCart(name: ingredient, at: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    // Confirm and then move the item to the shopping cart and delete it from the grocery list
    func confirmAndMoveItemToCart(name: String, at indexPath: IndexPath) {
        let confirmAlert = UIAlertController(title: "Confirm Purchase", message: "Are you sure you want to purchase \(name) and remove it from your grocery list?", preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.moveItemToCart(name: name, at: indexPath)
        }))
        present(confirmAlert, animated: true)
    }
    
    // Move the item to the shopping cart and delete it from the grocery list
    func moveItemToCart(name: String, at indexPath: IndexPath) {
        addToShoppingCart(name: name) { [weak self] success in
            if success {
                self?.deleteItem(name: name, at: indexPath)
            }
        }
    }
    
    func addToShoppingCart(name: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let newItem: [String: Any] = ["name": name]
        db.collection("users").document(userId).collection("shoppingCartItems").addDocument(data: newItem) { error in
            if let error = error {
                print("Error adding to shopping cart: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // Update the item in Firestore
    func updateItem(name: String, at indexPath: IndexPath) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let oldName = ingredients[indexPath.row]
        
        db.collection("users").document(userId).collection("groceryItems")
            .whereField("name", isEqualTo: oldName)
            .getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else if let document = querySnapshot?.documents.first {
                    document.reference.updateData(["name": name]) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            self?.ingredients[indexPath.row] = name
                            DispatchQueue.main.async {
                                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                            }
                        }
                    }
                }
            }
    }
    
    // Enable swipe-to-delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ingredient = ingredients[indexPath.row]
            deleteItem(name: ingredient, at: indexPath)  // Ensure the deletion works with the index path
        }
    }
    
    // Delete the item from Firestore and the local list
    func deleteItem(name: String, at indexPath: IndexPath) {
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
                            self?.ingredients.remove(at: indexPath.row)
                            DispatchQueue.main.async {
                                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                            }
                        }
                    }
                }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryListCell", for: indexPath) as! GroceryListCell
        cell.textLabel?.text = ingredients[indexPath.row]
        return cell
    }
}

//checkbox
class GroceryListCell: UITableViewCell {
    
    let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(checkboxButton)
        contentView.addSubview(textLabel!) // Explicitly add textLabel to the contentView
        
        // Position the checkbox on the left side
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 30),
            checkboxButton.heightAnchor.constraint(equalToConstant: 30)
            //fix overlap
            textLabel!.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 10),
            textLabel!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            textLabel!.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        checkboxButton.addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func toggleCheckbox() {
        checkboxButton.isSelected.toggle()
    }
}
extension GroceryListViewController {
    
    // Present an alert to edit the item
    func presentEditItemAlert(for ingredient: String, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.text = ingredient
            field.placeholder = "Enter Item..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            if let field = alert.textFields?.first, let newText = field.text, !newText.isEmpty {
                self?.updateItem(name: newText, at: indexPath)
            }
        }))
        present(alert, animated: true)
    }
}

