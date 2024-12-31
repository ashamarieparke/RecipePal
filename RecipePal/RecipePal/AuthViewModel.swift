//
//  AuthViewModel.swift
//  RecipePal
//
//  Created by Ashamarie Natayla Parke on 11/15/24.
//

import Combine
import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String?

    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Implemented login logic
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
            } else {
                self.isLoggedIn = true
                completion(.success(()))
            }
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Implemented signup logic
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
            } else {
                self.isLoggedIn = true
                completion(.success(()))
            }
        }
    }

    // MARK: - Logout Method
    func logout() {
           do {
               try Auth.auth().signOut()
               isLoggedIn = false
           } catch {
               errorMessage = error.localizedDescription
           }
       }

    // MARK: - Check Authentication State
    func checkAuthenticationState() {
        if let user = Auth.auth().currentUser {
                    isLoggedIn = true
                    print("User is logged in: \(user.email ?? "No email")")
                } else {
                    isLoggedIn = false
                    print("No user is logged in.")
                }
    }
}

