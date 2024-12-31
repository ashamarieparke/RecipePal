//
//  MockData.swift
//  RecipePal
//
//  Created by Ashamarie Natayla Parke on 11/27/24.
//

import Foundation

struct MockData {
    static let mockIngredients: [Ingredient] = [
        Ingredient(
            id: 1,
            name: "chicken breast",
            localizedName: "chicken breast",
            image: "chicken-breast.jpg",
            amount: 2,
            unit: "piece",
            unitLong: "pieces",
            unitShort: "pc",
            aisle: "Meat",
            original: "2 chicken breasts",
            originalName: "chicken breasts",
            meta: ["boneless", "skinless"],
            extendedName: "boneless skinless chicken breast"
        ),
        Ingredient(
            id: 2,
            name: "broccoli",
            localizedName: "broccoli",
            image: "broccoli.jpg",
            amount: 2,
            unit: "cups",
            unitLong: "cups",
            unitShort: "cup",
            aisle: "Produce",
            original: "2 cups broccoli florets",
            originalName: "broccoli florets",
            meta: ["florets"],
            extendedName: "broccoli florets"
        ),
        Ingredient(
            id: 3,
            name: "spaghetti",
            localizedName: "spaghetti",
            image: "spaghetti.jpg",
            amount: 8,
            unit: "ounce",
            unitLong: "ounces",
            unitShort: "oz",
            aisle: "Pasta and Rice",
            original: "8 oz spaghetti",
            originalName: "spaghetti",
            meta: [],
            extendedName: nil
        )
    ]
    
    static let mockRecipes: [RecipeDetail] = [
        RecipeDetail(
            id: 1,
            title: "Easy Chicken Stir Fry",
            image: "https://spoonacular.com/recipeImages/1-556x370.jpg",
            imageType: "jpg",
            servings: 4,
            readyInMinutes: 30,
            sourceName: "RecipePal",
            sourceUrl: "https://example.com/chicken-stir-fry",
            spoonacularSourceUrl: nil,
            healthScore: 85,
            spoonacularScore: 95,
            pricePerServing: 2.50,
            cheap: true,
            creditsText: nil,
            license: nil,
            summary: "This easy chicken stir fry is perfect for busy weeknights. Made with tender chicken breast and fresh vegetables in a savory sauce.",
            cuisines: ["Asian", "Chinese"],
            dishTypes: ["main course", "dinner"],
            diets: ["dairy-free"],
            occasions: ["weeknight dinner"],
            instructions: """
                1. Cut chicken into bite-sized pieces
                2. Heat oil in a large wok or skillet
                3. Cook chicken until golden brown
                4. Add broccoli and stir-fry
                5. Pour sauce over and simmer
                6. Serve hot over rice
                """,
            analyzedInstructions: nil,
            originalId: nil,
            likes: 150,
            usedIngredientCount: 1,
            missedIngredientCount: 2,
            missedIngredients: [mockIngredients[1]],
            usedIngredients: [mockIngredients[0]],
            unusedIngredients: [],
            extendedIngredients: [mockIngredients[0], mockIngredients[1]]
        ),
        RecipeDetail(
            id: 2,
            title: "Classic Spaghetti",
            image: "https://spoonacular.com/recipeImages/2-556x370.jpg",
            imageType: "jpg",
            servings: 4,
            readyInMinutes: 25,
            sourceName: "RecipePal",
            sourceUrl: "https://example.com/classic-spaghetti",
            spoonacularSourceUrl: nil,
            healthScore: 70,
            spoonacularScore: 85,
            pricePerServing: 1.75,
            cheap: true,
            creditsText: nil,
            license: nil,
            summary: "A classic spaghetti recipe that's quick and easy to prepare. Perfect for a family dinner.",
            cuisines: ["Italian"],
            dishTypes: ["main course", "dinner"],
            diets: ["vegetarian"],
            occasions: ["weeknight dinner"],
            instructions: """
                1. Boil water in a large pot
                2. Add spaghetti and cook until al dente
                3. Drain and serve with your favorite sauce
                """,
            analyzedInstructions: nil,
            originalId: nil,
            likes: 120,
            usedIngredientCount: 1,
            missedIngredientCount: 1,
            missedIngredients: [],
            usedIngredients: [mockIngredients[2]],
            unusedIngredients: [],
            extendedIngredients: [mockIngredients[2]]
        )
    ]
    
    static func getMockRecipeDetail(id: Int) -> RecipeDetail? {
        return mockRecipes.first { $0.id == id }
    }
}
