//WebViewController.swift
//8/2/24
//Rachel Wu

import UIKit
import WebKit
import FirebaseAuth
import FirebaseFirestore

class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var url: URL?

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
            webView.load(URLRequest(url: url))
        }
        setupAddToCartButton()
        setupNavigationBar()
    }

    private func setupAddToCartButton() {
        let button = UIButton(type: .system)
        button.setTitle("Add to Cart", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)

        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
    }

    @objc private func doneButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    //add item to cart
    @objc private func addToCartButtonTapped() {
        guard let currentURL = webView.url else { return }

        // makes sure that web is fully loaded before users enter page
        webView.evaluateJavaScript("document.readyState") { [weak self] result, error in
            guard let readyState = result as? String, readyState == "complete" else {
                print("Web content not fully loaded yet")
                return
            }

            self?.extractAndAddItemToCart()
        }
    }

    private func extractAndAddItemToCart() {
        webView.evaluateJavaScript("document.title") { [weak self] result, error in
            guard let title = result as? String, error == nil else {
                print("Error extracting item title: \(String(describing: error))")
                return
            }

            self?.addItemToCart(name: title)
        }
    }

    private func addItemToCart(name: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let newItem: [String: Any] = ["name": name]
        db.collection("users").document(userId).collection("shoppingCartItems").addDocument(data: newItem) { [weak self] error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                self?.showAddToCartSuccessMessage(name: name)
            }
        }
    }

    private func showAddToCartSuccessMessage(name: String) {
        let alert = UIAlertController(title: "Success", message: "\(name) has been added to your cart.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
