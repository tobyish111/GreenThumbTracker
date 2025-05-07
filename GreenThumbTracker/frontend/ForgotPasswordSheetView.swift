//
//  ForgotPasswordSheetView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/6/25.
//

import SwiftUI

struct ForgotPasswordSheetView: View {
    @Environment(\.dismiss) var dismiss

       @State private var email: String = ""
       @State private var isLoading = false
       @State private var showSuccess = false
       @State private var errorMessage: String?
       
       var body: some View {
           ZStack {
               LinearGradient(
                   colors: [.zenGreen.opacity(0.8), .zenBeige.opacity(0.6), .green.opacity(0.7)],
                   startPoint: .topLeading,
                   endPoint: .bottomTrailing
               )
               .ignoresSafeArea()
               
               VStack(spacing: 20) {
                   Spacer()
                   
                   Text("Reset Your Password")
                       .font(.title)
                       .fontWeight(.bold)
                       .foregroundColor(.green)
                   
                   TextField("Enter your email", text: $email)
                       .padding()
                       .background(Color.white.opacity(0.8))
                       .cornerRadius(10)
                       .keyboardType(.emailAddress)
                       .autocapitalization(.none)

                   if let error = errorMessage {
                       Text(error)
                           .foregroundColor(.red)
                           .font(.footnote)
                           .padding(.horizontal)
                           .transition(.opacity)
                   }

                   if isLoading {
                       ProgressView()
                           .progressViewStyle(CircularProgressViewStyle(tint: .green))
                           .scaleEffect(1.2)
                   } else if showSuccess {
                       Image(systemName: "checkmark.circle.fill")
                           .resizable()
                           .frame(width: 60, height: 60)
                           .foregroundColor(.green)
                           .transition(.scale.combined(with: .opacity))
                           .scaleEffect(1.2)
                           .padding(.top)
                   } else {
                       Button("Send Reset Email") {
                           submitReset()
                       }
                       .font(.headline)
                       .frame(maxWidth: .infinity)
                       .padding()
                       .background(Color.green)
                       .foregroundColor(.white)
                       .cornerRadius(10)
                   }
                   
                   Spacer()
                   
                   Button("Cancel") {
                       dismiss()
                   }
                   .foregroundColor(.secondary)
               }
               .padding()
           }
       }

       func submitReset() {
           let generator = UINotificationFeedbackGenerator()

           guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
               errorMessage = "Please enter your email."
               return
           }
           
           errorMessage = nil
           isLoading = true

           APIManager.shared.sendForgotPasswordEmail(email: email) { result in
               DispatchQueue.main.async {
                   isLoading = false
                   switch result {
                   case .success:
                       //haptic feedback
                       generator.notificationOccurred(.success)
                       
                       withAnimation {
                           showSuccess = true
                       }
                       DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                           dismiss()
                       }
                   case .failure(let error):
                       generator.notificationOccurred(.error)
                       errorMessage = "Failed to send reset email: \(error.localizedDescription)"
                   }
               }
           }
       }
   }

    
#Preview {
    ForgotPasswordSheetView()
}
