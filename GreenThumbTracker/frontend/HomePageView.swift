//
//  HomePageView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/20/25.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
          NavigationStack {
              ZStack {
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
                          HomeNavLink(title: "Add a Plant", systemImage: "plus.circle", destination: AddPlantView())
                          HomeNavLink(title: "View My Plants", systemImage: "leaf", destination: ViewPlantsView())
                          //HomeNavLink(title: "Delete a Plant", systemImage: "trash.fill", destination: DeletePlantView())
                      }

                      Spacer()
                  }
                  .padding(.horizontal, 24)
              }
          }
      }
  }

  // MARK: - Reusable Navigation Button
  struct HomeNavLink<Destination: View>: View {
      var title: String
      var systemImage: String
      var destination: Destination

      var body: some View {
          NavigationLink(destination: destination) {
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
          }
      }
  }


#Preview {
    HomePageView()
}
