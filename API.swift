//
//File for API integration 
//
//Rachel Wu
// Edited: Jevon Williams

//  File for API integration
//  Authors:
//  Raisa Methila
//  Rachel Wu
//  Jevon Williams


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
    let imageType: String? // This field contains the image type (e.g., "jpg")
    
    var imageURL: URL? {
        guard let imageType = imageType else { return nil }
        return URL(string: "https://img.spoonacular.com/recipes/\(id)-636x393.\(imageType)")
    }
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

struct RandomRecipeResponse: Decodable {
    let recipes: [Recipee]
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
    
    func fetchRecipeDetails(for id: Int, completion: @escaping (Result<Recipee, APIError>) -> Void) {
        let urlString = "\(baseURL)\(id)/information?apiKey=\(apiKey)"
        
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
                let recipe = try JSONDecoder().decode(Recipee.self, from: data)
                completion(.success(recipe))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        task.resume()
    }

    func fetchRecipes(query: String?, includeIngredients: String?, excludeIngredients: String?, completion: @escaping (Result<[Recipee], APIError>) -> Void) {
        var urlString = "\(baseURL)complexSearch?apiKey=\(apiKey)&number=10"
        
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
                let recipeSummaries = response.results
                
                let group = DispatchGroup()
                var recipes = [Recipee]()
                var fetchErrors = [APIError]()
                
                for summary in recipeSummaries {
                    group.enter()
                    self.fetchRecipeDetails(for: summary.id) { result in
                        switch result {
                        case .success(let recipe):
                            recipes.append(recipe)
                        case .failure(let error):
                            fetchErrors.append(error)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    if fetchErrors.isEmpty {
                        completion(.success(recipes))
                    } else {
                        completion(.failure(.decodingError(fetchErrors.first!))) // Handle multiple errors differently if needed
                    }
                }
                
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        task.resume()
    }

    func saveRecipeToFavorites(recipe: Recipee, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let recipeData: [String: Any] = [
            "id": recipe.id,
            "title": recipe.title,
            "image": recipe.image,
            "imageType": recipe.imageType ?? "",
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

    func removeRecipe(recipeId: Int, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(userId).collection("favoriteRecipes").document("\(recipeId)").delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func fetchFavoriteRecipes(userId: String, completion: @escaping (Result<[Recipee], Error>) -> Void) {
    db.collection("users").document(userId).collection("favoriteRecipes").getDocuments { (querySnapshot, error) in
        if let error = error {
            completion(.failure(error))
            return
        }

        var favoriteRecipes = [Recipee]()

        let dispatchGroup = DispatchGroup()

        for document in querySnapshot!.documents {
            if let data = document.data() as? [String: Any],
               let id = data["id"] as? Int {
                dispatchGroup.enter()
                self.fetchRecipeDetails(for: id) { result in
                    switch result {
                    case .success(let recipe):
                        favoriteRecipes.append(recipe)
                    case .failure(let error):
                        print("Error fetching recipe details: \(error)")
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(.success(favoriteRecipes))
        }
    }
}


    func fetchRandomRecipes(completion: @escaping (Result<[Recipee], APIError>) -> Void) {
        let urlString = "\(baseURL)random?number=2&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("Fetching from URL: \(urlString)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("HTTP status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                completion(.failure(.noData))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(.noData))
                return
            }
            
            print("Received data: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            do {
                let response = try JSONDecoder().decode(RandomRecipeResponse.self, from: data)
                let recipes = response.recipes
                print("Recipes decoded successfully: \(recipes)")
                completion(.success(recipes))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }
        task.resume()
    }
}
