//
//  UserFeedViewController.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/24/24.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var posts: [UserPost] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        loadUserFeed()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "recipePostCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadUserFeed() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUserID).collection("following").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error loading user feed: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No followed users found.")
                return
            }
            
            var posts: [UserPost] = []
            let dispatchGroup = DispatchGroup()
            
            for document in documents {
                let followedUserID = document.documentID
                dispatchGroup.enter()
                db.collection("users").document(followedUserID).collection("posts").order(by: "timestamp", descending: true).getDocuments { (postSnapshot, postError) in
                    if let postError = postError {
                        print("Error loading posts: \(postError.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }
                    guard let postDocuments = postSnapshot?.documents else {
                        print("No posts found for user \(followedUserID).")
                        dispatchGroup.leave()
                        return
                    }
                    let userPosts = postDocuments.compactMap { postDocument -> UserPost? in
                        let data = postDocument.data()
                        guard let timestamp = data["timestamp"] as? Timestamp else { return nil }
                        let postID = postDocument.documentID
                        let userHasLiked = (data["likedUsers"] as? [String] ?? []).contains(currentUserID)
                        
                        return UserPost(
                            postID: postID,
                            authorID: followedUserID,
                            authorUsername: data["authorUsername"] as? String ?? "Unknown",
                            title: data["title"] as? String,
                            image: data["image"] as? String,
                            servings: data["servings"] as? Int,
                            readyInMinutes: data["readyInMinutes"] as? Int,
                            instructions: data["instructions"] as? String,
                            content: data["content"] as? String,
                            timestamp: timestamp,
                            originalAuthorID: data["originalAuthorID"] as? String,
                            originalAuthorUsername: data["originalAuthorUsername"] as? String,
                            isRepost: data["isRepost"] as? Bool ?? false,
                            likesCount: data["likesCount"] as? Int ?? 0,
                            likedUsers: data["likedUsers"] as? [String] ?? [],
                            userHasLiked: userHasLiked
                        )
                    }
                    
                    posts.append(contentsOf: userPosts)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self?.posts = posts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
                self?.tableView.reloadData()
            }
        }
    }
    
    private func repostPost(_ post: UserPost) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let repostData: [String: Any] = [
            "title": post.title ?? "",
            "image": post.image ?? "",
            "servings": post.servings ?? 0,
            "readyInMinutes": post.readyInMinutes ?? 0,
            "instructions": post.instructions ?? "",
            "content": post.content ?? "",
            "timestamp": Timestamp(date: Date()),
            "originalAuthorID": post.authorID,
            "originalAuthorUsername": post.authorUsername,
            "isRepost": true
        ]
        db.collection("users").document(currentUserID).collection("posts").addDocument(data: repostData) { error in
            if let error = error {
                print("Error reposting: \(error.localizedDescription)")
            } else {
                print("Repost successful")
                self.loadUserFeed()
            }
        }
    }
    
    private func deletePost(_ post: UserPost) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).collection("posts").document(post.postID).delete { error in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                print("Post deleted successfully")
                self.loadUserFeed()
            }
        }
    }
    
    private func likePost(_ post: UserPost) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let postRef = db.collection("users").document(post.authorID).collection("posts").document(post.postID)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let postSnapshot: DocumentSnapshot
            do {
                postSnapshot = try transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                print("Error fetching document: \(fetchError.localizedDescription)")
                return nil
            }
            
            guard let currentLikesCount = postSnapshot.data()?["likesCount"] as? Int else {
                print("Error: likesCount field missing or invalid")
                return nil
            }
            
            // Add the user ID to the list of liked users
            var likedUsers = postSnapshot.data()?["likedUsers"] as? [String] ?? []
            if !likedUsers.contains(currentUserID) {
                let updatedLikesCount = currentLikesCount + 1
                likedUsers.append(currentUserID)
                transaction.updateData([
                    "likesCount": updatedLikesCount,
                    "likedUsers": likedUsers
                ], forDocument: postRef)
            }
            
            return nil
        }) { [weak self] (_, error) in
            if let error = error {
                print("Transaction failed: \(error.localizedDescription)")
            } else {
                self?.loadUserFeed() // Refresh the feed to reflect changes
            }
        }
    }
    
    private func unlikePost(_ post: UserPost) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let postRef = db.collection("users").document(post.authorID).collection("posts").document(post.postID)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let postSnapshot: DocumentSnapshot
            do {
                postSnapshot = try transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                print("Error fetching document: \(fetchError.localizedDescription)")
                return nil
            }
            
            guard let currentLikesCount = postSnapshot.data()?["likesCount"] as? Int else {
                print("Error: likesCount field missing or invalid")
                return nil
            }
            
            // Remove the user ID from the list of liked users
            var likedUsers = postSnapshot.data()?["likedUsers"] as? [String] ?? []
            if likedUsers.contains(currentUserID) {
                let updatedLikesCount = max(currentLikesCount - 1, 0)
                likedUsers.removeAll { $0 == currentUserID }
                transaction.updateData([
                    "likesCount": updatedLikesCount,
                    "likedUsers": likedUsers
                ], forDocument: postRef)
            }
            
            return nil
        }) { [weak self] (_, error) in
            if let error = error {
                print("Transaction failed: \(error.localizedDescription)")
            } else {
                self?.loadUserFeed() // Refresh the feed to reflect changes
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recipePostCell", for: indexPath) as? PostTableViewCell else {
            fatalError("Unable to dequeue PostTableViewCell")
        }
        
        let post = posts[indexPath.row]
        
        cell.usernameLabel.text = post.isRepost ? post.originalAuthorUsername : post.authorUsername
        cell.timestampLabel.text = DateFormatter.localizedString(from: post.timestamp.dateValue(), dateStyle: .short, timeStyle: .short)
        
        cell.titleLabel.text = post.title
        cell.titleLabel.isHidden = post.title == nil
        
        if let imageUrl = post.image, let url = URL(string: imageUrl) {
            cell.recipeImageView.load(url: url)
            cell.recipeImageView.isHidden = false
        } else {
            cell.recipeImageView.isHidden = true
        }
        
        cell.servingsLabel.text = post.servings != nil ? "Servings: \(post.servings!)" : nil
        cell.servingsLabel.isHidden = post.servings == nil
        
        cell.readyInMinutesLabel.text = post.readyInMinutes != nil ? "Ready in: \(post.readyInMinutes!) minutes" : nil
        cell.readyInMinutesLabel.isHidden = post.readyInMinutes == nil
        
        cell.instructionsTextView.text = post.instructions
        cell.instructionsTextView.isHidden = post.instructions == nil
        
        cell.contentTextView.text = post.content
        cell.contentTextView.isHidden = post.content == nil
        
        // For text-based posts, hide recipe-specific elements
        if post.title == nil && post.image == nil && post.servings == nil && post.readyInMinutes == nil && post.instructions == nil {
            cell.titleLabel.isHidden = true
            cell.recipeImageView.isHidden = true
            cell.servingsLabel.isHidden = true
            cell.readyInMinutesLabel.isHidden = true
            cell.instructionsTextView.isHidden = true
            cell.contentTextView.isHidden = false
        }
        
        cell.updateLikesCount(post.likesCount)
        
        // Update button states based on `userHasLiked`
        cell.likeButton.isHidden = post.userHasLiked
        cell.unlikeButton.isHidden = !post.userHasLiked
        
        cell.repostAction = { [weak self] in
            self?.repostPost(post)
        }
        cell.deleteAction = { [weak self] in
            self?.deletePost(post)
        }
        cell.likeAction = { [weak self] in
            self?.likePost(post)
        }
        cell.unlikeAction = { [weak self] in
            self?.unlikePost(post)
        }
        
        return cell
    }
}
