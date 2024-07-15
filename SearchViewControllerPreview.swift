//
//  SearchViewControllerPreview.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/15/24.
//

import SwiftUI

struct SearchViewControllerPreview: View {
    var body: some View {
            SearchViewControllerRepresentable()
                .edgesIgnoringSafeArea(.all) // If you want to ignore safe area for full-screen view
    }
}

struct SearchViewControllerPreview_Previews: PreviewProvider {
    static var previews: some View {
        SearchViewControllerPreview()
    }
}

