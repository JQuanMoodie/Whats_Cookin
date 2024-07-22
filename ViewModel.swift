import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import Combine

class ProfileViewModel: ObservableObject {

    @Published var profileImage: UIImage?
    @Published var profileImageURL: String?

    private let storage = Storage.storage()
    private let firestore = Firestore.firestore()
    
    init() {
        loadProfileDataFromFirestore()
    }

    // Load the profile image from Firestore URL
    func loadProfileImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }

        let task = URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
            if let error = error {
                print("Error loading image data: \(error)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Error: Data or image conversion failed")
                return
            }
            DispatchQueue.main.async {
                self?.profileImage = image
            }
        }
        task.resume()
    }

    func saveProfileImage(image: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let storageRef = storage.reference().child("profile_images/\(userId).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let uploadTask = storageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }
            storageRef.downloadURL { [weak self] url, error in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    return
                }
                if let url = url {
                    let urlString = url.absoluteString
                    self?.profileImageURL = urlString
                    self?.updateProfileImageURLInFirestore(urlString)
                }
            }
        }
        
        // Observe upload progress and completion (optional)
        uploadTask.observe(.progress) { snapshot in
            // Handle progress updates here
        }
        uploadTask.observe(.success) { snapshot in
            // Handle success here
        }
        uploadTask.observe(.failure) { snapshot in
            // Handle failure here
        }
    }

    private func updateProfileImageURLInFirestore(_ url: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = firestore.collection("users").document(userId)
        userRef.updateData(["profileImageURL": url]) { error in
            if let error = error {
                print("Error updating profile image URL in Firestore: \(error)")
            } else {
                print("Profile image URL updated successfully.")
            }
        }
    }

    // Load profile data from Firestore and then load the image if URL is available
    func loadProfileDataFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = firestore.collection("users").document(userId)
        userRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Error loading profile data: \(error)")
            } else if let document = document, document.exists {
                let data = document.data()
                if let profileImageURL = data?["profileImageURL"] as? String {
                    self?.profileImageURL = profileImageURL
                    self?.loadProfileImage(from: profileImageURL)
                }
            }
        }
    }
}
