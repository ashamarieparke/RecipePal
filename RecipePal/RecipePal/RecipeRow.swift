//
//  RecipeRow.swift
//  RecipePal
//
//  Created by Ashamarie Natayla Parke on 11/27/24.
//

import SwiftUI

struct RecipeRow: View {
    let recipe: RecipeDetail
    @ObservedObject var viewModel: RecipeViewModel
    
    var body: some View {
        HStack {
            if let imageUrl = URL(string: recipe.image) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        Color.gray
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .empty:
                        ProgressView()
                            .frame(width: 60, height: 60)
                    @unknown default:
                        Color.gray
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)
                    .accessibilityLabel("Recipe title: \(recipe.title)")
                
                if let readyInMinutes = recipe.readyInMinutes {
                    Text("\(readyInMinutes) minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                //shows ingredients needed
                HStack {
                    if let ingredients = recipe.extendedIngredients {
                        Text("\(ingredients.count) ingredients")
                            .foregroundColor(.secondary)
                    }
                    if let time = recipe.readyInMinutes {
                        Text("•")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        Text("\(time) min")
                            .foregroundColor(.secondary)
                    }
                }
                .font(.caption)
            }

            Spacer()

            Button(action: {
                withAnimation {
                    viewModel.toggleFavorite(recipe)
                }
                // Add haptic feedback for button tap
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }) {
                Image(systemName: viewModel.isFavorite(recipe) ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isFavorite(recipe) ? .red : .gray)
            }
        }
        .padding(.vertical, 8)
    }
}

struct RecipeRow_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = RecipeViewModel()
        RecipeRow(
            recipe: MockData.mockRecipes[0],
            viewModel: viewModel
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
