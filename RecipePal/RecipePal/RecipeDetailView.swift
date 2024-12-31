//
//  RecipeDetailView.swift
//  RecipePal
//
//  Created by Ashamarie Natayla Parke on 11/13/24.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: RecipeDetail
    @StateObject private var viewModel = RecipeViewModel()
    
    private func stripHTML(_ text: String) -> String {
        let pattern = "<[^>]+>"
        return text.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Recipe Image
                if let url = URL(string: recipe.image) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .clipped()
                        case .failure:
                            Color.gray
                                .frame(height: 250)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.white)
                                )
                        case .empty:
                            ProgressView()
                                .frame(height: 250)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(recipe.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Basic Info
                    HStack(spacing: 20) {
                        if let servings = recipe.servings {
                            Label("\(servings) servings", systemImage: "person.2.fill")
                        }
                        if let time = recipe.readyInMinutes {
                            Label("\(time) min", systemImage: "clock.fill")
                        }
                        if let likes = recipe.likes {
                            Label("\(likes) likes", systemImage: "heart.fill")
                        }
                    }
                    .foregroundColor(.secondary)
                    
                    // Ingredients Section
                    if let ingredients = recipe.extendedIngredients, !ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(ingredients) { ingredient in
                                HStack {
                                    Text("•")
                                    if let original = ingredient.original {
                                        Text(stripHTML(original))
                                    } else {
                                        Text("\(ingredient.amount?.formatted() ?? "") \(ingredient.unit ?? "") \(ingredient.name)")
                                    }
                                }
                            }
                        }
                    }
                    
                    // Instructions Section
                    if let instructions = recipe.instructions, !instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instructions")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(stripHTML(instructions))
                        }
                    }
                    
                    // Summary Section
                    if let summary = recipe.summary, !summary.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Summary")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(stripHTML(summary))
                        }
                    }
                    
                    // Source Link
                    if let sourceUrl = recipe.sourceUrl, let url = URL(string: sourceUrl) {
                        Link("View Original Recipe", destination: url)
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top)
                    }
                }
                .padding()
            }
        }
        .navigationBarItems(trailing: favoriteButton)
    }
    
    private var favoriteButton: some View {
        Button(action: {
            viewModel.toggleFavorite(recipe)
        }) {
            Image(systemName: viewModel.isFavorite(recipe) ? "heart.fill" : "heart")
                .foregroundColor(viewModel.isFavorite(recipe) ? .red : .gray)
        }
    }
}

#Preview {
    NavigationView {
        RecipeDetailView(
            recipe: RecipeDetail(
                id: 1,
                title: "Test Recipe",
                image: "https://example.com/image.jpg",
                imageType: "jpg",
                servings: 4,
                readyInMinutes: 30,
                sourceName: "Test Source",
                sourceUrl: "https://example.com",
                spoonacularSourceUrl: nil,
                healthScore: 80,
                spoonacularScore: 90,
                pricePerServing: 2.50,
                cheap: true,
                creditsText: nil,
                license: nil,
                summary: "A test recipe",
                cuisines: ["Italian"],
                dishTypes: ["main course"],
                diets: ["vegetarian"],
                occasions: ["dinner"],
                instructions: "Test instructions",
                analyzedInstructions: nil,
                originalId: nil,
                likes: 100,
                usedIngredientCount: 3,
                missedIngredientCount: 2,
                missedIngredients: [],
                usedIngredients: [],
                unusedIngredients: [],
                extendedIngredients: []
            )
        )
    }
}
