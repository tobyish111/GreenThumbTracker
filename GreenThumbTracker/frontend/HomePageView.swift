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
    @State private var showLogoutConfirmation: Bool = false
    var body: some View {
          NavigationStack {
              ZStack(alignment: .topTrailing) {
                  VStack {
                      HStack {
                          Spacer()
                          Button(action: {
                              showLogoutConfirmation = true
                              print("Logged out")
                          }) {
                              Image(systemName: "rectangle.portrait.and.arrow.right")
                                  .padding()
                                  .background(Circle().fill(Color.white))
                                  .foregroundColor(.green)
                                  .shadow(radius: 4)
                          }
                          .padding([.top, .trailing], 16)
                         
                      }
                      Spacer()
                  }

                  // Zen-inspired gradient background
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
                      // 🌱 Header
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

                      // 🌿 Main Menu Buttons
                      VStack(spacing: 20) {
                          HomeNavLink(title: "Add a Plant", systemImage: "plus.circle", destination: AddPlantView(), namespace: navNamespace)
                          HomeNavLink(title: "View My Plants", systemImage: "leaf", destination: ViewPlantsView(), namespace: navNamespace)
                          //HomeNavLink(title: "Delete a Plant", systemImage: "trash.fill", destination: DeletePlantView())
                      }

                      Spacer()
                  }
                  .padding(.horizontal, 24)
              }.alert("Are you sure you want to log out?", isPresented: $showLogoutConfirmation) {
                  Button("Log Out", role: .destructive) {
                      isLoggedIn = false
                  }
                  Button("Cancel", role: .cancel) {}
              }
          }
      }
  }

  //reusable nav button
  struct HomeNavLink<Destination: View>: View {
      var title: String
      var systemImage: String
      var destination: Destination
      var namespace: Namespace.ID //for zoom transitions

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
                  .matchedGeometryEffect(id: title, in: namespace) //smooth animation
          }
      }
  }


#Preview {
    HomePageView()
}
