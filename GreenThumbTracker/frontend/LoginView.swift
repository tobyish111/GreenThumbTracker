//
//  LoginView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/20/25.
//

import SwiftUI

struct LoginView: View {
    @State private var showingLoginForm: Bool = false
       @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

       var body: some View {
           NavigationStack {
               ZStack {
                   LinearGradient(
                       colors: [.zenGreen.opacity(0.8), .zenBeige.opacity(0.6), .green.opacity(0.7)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing
                   )
                   .ignoresSafeArea()

                   VStack(spacing: 30) {
                       Spacer()

                       Image(systemName: "leaf.circle.fill")
                           .resizable()
                           .scaledToFit()
                           .frame(width: 100, height: 100)
                           .foregroundStyle(.green)
                           .shadow(color: .green, radius: 5)

                       VStack(spacing: 10) {
                           Text("Welcome to")
                               .font(.title2)

                           Text("GreenThumbTracker")
                               .font(.largeTitle)
                               .fontWeight(.bold)
                               .foregroundStyle(.green)

                           Text("Please login to continue.")
                               .font(.body)
                       }
                       .multilineTextAlignment(.center)
                       .padding()

                       HStack(spacing: 30) {
                           GreenButton(title: "Login") {
                               showingLoginForm = true
                           }
                           .sheet(isPresented: $showingLoginForm) {
                               LoginFormView(showingLoginForm: $showingLoginForm)
                           }

                           GreenButton(title: "Sign Up") {
                               print("Not implemented yet!")
                           }
                       }

                       Spacer()
                   }
                   .padding(.horizontal, 32)
               }
               .navigationDestination(isPresented: $isLoggedIn) {
                   HomePageView()
               }
           }
       }
   }

//button
struct GreenButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(width: 120, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green)
                        .shadow(color: .green.opacity(0.6), radius: 4, x: 0, y: 4)
                )
                .foregroundColor(.white)
        }
    }
}

struct LoginFormView: View {
    @Binding var showingLoginForm: Bool
       @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
       @AppStorage("authToken") private var authToken: String = ""

       @State private var username: String = ""
       @State private var password: String = ""
       @State private var errorMessage: String?
       @State private var isLoading: Bool = false

       var body: some View {
           ZStack {
               //Background Gradient
               LinearGradient(
                   colors: [
                       .zenGreen.opacity(0.8),
                       .zenBeige.opacity(0.6),
                       .green.opacity(0.7)
                   ],
                   startPoint: .topLeading,
                   endPoint: .bottomTrailing
               )
               .ignoresSafeArea()

               //Main Login Form
               VStack(spacing: 20) {
                   Text("Sign In")
                       .font(.largeTitle)
                       .fontWeight(.bold)
                       .foregroundStyle(.green)

                   TextField("Username", text: $username)
                       .padding()
                       .background(Color.white.opacity(0.8))
                       .cornerRadius(10)
                       .autocapitalization(.none)

                   SecureField("Password", text: $password)
                       .padding()
                       .background(Color.white.opacity(0.8))
                       .cornerRadius(10)

                   if let errorMessage = errorMessage {
                       Text(errorMessage)
                           .foregroundColor(.red)
                           .font(.footnote)
                           .padding(.top, 5)
                   }

                   GreenButton(title: "Submit") {
                       isLoading = true
                       errorMessage = nil

                       APIManager.shared.login(username: username, password: password) { result in
                           DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                               isLoading = false
                               switch result {
                               case .success(let loginResponse):
                                   print("Login succeeded:", loginResponse)
                                   authToken = loginResponse.token
                                   showingLoginForm = false
                                   isLoggedIn = true
                               case .failure(let error):
                                   print("Login failed:", error)
                                   errorMessage = "Invalid username or password"
                               }
                           }
                       }
                   }

                   Button("Cancel") {
                       showingLoginForm = false
                   }
                   .foregroundColor(.secondary)
                   .padding(.top, 10)
               }
               .padding()
               .padding(.top, 100)

               //Loading Spinner Overlay
               if isLoading {
                   Color.black.opacity(0.3)
                       .ignoresSafeArea()

                   ProgressView("Signing In...")
                       .progressViewStyle(CircularProgressViewStyle(tint: .green))
                       .padding()
                       .background(Color.white)
                       .cornerRadius(12)
                       .shadow(radius: 5)
                       .transition(.opacity)
               }
           }
           .animation(.easeInOut, value: isLoading)
       }
}

#Preview {
    LoginView()
}
