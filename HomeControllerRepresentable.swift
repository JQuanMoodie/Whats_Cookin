//
//  Home.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/12/24.
//

import SwiftUI

struct HomeViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HomeViewController {
        let homeViewController = HomeViewController()
        return homeViewController
    }

    func updateUIViewController(_ uiViewController: HomeViewController, context: Context) {
        // Update the view controller if needed
    }
}
