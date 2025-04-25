//
//  EncyclopediaMenuView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/24/25.
//

import SwiftUI

struct EncyclopediaMenuView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2), .green.opacity(0.7)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    menuItem(title: "Browse Plants", systemImage: "leaf.fill") {
                        EncyclopediaView() // push to main view
                    }
                    menuItem(title: "Search by Region", systemImage: "globe.americas") {
                        // TODO: Replace with region search view
                        TrefleRegionListView()
                    }
                    menuItem(title: "Plant Families", systemImage: "tree") {
                        FamilySearchView()
                    }
                    menuItem(title: "Search", systemImage: "magnifyingglass") {
                        TrefleSearchView()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Trefle Menu")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func menuItem<V: View>(title: String, systemImage: String, destination: @escaping () -> V) -> some View {
        NavigationLink(destination: destination()) {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(Color.green)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
        }
    }
    
    
    struct PlaceholderView: View {
        let title: String
        var body: some View {
            Text("🚧 \(title) coming soon!")
                .font(.title)
                .padding()
                .navigationTitle(title)
        }
    }
}

#Preview {
    EncyclopediaMenuView()
}
