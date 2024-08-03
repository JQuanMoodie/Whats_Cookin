// ShoppingCartViewController.swift
// 7/17/2024
// Rachel Wu

import UIKit
import FirebaseFirestore
import FirebaseAuth
import WebKit

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
        fetchCartItems()
    }

    @objc func fetchCartItems() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        tableView.refreshControl?.beginRefreshing()
        db.collection("users").document(userId).collection("shoppingCartItems").getDocuments { [weak self] (querySnapshot, error) in
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

    @objc func didTapSearch() {
        let alert = UIAlertController(title: "Search Amazon", message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Enter search query..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { [weak self] _ in
            if let field = alert.textFields?.first, let query = field.text, !query.isEmpty {
                self?.searchAmazon(for: query)
            }
        }))
        present(alert, animated: true)
    }

    func searchAmazon(for query: String) {
        let formattedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.amazon.com/s?k=\(formattedQuery)"
        if let url = URL(string: urlString) {
            let webViewVC = WebViewController()
            webViewVC.url = url
            navigationController?.pushViewController(webViewVC, animated: true)
        }
    }

    // Enable swipe-to-delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = cartItems[indexPath.row]
            deleteCartItem(name: item)
        }
    }

    func deleteCartItem(name: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).collection("shoppingCartItems").whereField("name", isEqualTo: name).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error deleting document: \(error)")
                return
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error removing document: \(error)")
                        } else {
                            self?.fetchCartItems()
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
        return cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cartItems[indexPath.row]
        return cell
    }
}

class WebViewController: UIViewController {
    var webView: WKWebView!
    var url: URL?

    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
            webView.load(URLRequest(url: url))
        }
    }
}
