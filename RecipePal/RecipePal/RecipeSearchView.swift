//
//  RecipeSearchView.swift
//  RecipePal
//
//  Created by Ashamarie Natayla Parke on 11/25/24.
//

import SwiftUI

struct RecipeSearchView: View {
    @StateObject var viewModel = RecipeViewModel()
    @State private var searchText = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Search Bar
                HStack {
                    TextField("Search recipes by ingredients (e.g. chicken,rice)", text: $viewModel.searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
                .padding(.horizontal)
                
                
                // Search Results Section
                if !viewModel.searchQuery.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Search Results")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity)
                        } else if let error = viewModel.error {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        } else if viewModel.filteredRecipes.isEmpty {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("No recipes found")
                                    .font(.headline)
                                Text("Try different ingredients or check your spelling")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredRecipes) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        RecipeRow(recipe: recipe, viewModel: viewModel)
                                    }
                                    .foregroundColor(.primary)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                // Favorite Recipes Section
                if !viewModel.favoriteRecipes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Favorite Recipes")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(viewModel.favoriteRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    RecipeRow(recipe: recipe, viewModel: viewModel)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.vertical)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Recipe Search")
        .onAppear {
        }
    }
}

#Preview {
    NavigationView {
        RecipeSearchView()
    }
}
