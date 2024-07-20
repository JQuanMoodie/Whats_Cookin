//
//File for API integration 
//
//Rachel Wu
//

import Foundation

struct Recipe: Codable {
    let id: Int
    let title: String
    let image: String
}

//for API errors
enum APIError: Error {
    case responseProblem
    case decodingProblem
    case otherProblem
}

//response
struct RecipeResponse: Codable {
    let results: [Recipe]
}

// Create a class for the Recipe service
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
        offset: Int? = nil,
        number: Int? = nil,
        completion: @escaping (Result<[Recipe], APIError>) -> Void) {
        
        // Create URL components
        var urlComponents = URLComponents(string: "\(baseURL)/complexSearch")!
        var queryItems = [URLQueryItem(name: "apiKey", value: apiKey)]
        
        // Add parameters to query items
        if let query = query { queryItems.append(URLQueryItem(name: "query", value: query)) }
        if let cuisine = cuisine { queryItems.append(URLQueryItem(name: "cuisine", value: cuisine)) }
        if let excludeCuisine = excludeCuisine { queryItems.append(URLQueryItem(name: "excludeCuisine", value: excludeCuisine)) }
        if let diet = diet { queryItems.append(URLQueryItem(name: "diet", value: diet)) }
        if let intolerances = intolerances { queryItems.append(URLQueryItem(name: "intolerances", value: intolerances)) }
        if let equipment = equipment { queryItems.append(URLQueryItem(name: "equipment", value: equipment)) }
        if let includeIngredients = includeIngredients { queryItems.append(URLQueryItem(name: "includeIngredients", value: includeIngredients)) }
        if let excludeIngredients = excludeIngredients { queryItems.append(URLQueryItem(name: "excludeIngredients", value: excludeIngredients)) }
        if let type = type { queryItems.append(URLQueryItem(name: "type", value: type)) }
        if let instructionsRequired = instructionsRequired { queryItems.append(URLQueryItem(name: "instructionsRequired", value: String(instructionsRequired))) }
        if let fillIngredients = fillIngredients { queryItems.append(URLQueryItem(name: "fillIngredients", value: String(fillIngredients))) }
        if let addRecipeInformation = addRecipeInformation { queryItems.append(URLQueryItem(name: "addRecipeInformation", value: String(addRecipeInformation))) }
        if let addRecipeInstructions = addRecipeInstructions { queryItems.append(URLQueryItem(name: "addRecipeInstructions", value: String(addRecipeInstructions))) }
        if let addRecipeNutrition = addRecipeNutrition { queryItems.append(URLQueryItem(name: "addRecipeNutrition", value: String(addRecipeNutrition))) }
        if let author = author { queryItems.append(URLQueryItem(name: "author", value: author)) }
        if let tags = tags { queryItems.append(URLQueryItem(name: "tags", value: tags)) }
        if let recipeBoxId = recipeBoxId { queryItems.append(URLQueryItem(name: "recipeBoxId", value: String(recipeBoxId))) }
        if let titleMatch = titleMatch { queryItems.append(URLQueryItem(name: "titleMatch", value: titleMatch)) }
        if let maxReadyTime = maxReadyTime { queryItems.append(URLQueryItem(name: "maxReadyTime", value: String(maxReadyTime))) }
        if let minServings = minServings { queryItems.append(URLQueryItem(name: "minServings", value: String(minServings))) }
        if let maxServings = maxServings { queryItems.append(URLQueryItem(name: "maxServings", value: String(maxServings))) }
        if let ignorePantry = ignorePantry { queryItems.append(URLQueryItem(name: "ignorePantry", value: String(ignorePantry))) }
        if let sort = sort { queryItems.append(URLQueryItem(name: "sort", value: sort)) }
        if let sortDirection = sortDirection { queryItems.append(URLQueryItem(name: "sortDirection", value: sortDirection)) }
        if let minCarbs = minCarbs { queryItems.append(URLQueryItem(name: "minCarbs", value: String(minCarbs))) }
        if let maxCarbs = maxCarbs { queryItems.append(URLQueryItem(name: "maxCarbs", value: String(maxCarbs))) }
        if let minProtein = minProtein { queryItems.append(URLQueryItem(name: "minProtein", value: String(minProtein))) }
        if let maxProtein = maxProtein { queryItems.append(URLQueryItem(name: "maxProtein", value: String(maxProtein))) }
        if let minCalories = minCalories { queryItems.append(URLQueryItem(name: "minCalories", value: String(minCalories))) }
        if let maxCalories = maxCalories { queryItems.append(URLQueryItem(name: "maxCalories", value: String(max))) }
        if let minFat = minFat { queryItems.append(URLQueryItem(name: "minFat", value: String(minFat))) }
        if let maxFat = maxFat { queryItems.append(URLQueryItem(name: "maxFat", value: String(maxFat))) }
        if let minAlcohol = minAlcohol { queryItems.append(URLQueryItem(name: "minAlcohol", value: String(minAlcohol))) }
        if let maxAlcohol = maxAlcohol { queryItems.append(URLQueryItem(name: "maxAlcohol", value: String(maxAlcohol))) }
        if let minCaffeine = minCaffeine { queryItems.append(URLQueryItem(name: "minCaffeine", value: String(minCaffeine))) }
        if let maxCaffeine = maxCaffeine { queryItems.append(URLQueryItem(name: "maxCaffeine", value: String(maxCaffeine))) }
        if let minCopper = minCopper { queryItems.append(URLQueryItem(name: "minCopper", value: String(minCopper))) }
        if let maxCopper = maxCopper { queryItems.append(URLQueryItem(name: "maxCopper", value: String(maxCopper))) }
        if let minCalcium = minCalcium { queryItems.append(URLQueryItem(name: "minCalcium", value: String(minCalcium))) }
        if let maxCalcium = maxCalcium { queryItems.append(URLQueryItem(name: "maxCalcium", value: String(maxCalcium))) }
        if let minCholine = minCholine { queryItems.append(URLQueryItem(name: "minCholine", value: String(minCholine))) }
        if let maxCholine = maxCholine { queryItems.append(URLQueryItem(name: "maxCholine", value: String(maxCholine))) }
        if let minCholesterol = minCholesterol { queryItems.append(URLQueryItem(name: "minCholesterol", value: String(minCholesterol))) }
        if let maxCholesterol = maxCholesterol { queryItems.append(URLQueryItem(name: "maxCholesterol", value: String(maxCholesterol))) }
        if let minFluoride = minFluoride { queryItems.append(URLQueryItem(name: "minFluoride", value: String(minFluoride))) }
        if let maxFluoride = maxFluoride { queryItems.append(URLQueryItem(name: "maxFluoride", value: String(maxFluoride))) }
        if let minSaturatedFat = minSaturatedFat { queryItems.append(URLQueryItem(name: "minSaturatedFat", value: String(minSaturatedFat))) }
        if let maxSaturatedFat = maxSaturatedFat { queryItems.append(URLQueryItem(name: "maxSaturatedFat", value: String(maxSaturatedFat))) }
        if let minVitaminA = minVitaminA { queryItems.append(URLQueryItem(name: "minVitaminA", value: String(minVitaminA))) }
        if let maxVitaminA = maxVitaminA { queryItems.append(URLQueryItem(name: "maxVitaminA", value: String(maxVitaminA))) }
        if let minVitaminC = minVitaminC { queryItems.append(URLQueryItem(name: "minVitaminC", value: String(minVitaminC))) }
        if let maxVitaminC = maxVitaminC { queryItems.append(URLQueryItem(name: "maxVitaminC", value: String(maxVitaminC))) }
        if let minVitaminD = minVitaminD { queryItems.append(URLQueryItem(name: "minVitaminD", value: String(minVitaminD))) }
        if let maxVitaminD = maxVitaminD { queryItems.append(URLQueryItem(name: "maxVitaminD", value: String(maxVitaminD))) }
        if let minVitaminE = minVitaminE { queryItems.append(URLQueryItem(name: "minVitaminE", value: String(minVitaminE))) }
        if let maxVitaminE = maxVitaminE { queryItems.append(URLQueryItem(name: "maxVitaminE", value: String(maxVitaminE))) }
        if let minVitaminK = minVitaminK { queryItems.append(URLQueryItem(name: "minVitaminK", value: String(minVitaminK))) }
        if let maxVitaminK = maxVitaminK { queryItems.append(URLQueryItem(name: "maxVitaminK", value: String(maxVitaminK))) }
        if let minVitaminB1 = minVitaminB1 { queryItems.append(URLQueryItem(name: "minVitaminB1", value: String(minVitaminB1))) }
        if let maxVitaminB1 = maxVitaminB1 { queryItems.append(URLQueryItem(name: "maxVitaminB1", value: String(maxVitaminB1))) }
        if let minVitaminB2 = minVitaminB2 { queryItems.append(URLQueryItem(name: "minVitaminB2", value: String(minVitaminB2))) }
        if let maxVitaminB2 = maxVitaminB2 { queryItems.append(URLQueryItem(name: "maxVitaminB2", value: String(maxVitaminB2))) }
        if let minVitaminB5 = minVitaminB5 { queryItems.append(URLQueryItem(name: "minVitaminB5", value: String(minVitaminB5))) }
        if let maxVitaminB5 = maxVitaminB5 { queryItems.append(URLQueryItem(name: "maxVitaminB5", value: String(maxVitaminB5))) }
        if let minVitaminB3 = minVitaminB3 { queryItems.append(URLQueryItem(name: "minVitaminB3", value: String(minVitaminB3))) }
        if let maxVitaminB3 = maxVitaminB3 { queryItems.append(URLQueryItem(name: "maxVitaminB3", value: String(maxVitaminB3))) }
        if let minVitaminB6 = minVitaminB6 { queryItems.append(URLQueryItem(name: "minVitaminB6", value: String(minVitaminB6))) }
        if let maxVitaminB6 = maxVitaminB6 { queryItems.append(URLQueryItem(name: "maxVitaminB6", value: String(maxVitaminB6))) }
        if let minVitaminB12 = minVitaminB12 { queryItems.append(URLQueryItem(name: "minVitaminB12", value: String(minVitaminB12))) }
        if let maxVitaminB12 = maxVitaminB12 { queryItems.append(URLQueryItem(name: "maxVitaminB12", value: String(maxVitaminB12))) }
        if let minFiber = minFiber { queryItems.append(URLQueryItem(name: "minFiber", value: String(minFiber))) }
        if let maxFiber = maxFiber { queryItems.append(URLQueryItem(name: "maxFiber", value: String(maxFiber))) }
        if let minFolate = minFolate { queryItems.append(URLQueryItem(name: "minFolate", value: String(minFolate))) }
        if let maxFolate = maxFolate { queryItems.append(URLQueryItem(name: "maxFolate", value: String(maxFolate))) }
        if let minFolicAcid = minFolicAcid { queryItems.append(URLQueryItem(name: "minFolicAcid", value: String(minFolicAcid))) }
        if let maxFolicAcid = maxFolicAcid { queryItems.append(URLQueryItem(name: "maxFolicAcid", value: String(maxFolicAcid))) }
        if let minIodine = minIodine { queryItems.append(URLQueryItem(name: "minIodine", value: String(minIodine))) }
        if let maxIodine = maxIodine { queryItems.append(URLQueryItem(name: "maxIodine", value: String(maxIodine))) }
        if let minIron = minIron { queryItems.append(URLQueryItem(name: "minIron", value: String(minIron))) }
        if let maxIron = maxIron { queryItems.append(URLQueryItem(name: "maxIron", value: String(maxIron))) }
        if let minMagnesium = minMagnesium { queryItems.append(URLQueryItem(name: "minMagnesium", value: String(minMagnesium))) }
        if let maxMagnesium = maxMagnesium { queryItems.append(URLQueryItem(name: "maxMagnesium", value: String(maxMagnesium))) }
        if let minManganese = minManganese { queryItems.append(URLQueryItem(name: "minManganese", value: String(minManganese))) }
        if let maxManganese = maxManganese { queryItems.append(URLQueryItem(name: "maxManganese", value: String(maxManganese))) }
        if let minPhosphorus = minPhosphorus { queryItems.append(URLQueryItem(name: "minPhosphorus", value: String(minPhosphorus))) }
        if let maxPhosphorus = maxPhosphorus { queryItems.append(URLQueryItem(name: "maxPhosphorus", value: String(maxPhosphorus))) }
        if let minPotassium = minPotassium { queryItems.append(URLQueryItem(name: "minPotassium", value: String(minPotassium))) }
        if let maxPotassium = maxPotassium { queryItems.append(URLQueryItem(name: "maxPotassium", value: String(maxPotassium))) }
        if let minSelenium = minSelenium { queryItems.append(URLQueryItem(name: "minSelenium", value: String(minSelenium))) }
        if let maxSelenium = maxSelenium { queryItems.append(URLQueryItem(name: "maxSelenium", value: String(maxSelenium))) }
        if let minSodium = minSodium { queryItems.append(URLQueryItem(name: "minSodium", value: String(minSodium))) }
        if let maxSodium = maxSodium { queryItems.append(URLQueryItem(name: "maxSodium", value: String(maxSodium))) }
        if let minSugar = minSugar { queryItems.append(URLQueryItem(name: "minSugar", value: String(minSugar))) }
        if let maxSugar = maxSugar { queryItems.append(URLQueryItem(name: "maxSugar", value: String(maxSugar))) }
        if let minZinc = minZinc { queryItems.append(URLQueryItem(name: "minZinc", value: String(minZinc))) }
        if let maxZinc = maxZinc { queryItems.append(URLQueryItem(name: "maxZinc", value: String(maxZinc))) }
        if let offset = offset { queryItems.append(URLQueryItem(name: "offset", value: String(offset))) }
        if let number = number { queryItems.append(URLQueryItem(name: "number", value: String(number))) }


        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
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
                let response = try decoder.decode(RecipeResponse.self, from: data)
                completion(.success(response.results))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

struct RecipeResponse: Decodable {
    let results: [Recipe]
}