//
//File for API integration 
//
//Rachel Wu
//

import Foundation

struct Recipee: Identifiable, Decodable {
    let id: Int
    let title: String
    let image: String
    let servings: Int
    let readyInMinutes: Int
    let ingredients: [Ingredient]
    let instructions: String
}

struct Ingredient: Codable, Identifiable {
    let id: UUID // or use a different unique identifier if available in your API
    let name: String
    let amount: Double
    let unit: String
}

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case noData
    case decodingError(Error)
}

struct RecipeSearchResponse: Decodable {
    let results: [Recipee]
}

class RecipeService {
    func fetchRecipes(query: String?, includeIngredients: String?, excludeIngredients: String?, completion: @escaping (Result<[Recipee], APIError>) -> Void) {
        var urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=4797a64a1bcc4191b17e6da86f903914"
        
        if let query = query {
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString += "&query=\(encodedQuery)"
        }
        if let includeIngredients = includeIngredients {
            let encodedInclude = includeIngredients.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString += "&includeIngredients=\(encodedInclude)"
        }
        if let excludeIngredients = excludeIngredients {
            let encodedExclude = excludeIngredients.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString += "&excludeIngredients=\(encodedExclude)"
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.noData))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(RecipeSearchResponse.self, from: data)
                let recipes = response.results
                completion(.success(recipes))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        task.resume()
    }
}
