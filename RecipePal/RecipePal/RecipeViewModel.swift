//
//  RecipeViewModel.swift
//  RecipePal
//
//  Created by Ashamarie Natayla Parke on 11/27/24.
//

import Foundation
import Combine

class RecipeViewModel: ObservableObject {
    @Published var recipes: [RecipeDetail] = []
    @Published var filteredRecipes: [RecipeDetail] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var searchQuery: String = ""
    @Published var useMockData: Bool = false
    @Published var favoriteRecipes: [RecipeDetail] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let apiKey: String
    private var recipeCache: [Int: RecipeDetail] = [:] // Cache for recipe details
    private var lastSearchQuery: String = "" // Track last search
    private let firebaseManager = FirebaseManager.shared
    
    init() {
        // Load API key using APIConstants
        if let key = APIConstants.getAPIKey() {
            self.apiKey = key
            print("API Key loaded successfully")
        } else {
            self.apiKey = ""
            print("Failed to load API key")
            self.error = "API key not found. Please check your configuration."
        }
        
        // Setup search query subscription with shorter debounce
        $searchQuery
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main) // Reduced from 300ms
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                
                // Only search if query is different
                if query != self.lastSearchQuery {
                    print("Search query changed: \(query)")
                    if !query.isEmpty {
                        self.searchRecipes(with: query)
                    } else {
                        self.filteredRecipes = []
                    }
                    self.lastSearchQuery = query
                }
            }
            .store(in: &cancellables)
            
        // Subscribe to favorite recipes updates
        firebaseManager.$favoriteRecipes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recipes in
                self?.favoriteRecipes = recipes
            }
            .store(in: &cancellables)
    }
    
    func toggleFavorite(_ recipe: RecipeDetail) {
        firebaseManager.toggleFavorite(recipe) { [weak self] (isFavorited, error) in
            if let error = error {
                self?.error = "Failed to update favorite: \(error.localizedDescription)"
            }
        }
    }
    
    func isFavorite(_ recipe: RecipeDetail) -> Bool {
        return firebaseManager.isFavorite(recipe.id)
    }
    
    func searchRecipes(with query: String) {
        if useMockData {
            // Use mock data
            print("Using mock data for search")
            self.isLoading = true
            
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Reduced delay
                self.recipes = MockData.mockRecipes
                self.filteredRecipes = MockData.mockRecipes.filter { recipe in
                    recipe.title.lowercased().contains(query.lowercased())
                }
                self.isLoading = false
            }
            return
        }
        
        // Use real API
        guard !apiKey.isEmpty else {
            self.error = "API key not configured"
            return
        }
        
        isLoading = true
        error = nil
        print("Starting search with query: \(query)")
        
        // Base URL components
        guard var urlComponents = URLComponents(string: "\(APIConstants.baseURL)\(APIConstants.searchByIngredientsEndpoint)") else {
            self.error = "Invalid URL configuration"
            self.isLoading = false
            return
        }
        
        // Add query parameters
        urlComponents.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "number", value: "10"),
            URLQueryItem(name: "addRecipeInformation", value: "true"),
            URLQueryItem(name: "fillIngredients", value: "true"),
            URLQueryItem(name: "instructionsRequired", value: "true")
        ]
        
        guard let url = urlComponents.url else {
            self.error = "Invalid URL"
            self.isLoading = false
            return
        }
        
        print("Fetching recipes from: \(url.absoluteString.replacingOccurrences(of: apiKey, with: "API_KEY"))")
        
        // Configure URLSession with longer timeout and better caching
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30 // Increase timeout to 30 seconds
        config.timeoutIntervalForResource = 300 // Allow up to 5 minutes for the entire resource
        config.requestCachePolicy = .returnCacheDataElseLoad // Use cached data when available
        config.waitsForConnectivity = true // Wait for network connectivity
        
        let session = URLSession(configuration: config)
        
        session.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("Search response code: \(response.statusCode)")
                
                switch response.statusCode {
                case 200:
                    return output.data
                case 401:
                    throw NSError(domain: "API", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid API key"])
                case 402:
                    throw NSError(domain: "API", code: 402, userInfo: [NSLocalizedDescriptionKey: "API quota exceeded"])
                case 408, URLError.timedOut.rawValue:
                    throw NSError(domain: "API", code: 408, userInfo: [NSLocalizedDescriptionKey: "Request timed out. Please check your internet connection and try again."])
                case 429:
                    throw NSError(domain: "API", code: 429, userInfo: [NSLocalizedDescriptionKey: "Too many requests. Please try again later."])
                case 500...599:
                    throw NSError(domain: "API", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error. Please try again later."])
                default:
                    let errorMessage = String(data: output.data, encoding: .utf8) ?? "Unknown error"
                    throw NSError(domain: "API", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
            }
            .decode(type: SearchResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    print("Search failed with error: \(error.localizedDescription)")
                    
                    // Handle network-specific errors
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet:
                            self.error = "No internet connection. Please check your network settings."
                        case .timedOut:
                            self.error = "Request timed out. Please check your internet connection and try again."
                        case .networkConnectionLost:
                            self.error = "Network connection was lost. Please try again."
                        default:
                            self.error = "Network error: \(urlError.localizedDescription)"
                        }
                    } else {
                        self.error = error.localizedDescription
                    }
                    
                    // Fall back to mock data if available and enabled
                    if self.useMockData {
                        print("Falling back to mock data after error")
                        self.recipes = MockData.mockRecipes
                        self.filteredRecipes = MockData.mockRecipes.filter { recipe in
                            recipe.title.lowercased().contains(self.searchQuery.lowercased())
                        }
                    }
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                print("Successfully fetched \(response.results.count) recipes")
                self.recipes = response.results
                self.filteredRecipes = response.results
            }
            .store(in: &cancellables)
    }
    
    func fetchRecipeDetail(for id: Int, completion: @escaping (RecipeDetail?, String?) -> Void) {
        // Check cache first
        if let cachedRecipe = recipeCache[id] {
            print("Using cached recipe detail for id: \(id)")
            completion(cachedRecipe, nil)
            return
        }
        
        if useMockData {
            print("Using mock data for recipe detail")
            if let recipe = MockData.getMockRecipeDetail(id: id) {
                self.recipeCache[id] = recipe
                completion(recipe, nil)
            } else {
                completion(nil, "Recipe not found in mock data")
            }
            return
        }
        
        guard !apiKey.isEmpty else {
            completion(nil, "API key not configured")
            return
        }
        
        let endpoint = APIConstants.recipeInformationEndpoint.replacingOccurrences(of: "{id}", with: "\(id)")
        guard var urlComponents = URLComponents(string: "\(APIConstants.baseURL)\(endpoint)") else {
            completion(nil, "Invalid URL")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "includeNutrition", value: "false")
        ]
        
        guard let url = urlComponents.url else {
            completion(nil, "Invalid URL")
            return
        }
        
        print("Fetching recipe detail for ID: \(id)")
        print("URL: \(url.absoluteString.replacingOccurrences(of: apiKey, with: "API_KEY"))")
        
        // Configure URLSession with improved settings
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30 // Increase timeout to 30 seconds
        config.timeoutIntervalForResource = 300 // Allow up to 5 minutes for the entire resource
        config.requestCachePolicy = .returnCacheDataElseLoad // Use cached data when available
        config.waitsForConnectivity = true // Wait for network connectivity
        
        let session = URLSession(configuration: config)
        
        session.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("Recipe detail response code: \(response.statusCode)")
                
                // Log the response data for debugging
                if let responseString = String(data: output.data, encoding: .utf8) {
                    print("Recipe detail response data: \(responseString)")
                }
                
                switch response.statusCode {
                case 200:
                    return output.data
                case 401:
                    throw NSError(domain: "API", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid API key"])
                case 402:
                    throw NSError(domain: "API", code: 402, userInfo: [NSLocalizedDescriptionKey: "API quota exceeded"])
                case 404:
                    throw NSError(domain: "API", code: 404, userInfo: [NSLocalizedDescriptionKey: "Recipe not found"])
                case 408, URLError.timedOut.rawValue:
                    throw NSError(domain: "API", code: 408, userInfo: [NSLocalizedDescriptionKey: "Request timed out. Please check your internet connection and try again."])
                case 429:
                    throw NSError(domain: "API", code: 429, userInfo: [NSLocalizedDescriptionKey: "Too many requests. Please try again later."])
                case 500...599:
                    throw NSError(domain: "API", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error. Please try again later."])
                default:
                    let errorMessage = String(data: output.data, encoding: .utf8) ?? "Unknown error"
                    throw NSError(domain: "API", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
            }
            .decode(type: RecipeDetail.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completionResult in
                if case .failure(let error) = completionResult {
                    print("Recipe detail fetch failed: \(error.localizedDescription)")
                    
                    // Handle network-specific errors
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet:
                            completion(nil, "No internet connection. Please check your network settings.")
                        case .timedOut:
                            completion(nil, "Request timed out. Please check your internet connection and try again.")
                        case .networkConnectionLost:
                            completion(nil, "Network connection was lost. Please try again.")
                        default:
                            completion(nil, "Network error: \(urlError.localizedDescription)")
                        }
                    } else if let decodingError = error as? DecodingError {
                        print("Decoding error: \(decodingError)")
                        completion(nil, "Failed to decode recipe data")
                    } else {
                        completion(nil, error.localizedDescription)
                    }
                    
                    // Fall back to mock data if enabled
                    if self.useMockData, let mockRecipe = MockData.getMockRecipeDetail(id: id) {
                        print("Falling back to mock data after error")
                        self.recipeCache[id] = mockRecipe
                        completion(mockRecipe, nil)
                    }
                }
            } receiveValue: { [weak self] recipe in
                print("Successfully fetched recipe detail")
                self?.recipeCache[id] = recipe
                completion(recipe, nil)
            }
            .store(in: &cancellables)
    }
}
