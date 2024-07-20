//Grocery List View Controller
// 7/17/2024
// Rachel Wu 


import CloudKit
import UIKit

class GroceryListViewController: UIViewController, UITableViewDataSource {

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()


    //edit this
    private let database = CKContainer.default().publicCloudDatabase
    //                                         ^
    
    var ingredients = [String]()
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
    }

    //fetching item to screen
    @objc func fetchItems(){
        tableView.refreshControl?.beginRefreshing()
        let query = CKQuery(recordType: "GroceryItem", predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            guard let records = records, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self?.ingredients = records.compactMap({ $0.value(forKey: "name") as? String })
                self?.tableView.reloadData()
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }

    //adding items
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

    @objc func saveItem(name: String){
        let record = CKRecord(recordType: "GroceryItem")
        record.setValue(name, forKey: "name")
        database.save(record) { [weak self] record, error in
            if record != nil, error == nil {
                DispatchQueue.main.asyncAfter(deadline: .now()+2){
                    self?.fetchItems()
                }
            }
        }
    }

    // Import missing ingredients
    func importIngredients(ingredientNames: [String]) {
        let records = ingredientNames.map { name -> CKRecord in
            let record = CKRecord(recordType: "GroceryItem")
            record.setValue(name, forKey: "name")
            return record
        }
        let operation = CKModifyRecordsOperation(recordsToSave: records)
        operation.modifyRecordsCompletionBlock = { [weak self] savedRecords, deletedRecordIDs, error in
            if error == nil {
                DispatchQueue.main.async {
                    self?.fetchItems()
                }
            }
        }
        database.add(operation)
    }

    //missing ingredients from user input
    func determineMissingIngredients(from recipeIngredients: [String]) -> [String] {
        return recipeIngredients.filter { !ingredients.contains($0) }
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    //TABLE 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = ingredients[indexPath.row]
        return cell
    }
}

let groceryListVC = GroceryListViewController()
let allIngredients = ["Tomatoes", "Onions", "Garlic", "Peppers"]
let recipeIngredients = ["Tomatoes", "Garlic", "Basil", "Olive Oil"]
let missingIngredients = groceryListVC.determineMissingIngredients(from: recipeIngredients)
groceryListVC.importIngredients(ingredientNames: missingIngredients)