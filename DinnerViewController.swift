//
//  DinnerViewController.swift
//  capstoneproj
//
//  Created by Jose on 7/26/24.
//

import UIKit

class DinnerViewController: UIViewController {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemOrange // Dinner-themed background color
        
        setupTitleLabel()
        setupDescriptionLabel()
    }

    private func setupTitleLabel() {
        titleLabel.text = "Dinner Time!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 36)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupDescriptionLabel() {
        descriptionLabel.text = "Wind down your day with a delicious dinner. Discover a variety of dinner options to satisfy your evening cravings and end your day on a high note."
        descriptionLabel.font = UIFont.systemFont(ofSize: 18)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
