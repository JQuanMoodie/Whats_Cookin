//
//  PostTable.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/27/24.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class PostTableViewCell: UITableViewCell {
    let usernameLabel = UILabel()
    let timestampLabel = UILabel()
    let contentLabel = UILabel()
    let repostButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)

    var repostAction: (() -> Void)?
    var deleteAction: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        timestampLabel.font = UIFont.systemFont(ofSize: 12)
        timestampLabel.textColor = .gray
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.numberOfLines = 0
        repostButton.setTitle("Repost", for: .normal)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        
        repostButton.addTarget(self, action: #selector(didTapRepostButton), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)

        let buttonStackView = UIStackView(arrangedSubviews: [repostButton, deleteButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16

        let stackView = UIStackView(arrangedSubviews: [usernameLabel, timestampLabel, contentLabel, buttonStackView])
        stackView.axis = .vertical
        stackView.spacing = 4

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    @objc private func didTapRepostButton() {
        repostAction?()
    }

    @objc private func didTapDeleteButton() {
        deleteAction?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
