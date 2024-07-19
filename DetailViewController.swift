//
//  DetailViewController.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/16/24.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class DetailViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    private let followersLabel = UILabel()
    private let followingLabel = UILabel()
    private let searchTextField = UITextField()
    private let searchResultsTableView = UITableView()
    private var searchResults: [User] = [] // User model
    private var selectedUser: User? // Store the selected user for follow/unfollow actions

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray
        setupViews()
        searchTextField.addTarget(self, action: #selector(searchTextFieldDidChange(_:)), for: .editingChanged)
        loadUserData()
    }

    private func setupViews() {
        
        followersLabel.text = "Followers: 0"
        followingLabel.text = "Following: 0"
        followingLabel.textColor = .label
        followersLabel.textColor = .label
        
        searchTextField.placeholder = "Search for users"
        searchTextField.borderStyle = .roundedRect
        searchTextField.delegate = self
        
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(followersLabel)
        view.addSubview(followingLabel)
        view.addSubview(searchTextField)
        view.addSubview(searchResultsTableView)
        
        // Set up AutoLayout for the views
        setupConstraints()
    }

    private func setupConstraints() {
        followersLabel.translatesAutoresizingMaskIntoConstraints = false
        followingLabel.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            followersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            followersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            followingLabel.topAnchor.constraint(equalTo: followersLabel.bottomAnchor, constant: 20),
            followingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            searchTextField.topAnchor.constraint(equalTo: followingLabel.bottomAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            searchResultsTableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadUserData() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        
        // Load followers count
        db.collection("users").document(currentUserID).collection("followers").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching followers: \(error.localizedDescription)")
                return
            }
            let followersCount = snapshot?.documents.count ?? 0
            self?.followersLabel.text = "Followers: \(followersCount)"
        }

        // Load following count
        db.collection("users").document(currentUserID).collection("following").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching following: \(error.localizedDescription)")
                return
            }
            let followingCount = snapshot?.documents.count ?? 0
            self?.followingLabel.text = "Following: \(followingCount)"
        }
    }

    @objc private func searchTextFieldDidChange(_ textField: UITextField) {
        guard let searchText = textField.text, !searchText.isEmpty else {
            searchResults = []
            searchResultsTableView.reloadData()
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .whereField("username", isEqualTo: searchText)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Error searching users: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No results found.")
                    self.searchResults = []
                    self.searchResultsTableView.reloadData()
                    return
                }

                self.searchResults = documents.compactMap { document in
                    let data = document.data()
                    guard let username = data["username"] as? String else { return nil }
                    let uid = document.documentID
                    return User(uid: uid, username: username)
                }
                self.searchResultsTableView.reloadData()
            }
    }

    // UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let user = searchResults[indexPath.row]
        cell.textLabel?.text = user.username
        return cell
    }

    // UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = searchResults[indexPath.row]
        guard let selectedUser = selectedUser else { return }
        
        // Check if the current user is already following the selected user
        checkIfFollowing(userIDToCheck: selectedUser.uid) { [weak self] isFollowing in
            guard let self = self else { return }
            let actionTitle = isFollowing ? "Unfollow" : "Follow"
            self.presentFollowUnfollowAlert(user: selectedUser, actionTitle: actionTitle)
        }
    }

    private func checkIfFollowing(userIDToCheck: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).collection("following").document(userIDToCheck).getDocument { document, error in
            if let error = error {
                print("Error checking following status: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(document?.exists ?? false)
        }
    }

    private func followUser(currentUserID: String, userIDToFollow: String) {
        let db = Firestore.firestore()
        
        // Add the userIDToFollow to the following subcollection of currentUserID
        db.collection("users").document(currentUserID).collection("following").document(userIDToFollow).setData([:]) { error in
            if let error = error {
                print("Error following user: \(error.localizedDescription)")
            } else {
                print("User followed successfully.")
                self.loadUserData() // Refresh user data
            }
        }
        
        // Add the currentUserID to the followers subcollection of userIDToFollow
        db.collection("users").document(userIDToFollow).collection("followers").document(currentUserID).setData([:]) { error in
            if let error = error {
                print("Error updating followers: \(error.localizedDescription)")
            } else {
                print("Followers updated successfully.")
            }
        }
    }

    private func unfollowUser(currentUserID: String, userIDToUnfollow: String) {
        let db = Firestore.firestore()
        
        // Remove the userIDToUnfollow from the following subcollection of currentUserID
        db.collection("users").document(currentUserID).collection("following").document(userIDToUnfollow).delete { error in
            if let error = error {
                print("Error unfollowing user: \(error.localizedDescription)")
            } else {
                print("User unfollowed successfully.")
                self.loadUserData() // Refresh user data
            }
        }
        
        // Remove the currentUserID from the followers subcollection of userIDToUnfollow
        db.collection("users").document(userIDToUnfollow).collection("followers").document(currentUserID).delete { error in
            if let error = error {
                print("Error updating followers: \(error.localizedDescription)")
            } else {
                print("Followers updated successfully.")
            }
        }
    }

    private func presentFollowUnfollowAlert(user: User, actionTitle: String) {
        let alert = UIAlertController(title: nil, message: "Would you like to \(actionTitle.lowercased()) \(user.username)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { [weak self] _ in
            guard let self = self, let currentUserID = Auth.auth().currentUser?.uid else { return }
            if actionTitle == "Follow" {
                self.followUser(currentUserID: currentUserID, userIDToFollow: user.uid)
            } else {
                self.unfollowUser(currentUserID: currentUserID, userIDToUnfollow: user.uid)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// User Model
struct User {
    let uid: String
    let username: String
}



#Preview{
    DetailViewController()
}
