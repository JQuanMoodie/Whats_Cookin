// ShoppingCartViewController.swift
// 7/17/2024
// Rachel Wu

import UIKit
import FirebaseFirestore

class ShoppingCartViewController: UIViewController, UITableViewDataSource {

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let db = Firestore.firestore()
    
    var cartItems = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Shopping Cart"
        view.addSubview(tableView)
        tableView.dataSource = self
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(fetchCartItems), for: .valueChanged)
        tableView.refreshControl = control
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        fetchCartItems()
    }

    @objc func fetchCartItems() {
        tableView.refreshControl?.beginRefreshing()
        db.collection("shoppingCartItems").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            } else {
                self?.cartItems = querySnapshot?.documents.compactMap { $0.get("name") as? String } ?? []
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }

    @objc func didTapAdd() {
        let alert = UIAlertController(title: "Add Item to Cart", message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Enter Item..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            if let field = alert.textFields?.first, let text = field.text, !text.isEmpty {
                self?.saveCartItem(name: text)
            }
        }))
        present(alert, animated: true)
    }

    @objc func saveCartItem(name: String) {
        let newItem: [String: Any] = ["name": name]
        db.collection("shoppingCartItems").addDocument(data: newItem) { [weak self] error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                self?.fetchCartItems()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cartItems[indexPath.row]
        return cell
    }
}
