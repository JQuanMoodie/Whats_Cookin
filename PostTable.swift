//
//  PostTable.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/27/24.
//
import UIKit

class PostTableViewCell: UITableViewCell {

    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let repostIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrow.2.squarepath") // Use a system image or your own icon
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        return imageView
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
        return button
    }()

    let repostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Repost", for: .normal)
        return button
    }()

    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        return button
    }()

    let likesCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
     let originalAuthorUsernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        return label
    }()

    var repostAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    var likeAction: (() -> Void)?
    var unlikeAction: (() -> Void)?

    var post: UserPost? {
        didSet {
            configure(with: post)
        }
    }

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
        buttonStackView.addArrangedSubview(repostButton)
        buttonStackView.addArrangedSubview(deleteButton)
        contentView.addSubview(likesCountLabel)
        contentView.addSubview(repostIconImageView)
        contentView.addSubview(originalAuthorUsernameLabel)
        
        setupConstraints()
        
        // Add double-tap gesture recognizer to likeButton
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(likeButtonTapped))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        likeButton.addGestureRecognizer(doubleTapGestureRecognizer)
        
        repostButton.addTarget(self, action: #selector(repostButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
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
    repostIconImageView.translatesAutoresizingMaskIntoConstraints = false
    originalAuthorUsernameLabel.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
        usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
        usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        
        repostIconImageView.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 4),
        repostIconImageView.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
        repostIconImageView.widthAnchor.constraint(equalToConstant: 16),
        repostIconImageView.heightAnchor.constraint(equalToConstant: 16),
        
        originalAuthorUsernameLabel.leadingAnchor.constraint(equalTo: repostIconImageView.trailingAnchor, constant: 4),
        originalAuthorUsernameLabel.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
        originalAuthorUsernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        
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
        
        contentTextView.topAnchor.constraint(equalTo: instructionsTextView.bottomAnchor, constant: 8),
        contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        
        buttonStackView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 8),
        buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        
        likesCountLabel.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 8),
        likesCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        likesCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
    ])
}

func configure(with post: UserPost?) {
    guard let post = post else { return }
    
    usernameLabel.text = post.authorUsername
    
    // Only show repost icon and original author username if it is a repost
    repostIconImageView.isHidden = !post.isRepost
    originalAuthorUsernameLabel.isHidden = !post.isRepost
    originalAuthorUsernameLabel.text = post.isRepost ? "Reposted from \(post.originalAuthorUsername ?? "")" : ""
    
    // Convert Firestore Timestamp to Date
    let date = post.timestamp.dateValue()
    timestampLabel.text = formatDate(date)
    
    titleLabel.text = post.title ?? ""
    servingsLabel.text = (post.servings ?? 0) > 0 ? "Servings: \(post.servings!)" : nil
    readyInMinutesLabel.text = (post.readyInMinutes ?? 0) > 0 ? "Ready in: \(post.readyInMinutes!) mins" : nil
    
    // Format and sanitize instructions
    instructionsTextView.text = formatInstructions(post.instructions ?? "")
    contentTextView.text = post.content ?? ""
    
    likesCountLabel.text = "Likes: \(post.likesCount)"
    
    if let imageUrlString = post.image, let imageURL = URL(string: imageUrlString) {
        recipeImageView.load(url: imageURL)
    } else {
        recipeImageView.image = nil
    }
    
    likeButton.setTitle(post.userHasLiked ? "Unlike" : "Like", for: .normal)
}

// Method to format and sanitize instructions
private func formatInstructions(_ instructions: String) -> String {
    // Remove any unwanted characters or extra spaces
    let sanitizedInstructions = instructions
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "\n", with: " ")
    
    // Convert multiple spaces into a single space
    let formattedInstructions = sanitizedInstructions
        .components(separatedBy: .whitespaces)
        .filter { !$0.isEmpty }
        .joined(separator: " ")
    
    return formattedInstructions
}



    @objc private func likeButtonTapped() {
        if let action = likeAction {
            action()
        }
    }

    @objc private func repostButtonTapped() {
        repostAction?()
    }

    @objc private func deleteButtonTapped() {
        deleteAction?()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
