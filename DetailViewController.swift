//
//  DetailViewController.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/16/24.
//

import UIKit


class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let label = UILabel()
        label.text = "Detail View"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center

        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

#Preview{
    DetailViewController()
}
