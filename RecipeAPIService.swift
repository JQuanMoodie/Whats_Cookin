//
//File for API integration 
//
//Rachel Wu
//

import Foundation

// Ensure that your model conforms to `Encodable`
struct Recipee: Identifiable, Decodable, Encodable {
    let id: Int
    let title: String
    let image: String
    let ingredients: [Ingredient]
    // Add other properties if needed and ensure they conform to `Encodable`
}

struct Ingredient: Identifiable, Decodable, Encodable {
    let id: Int
    let name: String
    let quantity: String
}


// Define an enum for API errors
enum APIError: Error {
    case responseError
    case dataError
    case decodeError
}

// Define a response model to match the API response
struct RecipeResponse: Decodable {
    let results: [Recipee]
}

class RecipeService {
    private let baseURL = "https://api.spoonacular.com/recipes"
    private let apiKey = "4797a64albcc4191b17e6da86f903914"
    
    func fetchRecipes(
        query: String? = nil,
        cuisine: String? = nil,
        excludeCuisine: String? = nil,
        diet: String? = nil,
        intolerances: String? = nil,
        equipment: String? = nil,
        includeIngredients: String? = nil,
        excludeIngredients: String? = nil,
        type: String? = nil,
        instructionsRequired: Bool? = nil,
        fillIngredients: Bool? = nil,
        addRecipeInformation: Bool? = nil,
        addRecipeInstructions: Bool? = nil,
        addRecipeNutrition: Bool? = nil,
        author: String? = nil,
        tags: String? = nil,
        recipeBoxId: Int? = nil,
        titleMatch: String? = nil,
        maxReadyTime: Int? = nil,
        minServings: Int? = nil,
        maxServings: Int? = nil,
        ignorePantry: Bool? = nil,
        sort: String? = nil,
        sortDirection: String? = nil,
        minCarbs: Int? = nil,
        maxCarbs: Int? = nil,
        minProtein: Int? = nil,
        maxProtein: Int? = nil,
        minCalories: Int? = nil,
        maxCalories: Int? = nil,
        minFat: Int? = nil,
        maxFat: Int? = nil,
        minAlcohol: Int? = nil,
        maxAlcohol: Int? = nil,
        minCaffeine: Int? = nil,
        maxCaffeine: Int? = nil,
        minCopper: Int? = nil,
        maxCopper: Int? = nil,
        minCalcium: Int? = nil,
        maxCalcium: Int? = nil,
        minCholine: Int? = nil,
        maxCholine: Int? = nil,
        minCholesterol: Int? = nil,
        maxCholesterol: Int? = nil,
        minFluoride: Int? = nil,
        maxFluoride: Int? = nil,
        minSaturatedFat: Int? = nil,
        maxSaturatedFat: Int? = nil,
        minVitaminA: Int? = nil,
        maxVitaminA: Int? = nil,
        minVitaminC: Int? = nil,
        maxVitaminC: Int? = nil,
        minVitaminD: Int? = nil,
        maxVitaminD: Int? = nil,
        minVitaminE: Int? = nil,
        maxVitaminE: Int? = nil,
        minVitaminK: Int? = nil,
        maxVitaminK: Int? = nil,
        minVitaminB1: Int? = nil,
        maxVitaminB1: Int? = nil,
        minVitaminB2: Int? = nil,
        maxVitaminB2: Int? = nil,
        minVitaminB5: Int? = nil,
        maxVitaminB5: Int? = nil,
        minVitaminB3: Int? = nil,
        maxVitaminB3: Int? = nil,
        minVitaminB6: Int? = nil,
        maxVitaminB6: Int? = nil,
        minVitaminB12: Int? = nil,
        maxVitaminB12: Int? = nil,
        minFiber: Int? = nil,
        maxFiber: Int? = nil,
        minFolate: Int? = nil,
        maxFolate: Int? = nil,
        minFolicAcid: Int? = nil,
        maxFolicAcid: Int? = nil,
        minIodine: Int? = nil,
        maxIodine: Int? = nil,
        minIron: Int? = nil,
        maxIron: Int? = nil,
        minMagnesium: Int? = nil,
        maxMagnesium: Int? = nil,
        minManganese: Int? = nil,
        maxManganese: Int? = nil,
        minPhosphorus: Int? = nil,
        maxPhosphorus: Int? = nil,
        minPotassium: Int? = nil,
        maxPotassium: Int? = nil,
        minSelenium: Int? = nil,
        maxSelenium: Int? = nil,
        minSodium: Int? = nil,
        maxSodium: Int? = nil,
        minSugar: Int? = nil,
        maxSugar: Int? = nil,
        minZinc: Int? = nil,
        maxZinc: Int? = nil,
        minTransFat: Int? = nil,
        maxTransFat: Int? = nil,
        offset: Int? = nil,
        number: Int? = nil,
        completion: @escaping (Result<[Recipee], APIError>) -> Void) {
        
        // Create URL components
        var urlComponents = URLComponents(string: "\(baseURL)/complexSearch")!
        var queryItems = [URLQueryItem(name: "apiKey", value: apiKey)]
        
        // Add parameters to query items
        let parameters: [(String, Any?)] = [
            ("query", query),
            ("cuisine", cuisine),
            ("excludeCuisine", excludeCuisine),
            ("diet", diet),
            ("intolerances", intolerances),
            ("equipment", equipment),
            ("includeIngredients", includeIngredients),
            ("excludeIngredients", excludeIngredients),
            ("type", type),
            ("instructionsRequired", instructionsRequired),
            ("fillIngredients", fillIngredients),
            ("addRecipeInformation", addRecipeInformation),
            ("addRecipeInstructions", addRecipeInstructions),
            ("addRecipeNutrition", addRecipeNutrition),
            ("author", author),
            ("tags", tags),
            ("recipeBoxId", recipeBoxId),
            ("titleMatch", titleMatch),
            ("maxReadyTime", maxReadyTime),
            ("minServings", minServings),
            ("maxServings", maxServings),
            ("ignorePantry", ignorePantry),
            ("sort", sort),
            ("sortDirection", sortDirection),
            ("minCarbs", minCarbs),
            ("maxCarbs", maxCarbs),
            ("minProtein", minProtein),
            ("maxProtein", maxProtein),
            ("minCalories", minCalories),
            ("maxCalories", maxCalories),
            ("minFat", minFat),
            ("maxFat", maxFat),
            ("minAlcohol", minAlcohol),
            ("maxAlcohol", maxAlcohol),
            ("minCaffeine", minCaffeine),
            ("maxCaffeine", maxCaffeine),
            ("minCopper", minCopper),
            ("maxCopper", maxCopper),
            ("minCalcium", minCalcium),
            ("maxCalcium", maxCalcium),
            ("minCholine", minCholine),
            ("maxCholine", maxCholine),
            ("minCholesterol", minCholesterol),
            ("maxCholesterol", maxCholesterol),
            ("minFluoride", minFluoride),
            ("maxFluoride", maxFluoride),
            ("minSaturatedFat", minSaturatedFat),
            ("maxSaturatedFat", maxSaturatedFat),
            ("minVitaminA", minVitaminA),
            ("maxVitaminA", maxVitaminA),
            ("minVitaminC", minVitaminC),
            ("maxVitaminC", maxVitaminC),
            ("minVitaminD", minVitaminD),
            ("maxVitaminD", maxVitaminD),
            ("minVitaminE", minVitaminE),
            ("maxVitaminE", maxVitaminE),
            ("minVitaminK", minVitaminK),
            ("maxVitaminK", maxVitaminK),
            ("minVitaminB1", minVitaminB1),
            ("maxVitaminB1", maxVitaminB1),
            ("minVitaminB2", minVitaminB2),
            ("maxVitaminB2", maxVitaminB2),
            ("minVitaminB5", minVitaminB5),
            ("maxVitaminB5", maxVitaminB5),
            ("minVitaminB3", minVitaminB3),
            ("maxVitaminB3", maxVitaminB3),
            ("minVitaminB6", minVitaminB6),
            ("maxVitaminB6", maxVitaminB6),
            ("minVitaminB12", minVitaminB12),
            ("maxVitaminB12", maxVitaminB12),
            ("minFiber", minFiber),
            ("maxFiber", maxFiber),
            ("minFolate", minFolate),
            ("maxFolate", maxFolate),
            ("minFolicAcid", minFolicAcid),
            ("maxFolicAcid", maxFolicAcid),
            ("minIodine", minIodine),
            ("maxIodine", maxIodine),
            ("minIron", minIron),
            ("maxIron", maxIron),
            ("minMagnesium", minMagnesium),
            ("maxMagnesium", maxMagnesium),
            ("minManganese", minManganese),
            ("maxManganese", maxManganese),
            ("minPhosphorus", minPhosphorus),
            ("maxPhosphorus", maxPhosphorus),
            ("minPotassium", minPotassium),
            ("maxPotassium", maxPotassium),
            ("minSelenium", minSelenium),
            ("maxSelenium", maxSelenium),
            ("minSodium", minSodium),
            ("maxSodium", maxSodium),
            ("minSugar", minSugar),
            ("maxSugar", maxSugar),
            ("minZinc", minZinc),
            ("maxZinc", maxZinc),
            ("minTransFat", minTransFat),
            ("maxTransFat", maxTransFat),
            ("offset", offset),
            ("number", number)
        ]
        
        for (key, value) in parameters {
            if let value = value {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            completion(.failure(.responseError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching recipes: \(error)")
                completion(.failure(.responseError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.dataError))
                return
            }
            
            do {
                let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
                completion(.success(recipeResponse.results))
            } catch {
                print("Error decoding recipe response: \(error)")
                completion(.failure(.decodeError))
            }
        }
        
        task.resume()
    }
}
