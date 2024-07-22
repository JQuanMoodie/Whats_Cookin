//
//  StoreAPI.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/22/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift // For the `setData(from:forDocument:)` method

class FirestoreService {
    private let db = Firestore.firestore()
    
    func saveRecipes(_ recipes: [Recipee], completion: @escaping (Result<Void, Error>) -> Void) {
        let batch = db.batch()
        
        for recipe in recipes {
            let recipeRef = db.collection("recipes").document("\(recipe.id)")
            do {
                try batch.setData(from: recipe, forDocument: recipeRef)
            } catch {
                // Rollback the batch operation and return the error
                completion(.failure(error))
                return
            }
        }
        
        batch.commit { error in
            if let error = error {
                // Handle the commit error
                completion(.failure(error))
            } else {
                // Successfully committed batch
                completion(.success(()))
            }
        }
    }
}


