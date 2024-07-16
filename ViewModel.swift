//
//  ViewModel.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/10/24.
//

import UIKit

class ProfileViewModel {

    @Published var profileImage: UIImage? {
        didSet {
            saveProfileImage(image: profileImage)
        }
    }

    private let profileImageKey = "profileImageData"

    init() {
        loadProfileImage()
    }

    func loadProfileImage() {
        if let data = UserDefaults.standard.data(forKey: profileImageKey),
           let uiImage = UIImage(data: data) {
            profileImage = uiImage
        }
    }

    func saveProfileImage(image: UIImage?) {
        if let image = image, let imageData = image.jpegData(compressionQuality: 1.0) {
            UserDefaults.standard.set(imageData, forKey: profileImageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: profileImageKey)
        }
    }
}
    
   
