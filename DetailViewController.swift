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
    private let feedButton = UIButton(type: .system)
    private let postButton = UIButton(type: .system)
    private var searchResults: [User] = []
    private var selectedUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        searchTextField.addTarget(self, action: #selector(searchTextFieldDidChange(_:)), for: .editingChanged)
        loadUserData()
    }
    
    private func setupViews() {
        followersLabel.text = "Followers: 0"
        followingLabel.text = "Following: 0"
        followersLabel.textColor = .label
        followingLabel.textColor = .label
        
        searchTextField.placeholder = "Search for users"
        searchTextField.borderStyle = .roundedRect
        searchTextField.delegate = self
        
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        feedButton.setTitle("Feed", for: .normal)
        feedButton.addTarget(self, action: #selector(handleFeedButtonTapped), for: .touchUpInside)
        
        postButton.setTitle("Post", for: .normal)
        postButton.addTarget(self, action: #selector(handlePostButtonTapped), for: .touchUpInside)
        
        view.addSubview(followersLabel)
        view.addSubview(followingLabel)
        view.addSubview(searchTextField)
        view.addSubview(searchResultsTableView)
        view.addSubview(feedButton)
        view.addSubview(postButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        followersLabel.translatesAutoresizingMaskIntoConstraints = false
        followingLabel.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        feedButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            followersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            followersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            followingLabel.topAnchor.constraint(equalTo: followersLabel.bottomAnchor, constant: 10),
            followingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            searchTextField.topAnchor.constraint(equalTo: followingLabel.bottomAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            feedButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            feedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            postButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            postButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchResultsTableView.topAnchor.constraint(equalTo: feedButton.bottomAnchor, constant: 20),
            searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadUserData() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        // Load followers count
        db.collection("users").document(currentUserID).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists, let data = document.data() {
                let followersCount = data["followersCount"] as? Int ?? 0
                let followingCount = data["followingCount"] as? Int ?? 0
                self?.followersLabel.text = "Followers: \(followersCount)"
                self?.followingLabel.text = "Following: \(followingCount)"
            }
        }
    }
    
    @objc private func searchTextFieldDidChange(_ textField: UITextField) {
        guard let searchText = textField.text, !searchText.isEmpty else {
            searchResults = []
            searchResultsTableView.reloadData()
            return
        }
        searchUsers(withText: searchText)
    }
    
    private func searchUsers(withText searchText: String) {
        let db = Firestore.firestore()
        db.collection("users").whereField("username", isGreaterThanOrEqualTo: searchText).getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error searching users: \(error.localizedDescription)")
                return
            }
            self?.searchResults = snapshot?.documents.compactMap { document -> User? in
                let data = document.data()
                guard let username = data["username"] as? String else { return nil }
                let uid = document.documentID
                return User(uid: uid, username: username)
            } ?? []
            self?.searchResultsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = searchResults[indexPath.row].username
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = searchResults[indexPath.row]
        guard let user = selectedUser else { return }
        
        isUserFollowing(userID: user.uid) { [weak self] isFollowing in
            guard let self = self else { return }
            let actionTitle = isFollowing ? "Unfollow" : "Follow"
            self.presentFollowUnfollowAlert(user: user, actionTitle: actionTitle)
        }
    }
    
    @objc private func handleFeedButtonTapped() {
        let feedVC = FeedViewController()
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    @objc private func handlePostButtonTapped() {
        let postVC = PostViewController()
        navigationController?.pushViewController(postVC, animated: true)
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
    
  private func followUser(currentUserID: String, userIDToFollow: String) {
    let db = Firestore.firestore()
    
    // Add the userIDToFollow to the following subcollection of currentUserID
    db.collection("users").document(currentUserID).collection("following").document(userIDToFollow).setData([:]) { error in
        if let error = error {
            print("Error following user: \(error.localizedDescription)")
        } else {
            print("User followed successfully.")
            // Increment the following count
            db.collection("users").document(currentUserID).updateData([
                "followingCount": FieldValue.increment(Int64(1))
            ]) { error in
                if let error = error {
                    print("Error updating following count: \(error.localizedDescription)")
                } else {
                    self.loadUserData() // Refresh user data
                }
            }
        }
    }
    
    // Add the currentUserID to the followers subcollection of userIDToFollow
    db.collection("users").document(userIDToFollow).collection("followers").document(currentUserID).setData([:]) { error in
        if let error = error {
            print("Error updating followers: \(error.localizedDescription)")
        } else {
            print("Followers updated successfully.")
            // Increment the followers count
            db.collection("users").document(userIDToFollow).updateData([
                "followersCount": FieldValue.increment(Int64(1))
            ]) { error in
                if let error = error {
                    print("Error updating followers count: \(error.localizedDescription)")
                }
            }
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
                // Decrement the following count
                db.collection("users").document(currentUserID).updateData([
                    "followingCount": FieldValue.increment(Int64(-1))
                ])
                self.loadUserData() // Refresh user data
            }
        }
        
        // Remove the currentUserID from the followers subcollection of userIDToUnfollow
        db.collection("users").document(userIDToUnfollow).collection("followers").document(currentUserID).delete { error in
            if let error = error {
                print("Error updating followers: \(error.localizedDescription)")
            } else {
                print("Followers updated successfully.")
                // Decrement the followers count
                db.collection("users").document(userIDToUnfollow).updateData([
                    "followersCount": FieldValue.increment(Int64(-1))
                ])
            }
        }
    }
    
    private func isUserFollowing(userID: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { completion(false); return }
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(currentUserID).collection("following").document(userID)
        docRef.getDocument { document, error in
            if let error = error {
                print("Error checking follow status: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(document?.exists ?? false)
            }
        }
    }
}



struct UserPost: Identifiable {
     let postID: String
    let authorID: String
    let authorUsername: String?
    let title: String?
    let image: String?
    let servings: Int?
    let readyInMinutes: Int?
    let instructions: String?
    let content: String?
    let timestamp: Timestamp
    let originalAuthorID: String?
    let originalAuthorUsername: String?
    let isRepost: Bool
    var likesCount: Int
    var likedUsers: [String]
    var userHasLiked: Bool
    var id: String { postID }
}



struct User {
    let uid: String
    let username: String
    var posts: [UserPost] = []
}




