//
//  ViewModel.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/10/24.
//

import PhotosUI
import SwiftUI
class ProfileViewModel: ObservableObject{
    @Published var profileImage: Image? = nil
        @Published var selectedItem: PhotosPickerItem? {
            didSet {
                loadPhoto()
            }
        }
        
        private let profileImageKey = "profileImageData"
        
        init() {
            loadProfileImage()
        }
        
        func loadPhoto() {
            Task {
                // Retrieve selected item
                guard let selectedItem = selectedItem else { return }
                
                // Retrieve selected item’s data
                if let data = try? await selectedItem.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        profileImage = Image(uiImage: uiImage)
                        
                        // Save profile image to UserDefaults
                        UserDefaults.standard.set(data, forKey: profileImageKey)
                    }
                }
            }
        }
        
        func loadProfileImage() {
            if let data = UserDefaults.standard.data(forKey: profileImageKey),
               let uiImage = UIImage(data: data) {
                profileImage = Image(uiImage: uiImage)
            }
        }
    //@Published var selectedItem: PhotosPickerItem?{
      //  didSet{Task{try await loadImage()}}
    //}
    //@Published var profileImage: Image?
    
    //func loadImage() async throws{
      //  guard let item = selectedItem else{return}
       // guard let imageData = try await item.loadTransferable(type: Data.self)else{return}
      //  guard let uiImage = UIImage(data:imageData)else{return}
      //  self.profileImage = Image(uiImage:uiImage)
        
    //}
    
}
    
   
