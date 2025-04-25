//
//  HomePageView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/20/25.
//

import SwiftUI

struct HomePageView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true
    @Namespace private var navNamespace
    @State private var showCustomLogoutPrompt = false
    @State private var isLoggingOut = false

    var body: some View {
        NavigationStack {
                   ZStack {
                       // Background gradient
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

                       VStack(spacing: 30) {
                           //Header
                           VStack(spacing: 8) {
                               Image(systemName: "leaf.fill")
                                   .resizable()
                                   .scaledToFit()
                                   .frame(width: 60, height: 60)
                                   .foregroundColor(.green)
                                   .shadow(radius: 3)

                               Text("GreenThumbTracker")
                                   .font(.largeTitle)
                                   .fontWeight(.bold)
                                   .foregroundStyle(.green)

                               Text("Your garden, in your hands.")
                                   .font(.subheadline)
                                   .foregroundColor(.gray)
                           }
                           .padding(.top, 40)

                           //Main Menu Buttons
                           VStack(spacing: 20) {
                               HomeNavLink(title: "Add a Plant", systemImage: "plus.circle", destination: AddPlantView(), namespace: navNamespace)
                               HomeNavLink(title: "View My Plants", systemImage: "leaf", destination: ViewPlantsView(), namespace: navNamespace)
                               HomeNavLink(title: "Encyclopedia", systemImage: "book", destination: EncyclopediaMenuView(), namespace: navNamespace)

                               // ✅ Log Out Button styled like the rest
                               Button(action: {
                                   withAnimation {
                                       showCustomLogoutPrompt = true
                                   }
                               }) {
                                   HStack {
                                       Image(systemName: "rectangle.portrait.and.arrow.right")
                                           .foregroundColor(.white)
                                           .font(.title2)
                                           .frame(width: 36)

                                       Text("Log Out")
                                           .font(.headline)
                                           .foregroundColor(.white)

                                       Spacer()
                                       Image(systemName: "chevron.right")
                                           .foregroundColor(.white.opacity(0.7))
                                   }
                                   .padding()
                                   .background(
                                       RoundedRectangle(cornerRadius: 16)
                                           .fill(Color.green)
                                           .shadow(color: .green.opacity(0.4), radius: 4, x: 0, y: 4)
                                   )
                                   .matchedGeometryEffect(id: "Log Out", in: navNamespace)
                               }
                           }

                           Spacer()
                       }
                       .padding(.horizontal, 24)

                       // ✅ Zen-styled logout confirmation modal
                       if showCustomLogoutPrompt {
                           Color.black.opacity(0.4)
                               .ignoresSafeArea()
                               .zIndex(1)

                           VStack(spacing: 16) {
                               Text("Log out of GreenThumb Tracker?")
                                   .font(.title2)
                                   .fontWeight(.semibold)
                                   .multilineTextAlignment(.center)

                               Text("You'll need to log in again to access your plants.")
                                   .font(.subheadline)
                                   .foregroundColor(.gray)
                                   .multilineTextAlignment(.center)

                               HStack(spacing: 20) {
                                   Button("Cancel") {
                                       withAnimation {
                                           showCustomLogoutPrompt = false
                                       }
                                   }
                                   .padding()
                                   .frame(maxWidth: .infinity)
                                   .background(Color.zenBeige)
                                   .cornerRadius(12)

                                   Button("Log Out") {
                                       logout()
                                   }
                                   .padding()
                                   .frame(maxWidth: .infinity)
                                   .background(Color.red.opacity(0.85))
                                   .foregroundColor(.white)
                                   .cornerRadius(12)
                               }
                           }
                           .padding()
                           .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                           .padding(40)
                           .shadow(radius: 10)
                           .transition(.scale)
                           .zIndex(2)
                       }
                   }
               }
           }

           // MARK: - Logout Function
           func logout() {
               print("logging out...")
               isLoggingOut = true
               APIManager.shared.logout { result in
                   isLoggingOut = false
                   showCustomLogoutPrompt = false
                   switch result {
                   case .success(let message):
                       print("✅ Logout successful: \(message)")
                       withAnimation(.easeInOut(duration: 0.6)){
                           isLoggedIn = false
                       }
                   case .failure(let error):
                       print("❌ Logout failed: \(error.localizedDescription)")
                   }
               }
           }
       }

       // MARK: - Reusable Navigation Link View
       struct HomeNavLink<Destination: View>: View {
           var title: String
           var systemImage: String
           var destination: Destination
           var namespace: Namespace.ID

           var body: some View {
               NavigationLink(destination: destination
                   .navigationTransition(.zoom(sourceID: title, in: namespace))
               ) {
                   HStack {
                       Image(systemName: systemImage)
                           .foregroundColor(.white)
                           .font(.title2)
                           .frame(width: 36)

                       Text(title)
                           .font(.headline)
                           .foregroundColor(.white)

                       Spacer()
                       Image(systemName: "chevron.right")
                           .foregroundColor(.white.opacity(0.7))
                   }
                   .padding()
                   .background(
                       RoundedRectangle(cornerRadius: 16)
                           .fill(Color.green)
                           .shadow(color: .green.opacity(0.4), radius: 4, x: 0, y: 4)
                   )
                   .matchedGeometryEffect(id: title, in: namespace)
               }
           }
       }


#Preview {
    HomePageView()
}
