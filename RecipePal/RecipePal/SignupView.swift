//
//  SignupView.swift
//  RecipePal
//
//  Created by Ashamarie Natayla Parke on 11/15/24.
//

import SwiftUI

struct SignupView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    var body: some View {
        VStack {
            Text("Welcome to RecipePal!")
                .font(.largeTitle)
                .padding()
            TextField("Username/Email", text: $email)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button("Create Account") {
                authViewModel.signUp(email: email, password: password) { result in
                    switch result {
                    case .success:
                        print("Sign up successful")
                        isLoggedIn = true
                        dismiss()
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

#Preview {
    SignupView()
}
