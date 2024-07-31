//
//  NetworkManager.swift
//  What'sCookin
//
//  Created by Raisa Methila on 7/29/24.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.spoonacular.com/recipes/random"
    private let apiKey = "4797a64a1bcc4191b17e6da86f903914"
    
    private init() {}
    
    func fetchRandomRecipes(completion: @escaping (Result<[Recipes], Error>) -> Void) {
        let urlString = "\(baseURL)?number=2&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let recipeResponse = try decoder.decode(RandomRecipeResponse.self, from: data)
                completion(.success(recipeResponse.recipes))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

// Models
struct RandomRecipeResponse: Decodable {
    let recipes: [Recipes]
}

struct Recipes: Decodable {
    let id: Int
    let title: String
    let image: String? // This field contains the image type (e.g., "jpg")
    let ingredients: [String]?
    
    var imageURL: URL? {
        guard let imageType = image else { return nil }
        return URL(string: "https://img.spoonacular.com/recipes/\(id)-636x393.\(imageType)")
    }
}
