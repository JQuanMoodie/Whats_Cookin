//
//  SearchViewRepresentable.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/15/24.
//

import SwiftUI

struct SearchViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SearchViewController {
        // Create SearchViewController instance
        let searchViewController = SearchViewController()
        return searchViewController
    }

    func updateUIViewController(_ uiViewController: SearchViewController, context: Context) {
        // Update the view controller if needed
    }
    
     
}
