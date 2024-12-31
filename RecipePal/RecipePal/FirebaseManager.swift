//
//  FirebaseManager.swift
//  RecipePal
//
//  Created by Ashamarie Natayla Parke on 11/28/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    @Published var favoriteRecipes: [RecipeDetail] = []
    @Published var isSignedIn: Bool = false
    private var favoriteIds: Set<Int> = []
    private var listener: ListenerRegistration?
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            DispatchQueue.main.async {
                self?.isSignedIn = user != nil
                if user != nil {
                    self?.loadFavoriteRecipes()
                } else {
                    self?.favoriteRecipes = []
                    self?.favoriteIds = []
                }
            }
        }
    }
    
    func signInAnonymously(completion: @escaping (Error?) -> Void) {
        Auth.auth().signInAnonymously { [weak self] (result, error) in
            if let error = error {
                print("Error signing in: \(error)")
                completion(error)
                return
            }
            
            print("Successfully signed in anonymously")
            self?.loadFavoriteRecipes()
            completion(nil)
        }
    }
    
    func toggleFavorite(_ recipe: RecipeDetail, completion: @escaping (Bool, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            // If not signed in, try to sign in anonymously first
            signInAnonymously { [weak self] error in
                if let error = error {
                    completion(false, error)
                } else {
                    // Retry toggle after signing in
                    self?.toggleFavorite(recipe, completion: completion)
                }
            }
            return
        }
        
        let recipeRef = db.collection("users").document(user.uid).collection("favorites").document("\(recipe.id)")
        
        if isFavorite(recipe.id) {
            // Remove from favorites
            recipeRef.delete { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error removing favorite: \(error)")
                        completion(false, error)
                    } else {
                        print("Successfully removed favorite")
                        self?.favoriteIds.remove(recipe.id)
                        completion(false, nil)
                    }
                }
            }
        } else {
            // Add to favorites
            do {
                let recipeData = try JSONEncoder().encode(recipe)
                guard let recipeDict = try JSONSerialization.jsonObject(with: recipeData) as? [String: Any] else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert recipe to dictionary"])
                }
                
                recipeRef.setData(recipeDict) { [weak self] error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error adding favorite: \(error)")
                            completion(false, error)
                        } else {
                            print("Successfully added favorite")
                            self?.favoriteIds.insert(recipe.id)
                            completion(true, nil)
                        }
                    }
                }
            } catch {
                print("Error encoding recipe: \(error)")
                completion(false, error)
            }
        }
    }
    
    func isFavorite(_ recipeId: Int) -> Bool {
        return favoriteIds.contains(recipeId)
    }
    
    private func loadFavoriteRecipes() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        // Remove existing listener if any
        listener?.remove()
        
        // Set up real-time listener for favorites
        listener = db.collection("users").document(userId).collection("favorites")
            .addSnapshotListener { [weak self] (snapshot, error) in
                if let error = error {
                    print("Error loading favorites: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No favorites found")
                    DispatchQueue.main.async {
                        self?.favoriteRecipes = []
                        self?.favoriteIds = []
                    }
                    return
                }
                
                let recipes = documents.compactMap { document -> RecipeDetail? in
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data())
                        return try JSONDecoder().decode(RecipeDetail.self, from: data)
                    } catch {
                        print("Error decoding recipe: \(error)")
                        return nil
                    }
                }
                
                DispatchQueue.main.async {
                    self?.favoriteRecipes = recipes
                    self?.favoriteIds = Set(recipes.map { $0.id })
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
}
