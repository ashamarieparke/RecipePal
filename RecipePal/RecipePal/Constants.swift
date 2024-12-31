//
//  Constants.swift
//  RecipePal
//
//  Created by Ashamarie Natayla Parke on 11/27/24.
//

import Foundation

// MARK: - Models
struct RecipeDetail: Identifiable, Codable {
    let id: Int
    let title: String
    let image: String
    let imageType: String?
    let servings: Int?
    let readyInMinutes: Int?
    let sourceName: String?
    let sourceUrl: String?
    let spoonacularSourceUrl: String?
    let healthScore: Int?
    let spoonacularScore: Double?
    let pricePerServing: Double?
    let cheap: Bool?
    let creditsText: String?
    let license: String?
    let summary: String?
    let cuisines: [String]?
    let dishTypes: [String]?
    let diets: [String]?
    let occasions: [String]?
    let instructions: String?
    let analyzedInstructions: [AnalyzedInstruction]?
    let originalId: Int?
    let likes: Int?
    
    // Search-specific fields
    let usedIngredientCount: Int?
    let missedIngredientCount: Int?
    let missedIngredients: [Ingredient]?
    let usedIngredients: [Ingredient]?
    let unusedIngredients: [Ingredient]?
    let extendedIngredients: [Ingredient]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, image, imageType, servings, readyInMinutes, sourceName
        case sourceUrl, spoonacularSourceUrl, healthScore, spoonacularScore
        case pricePerServing, cheap, creditsText, license, summary, cuisines
        case dishTypes, diets, occasions, instructions, analyzedInstructions
        case originalId, likes
        case usedIngredientCount, missedIngredientCount
        case missedIngredients, usedIngredients, unusedIngredients
        case extendedIngredients
    }
}

struct AnalyzedInstruction: Codable {
    let name: String?
    let steps: [Step]?
}

struct Step: Codable {
    let number: Int?
    let step: String?
    let ingredients: [Ingredient]?
    let equipment: [Equipment]?
}

struct Equipment: Codable {
    let id: Int?
    let name: String?
    let localizedName: String?
    let image: String?
}

struct Ingredient: Codable, Identifiable {
    let id: Int
    let name: String
    let localizedName: String?
    let image: String?
    let amount: Double?
    let unit: String?
    let unitLong: String?
    let unitShort: String?
    let aisle: String?
    let original: String?
    let originalName: String?
    let meta: [String]?
    let extendedName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, localizedName, image, amount, unit, unitLong, unitShort
        case aisle, original, originalName, meta, extendedName
    }
}

struct SearchResponse: Codable {
    let results: [RecipeDetail]
    let offset: Int
    let number: Int
    let totalResults: Int
}

// API Constants
struct APIConstants {
    static let baseURL = "https://api.spoonacular.com"
    static let searchByIngredientsEndpoint = "/recipes/complexSearch"
    static let recipeInformationEndpoint = "/recipes/{id}/information"
    
    static func getAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["SpoonacularAPIKey"] as? String else {
            return nil
        }
        return key.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\"", with: "")
    }
}
