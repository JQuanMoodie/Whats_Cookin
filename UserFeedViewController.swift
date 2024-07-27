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
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "postCell")
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
                db.collection("users").document(followedUserID).getDocument { (userSnapshot, userError) in
                    if let userError = userError {
                        print("Error loading user data: \(userError.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }
                    guard let userData = userSnapshot?.data(),
                          let username = userData["username"] as? String else {
                        print("No username found for user \(followedUserID).")
                        dispatchGroup.leave()
                        return
                    }

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
                            guard let content = data["content"] as? String,
                                  let timestamp = data["timestamp"] as? Timestamp else { return nil }
                            let postID = postDocument.documentID
                            return UserPost(postID: postID, authorID: followedUserID, authorUsername: username, content: content, timestamp: timestamp, originalAuthorID: nil, originalAuthorUsername: nil, isRepost: false)
                        }
                        posts.append(contentsOf: userPosts)
                        dispatchGroup.leave()
                    }
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
            "content": post.content,
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else {
            fatalError("Unable to dequeue PostTableViewCell")
        }
        let post = posts[indexPath.row]
        cell.usernameLabel.text = post.authorUsername
        cell.timestampLabel.text = DateFormatter.localizedString(from: post.timestamp.dateValue(), dateStyle: .short, timeStyle: .short)
        cell.contentLabel.text = post.content
        cell.repostAction = { [weak self] in
            self?.repostPost(post)
        }
        cell.deleteAction = { [weak self] in
            self?.deletePost(post)
        }
        return cell
    }
}

