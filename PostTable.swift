//
//  PostTable.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/27/24.
//
import UIKit
import FirebaseFirestore

class PostTableViewCell: UITableViewCell {
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    let servingsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    let readyInMinutesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    let instructionsTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    let contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Like", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let unlikeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Unlike", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let repostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Repost", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let likesCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    var repostAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    var likeAction: (() -> Void)?
    var unlikeAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(recipeImageView)
        contentView.addSubview(servingsLabel)
        contentView.addSubview(readyInMinutesLabel)
        contentView.addSubview(instructionsTextView)
        contentView.addSubview(contentTextView)
        contentView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(likeButton)
        buttonStackView.addArrangedSubview(unlikeButton)
        buttonStackView.addArrangedSubview(repostButton)
        buttonStackView.addArrangedSubview(deleteButton)
        contentView.addSubview(likesCountLabel)
        
        setupConstraints()
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        unlikeButton.addTarget(self, action: #selector(unlikeButtonTapped), for: .touchUpInside)
        repostButton.addTarget(self, action: #selector(repostButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        // Set default button states
        likeButton.isHidden = false
        unlikeButton.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        servingsLabel.translatesAutoresizingMaskIntoConstraints = false
        readyInMinutesLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsTextView.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        likesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            timestampLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            timestampLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            recipeImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recipeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            recipeImageView.heightAnchor.constraint(equalToConstant: 200),
            
            servingsLabel.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 8),
            servingsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            readyInMinutesLabel.topAnchor.constraint(equalTo: servingsLabel.bottomAnchor, constant: 4),
            readyInMinutesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            instructionsTextView.topAnchor.constraint(equalTo: readyInMinutesLabel.bottomAnchor, constant: 8),
            instructionsTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            instructionsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            instructionsTextView.heightAnchor.constraint(equalToConstant: 80),
            
            contentTextView.topAnchor.constraint(equalTo: instructionsTextView.bottomAnchor, constant: 8),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(equalToConstant: 80),
            
            buttonStackView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 8),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            likesCountLabel.centerYAnchor.constraint(equalTo: buttonStackView.centerYAnchor),
            likesCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            contentView.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 8)
        ])
    }
    
    func updateLikesCount(_ count: Int) {
        likesCountLabel.text = "\(count) likes"
    }
    
    @objc private func repostButtonTapped() {
        repostAction?()
    }
    
    @objc private func deleteButtonTapped() {
        deleteAction?()
    }
    
    @objc private func likeButtonTapped() {
        likeAction?()
    }
    
    @objc private func unlikeButtonTapped() {
        unlikeAction?()
    }
    
func configure(with post: UserPost) {
    print("Post ID: \(post.postID)")
    print("Author Username: \(post.authorUsername ?? "nil")")
    print("Original Author Username: \(post.originalAuthorUsername ?? "nil")")
    
    // Check if the post is a repost
    if post.isRepost {
        // Display the original author's username
        usernameLabel.text = "Test Username" // Check if this updates the label correctly

    } else {
        // Display the current author's username
        usernameLabel.text = "Test Username" // Check if this updates the label correctly

    }

    // Convert Timestamp to Date if needed
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short

    if let timestamp = post.timestamp as? Timestamp {
        let date = timestamp.dateValue()
        timestampLabel.text = dateFormatter.string(from: date)
    } else {
        timestampLabel.text = "Unknown date"
    }
    
    titleLabel.text = post.title ?? "No title"
    
    // Check if image is a URL string
    if let imageUrlString = post.image, let url = URL(string: imageUrlString) {
        recipeImageView.load(url: url) // Assuming you have an extension to load images from URLs
    } else {
        recipeImageView.image = nil // Or a placeholder image
    }
    
    servingsLabel.text = post.servings != nil ? "Servings: \(post.servings!)" : "No servings info"
    readyInMinutesLabel.text = post.readyInMinutes != nil ? "Ready in: \(post.readyInMinutes!) minutes" : "No time info"
    instructionsTextView.text = post.instructions ?? "No instructions provided"
    contentTextView.text = post.content ?? "No content available"
    
    updateLikesCount(post.likesCount)
    
    // Update button visibility based on post state
    likeButton.isHidden = post.userHasLiked
    unlikeButton.isHidden = !post.userHasLiked
}
}


