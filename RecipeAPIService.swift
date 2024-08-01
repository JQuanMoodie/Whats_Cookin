//
//File for API integration 
//
//Rachel Wu
// Edited: Jevon Williams

import Foundation
import FirebaseFirestore

struct Recipee: Identifiable, Decodable {
    let id: Int
    let title: String
    let image: String
    let servings: Int?
    let readyInMinutes: Int?
    let ingredients: [Ingredient]?
    let instructions: String?
}

struct Ingredient: Codable, Identifiable {
    let id: UUID
    let name: String
    let amount: Double
    let unit: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, amount, unit
    }
    
    init(id: UUID = UUID(), name: String, amount: Double, unit: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
    }
}

struct RecipeResponse: Decodable {
    let results: [Recipee]
}

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case noData
    case decodingError(Error)
}

class RecipeService {
    private let apiKey = "4797a64a1bcc4191b17e6da86f903914"
    private let baseURL = "https://api.spoonacular.com/recipes/"
    private let db = Firestore.firestore()
    
    // Fetch recipes with query parameters
    func fetchRecipes(query: String?, includeIngredients: String?, excludeIngredients: String?, completion: @escaping (Result<[Recipee], APIError>) -> Void) {
        var urlString = "\(baseURL)complexSearch?apiKey=\(apiKey)"
        
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
                let response = try JSONDecoder().decode(RecipeResponse.self, from: data)
                let recipes = response.results
                completion(.success(recipes))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        task.resume()
    }
    
    // Save recipe to Firestore
    func saveRecipeToFavorites(recipe: Recipee, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let recipeData: [String: Any] = [
            "id": recipe.id,
            "title": recipe.title,
            "image": recipe.image,
            "servings": recipe.servings ?? 0,
            "readyInMinutes": recipe.readyInMinutes ?? 0,
            "ingredients": recipe.ingredients?.map { ingredient in
                [
                    "id": ingredient.id.uuidString,
                    "name": ingredient.name,
                    "amount": ingredient.amount,
                    "unit": ingredient.unit
                ]
            } ?? [],
            "instructions": recipe.instructions ?? "",
            "userId": userId
        ]
        
        db.collection("users").document(userId).collection("favoriteRecipes").document("\(recipe.id)").setData(recipeData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
   // Remove recipe from Firestore
func removeRecipe(recipeId: Int, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
    db.collection("favoriteRecipes")
        .document("\(userId)")
        .collection("recipes")
        .document("\(recipeId)")
        .delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
}

    // Fetch favorite recipes from Firestore
    func fetchFavoriteRecipes(userId: String, completion: @escaping (Result<[Recipee], Error>) -> Void) {
        db.collection("users").document(userId).collection("favoriteRecipes").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let recipes = snapshot?.documents.compactMap { document -> Recipee? in
                    let data = document.data()
                    guard
                        let id = data["id"] as? Int,
                        let title = data["title"] as? String,
                        let image = data["image"] as? String
                    else {
                        return nil
                    }
                    
                    let servings = data["servings"] as? Int
                    let readyInMinutes = data["readyInMinutes"] as? Int
                    let ingredientsData = data["ingredients"] as? [[String: Any]]
                    let ingredients = ingredientsData?.compactMap { ingredientData -> Ingredient? in
                        guard
                            let idString = ingredientData["id"] as? String,
                            let id = UUID(uuidString: idString),
                            let name = ingredientData["name"] as? String,
                            let amount = ingredientData["amount"] as? Double,
                            let unit = ingredientData["unit"] as? String
                        else {
                            return nil
                        }
                        return Ingredient(id: id, name: name, amount: amount, unit: unit)
                    }
                    let instructions = data["instructions"] as? String
                    
                    return Recipee(
                        id: id,
                        title: title,
                        image: image,
                        servings: servings,
                        readyInMinutes: readyInMinutes,
                        ingredients: ingredients,
                        instructions: instructions
                    )
                } ?? []
                completion(.success(recipes))
            }
        }
    }
    
    
    
    // Fetch random recipes from Spoonacular
    func fetchRandomRecipes(completion: @escaping (Result<[Recipee], Error>) -> Void) {
        let urlString = "\(baseURL)random?number=2&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(RecipeResponse.self, from: data)
                completion(.success(response.results))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
     private func parseRecipeData(_ data: [String: Any]) -> Recipee? {
        guard
            let id = data["id"] as? Int,
            let title = data["title"] as? String,
            let image = data["image"] as? String,
            let servings = data["servings"] as? Int,
            let readyInMinutes = data["readyInMinutes"] as? Int,
            let instructions = data["instructions"] as? String
        else {
            return nil
        }

        let ingredientsData = data["ingredients"] as? [[String: Any]] ?? []
        let ingredients = ingredientsData.compactMap { ingredientData -> Ingredient? in
            guard
                let idString = ingredientData["id"] as? String,
                let id = UUID(uuidString: idString),
                let name = ingredientData["name"] as? String,
                let amount = ingredientData["amount"] as? Double,
                let unit = ingredientData["unit"] as? String
            else {
                return nil
            }
            return Ingredient(id: id, name: name, amount: amount, unit: unit)
        }

        return Recipee(id: id, title: title, image: image, servings: servings, readyInMinutes: readyInMinutes, ingredients: ingredients, instructions: instructions)
    }
}