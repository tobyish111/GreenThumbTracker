//
//  RegisterView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/25/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var username = ""
        @State private var email = ""
        @State private var password = ""
        @State private var confirmPassword = ""
        @State private var errorMessage: String?
        @State private var successMessage: String?
        @State private var isLoading = false

        var body: some View {
            ZStack {
                LinearGradient(colors: [.zenGreen.opacity(0.8), .zenBeige.opacity(0.3)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Create Account")
                        .font(.largeTitle.bold())
                        .foregroundColor(.green)

                    Group {
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        SecureField("Password", text: $password)
                            .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        SecureField("Confirm Password", text: $confirmPassword)
                            .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                    }
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                    if let error = errorMessage {
                        Text("❌ \(error)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    if let success = successMessage {
                        Text("✅ \(success)")
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                    }

                    if isLoading{
                        ProgressView()
                    } else{
                        GreenButton(title: "Register", action: registerUser)
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Register", displayMode: .inline)
        }

        private func registerUser() {
            errorMessage = nil
            successMessage = nil

            guard !username.isEmpty && !email.isEmpty && !password.isEmpty else {
                errorMessage = "All fields are required."
                return
            }

            guard password == confirmPassword else {
                errorMessage = "Passwords do not match."
                return
            }

            isLoading = true
            APIManager.shared.register(username: username, email: email, password: password) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success:
                        successMessage = "Registration successful! Check your email to verify."
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

#Preview {
    RegisterView()
}
