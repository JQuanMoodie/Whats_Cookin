//
//  PostTable.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/27/24.
//
import UIKit

class PostTableViewCell: UITableViewCell {

    let usernameLabel = UILabel()
    let timestampLabel = UILabel()
    let titleLabel = UILabel()
    let recipeImageView = UIImageView()
    let servingsLabel = UILabel()
    let readyInMinutesLabel = UILabel()
    let instructionsTextView = UITextView()
    let contentTextView = UITextView()
    
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
    
    let likesCountLabel = UILabel()
    
    var repostAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    var likeAction: (() -> Void)?
    var unlikeAction: (() -> Void)?

    private let repostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Repost", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var doubleTapGestureRecognizer: UITapGestureRecognizer?

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
        contentView.addSubview(likeButton)
        contentView.addSubview(unlikeButton)
        contentView.addSubview(likesCountLabel)
        contentView.addSubview(repostButton)
        contentView.addSubview(deleteButton)
        
        setupConstraints()
        
        repostButton.addTarget(self, action: #selector(repostButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        unlikeButton.addTarget(self, action: #selector(unlikeButtonTapped), for: .touchUpInside)
        
        // Configure double tap gesture recognizer for the unlike button
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(unlikeButtonDoubleTapped))
        doubleTapGestureRecognizer?.numberOfTapsRequired = 2
        unlikeButton.addGestureRecognizer(doubleTapGestureRecognizer!)
        
        // Set default button states
        likeButton.isHidden = false
        unlikeButton.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        // Example layout constraints - adjust as needed
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        servingsLabel.translatesAutoresizingMaskIntoConstraints = false
        readyInMinutesLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsTextView.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        unlikeButton.translatesAutoresizingMaskIntoConstraints = false
        likesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        repostButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

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

            contentTextView.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 8),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(equalToConstant: 80),

            likeButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 8),
            likeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            unlikeButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 8),
            unlikeButton.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 8),

            likesCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likesCountLabel.leadingAnchor.constraint(equalTo: unlikeButton.trailingAnchor, constant: 8),
            likesCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            repostButton.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 8),
            repostButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            repostButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            deleteButton.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 8),
            deleteButton.leadingAnchor.constraint(equalTo: repostButton.trailingAnchor, constant: 16),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
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

    @objc private func unlikeButtonDoubleTapped() {
        unlikeAction?()
    }

    func updateLikesCount(_ count: Int) {
        likesCountLabel.text = "\(count) Likes"
    }
    
    func configure(with post: UserPost) {
        // Update the UI with post details
        usernameLabel.text = post.isRepost ? post.originalAuthorUsername : post.authorUsername
        timestampLabel.text = DateFormatter.localizedString(from: post.timestamp.dateValue(), dateStyle: .short, timeStyle: .short)
        
        titleLabel.text = post.title
        titleLabel.isHidden = post.title == nil
        
        if let imageUrl = post.image, let url = URL(string: imageUrl) {
            recipeImageView.load(url: url)
            recipeImageView.isHidden = false
        } else {
            recipeImageView.isHidden = true
        }
        
        servingsLabel.text = post.servings != nil ? "Servings: \(post.servings!)" : nil
        servingsLabel.isHidden = post.servings == nil
        
        readyInMinutesLabel.text = post.readyInMinutes != nil ? "Ready in: \(post.readyInMinutes!) minutes" : nil
        readyInMinutesLabel.isHidden = post.readyInMinutes == nil
        
        instructionsTextView.text = post.instructions
        instructionsTextView.isHidden = post.instructions == nil
        
        contentTextView.text = post.content
        contentTextView.isHidden = post.content == nil
        
        updateLikesCount(post.likesCount)
        
        // Update button visibility based on whether the post is liked
        likeButton.isHidden = post.userHasLiked
        unlikeButton.isHidden = !post.userHasLiked
    }
}

