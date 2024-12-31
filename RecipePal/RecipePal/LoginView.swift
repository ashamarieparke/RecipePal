//
//  LoginView.swift
//  RecipePal
//
//  Created by Ashamarie Natayla Parke on 11/15/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingSignup: Bool = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack {
            Text("Login to RecipePal!")
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
                    .padding()
            }

            Button("Login") {
                authViewModel.login(email: email, password: password) { result in
                    switch result {
                    case .success:
                        isLoggedIn = true
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Sign Up") {
                showingSignup = true
            }
            .padding()
            .sheet(isPresented: $showingSignup) {
                SignupView() // Navigate to signup view
            }
        }
        .padding()
        Spacer()
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
