//
//  ContentView.swift
//  RecipePal
//
//  Created by Ashamarie Natayla Parke on 11/27/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RecipeViewModel()
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoggedIn {
                    RecipeSearchView()
                        .navigationBarItems(trailing: signOutButton)
                } else {
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }
            .navigationTitle("RecipePal")
        }
    }
    
    private var signOutButton: some View {
        Button(action: signOut) {
            Text("Sign Out")
                .foregroundColor(.red)
        }
    }
    
    private func signOut() {
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "favoriteRecipes")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
