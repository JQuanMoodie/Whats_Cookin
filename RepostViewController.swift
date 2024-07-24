//
//  RepostViewController.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/24/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class RepostViewController: UIViewController {
    var recipe: Recipes?
    var recipeLabel: UILabel!
    var repostButton: UIButton!
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    func setupUI() {
        recipeLabel = UILabel(frame: CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 100))
        recipeLabel.text = recipe?.title ?? "No recipe title"
        recipeLabel.numberOfLines = 0
        recipeLabel.textAlignment = .center
        view.addSubview(recipeLabel)

        repostButton = UIButton(type: .system)
        repostButton.setTitle("Repost", for: .normal)
        repostButton.frame = CGRect(x: 20, y: 220, width: view.bounds.width - 40, height: 50)
        repostButton.addTarget(self, action: #selector(repostButtonTapped), for: .touchUpInside)
        view.addSubview(repostButton)
    }

    @objc func repostButtonTapped() {
        guard let recipe = recipe else {
            print("No recipe data available")
            return
        }

        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        let repostData: [String: Any] = [
            "id": recipe.id,
            "title": recipe.title,
            "image": recipe.image,
            "timestamp": FieldValue.serverTimestamp()
        ]

        // Debug print to ensure data being sent is correct
        print("Reposting data: \(repostData)")

        let userRef = db.collection("users").document(userID)
        userRef.updateData([
            "reposts": FieldValue.arrayUnion([repostData])
        ]) { error in
            if let error = error {
                print("Error reposting recipe: \(error.localizedDescription)")
            } else {
                print("Recipe reposted successfully")
                // Optionally, navigate back to the previous screen
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}


