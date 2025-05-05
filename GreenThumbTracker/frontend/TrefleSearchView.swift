//
//  TrefleSearchView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/24/25.
//

import SwiftUI
import Kingfisher
struct TrefleSearchView: View {
    @State private var query: String = ""
       @State private var searchResults: [TreflePlant] = []
       @State private var isLoading = false
       @State private var errorMessage: String?

       var body: some View {
           ZStack {
               LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2), .green.opacity(0.7)],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
                   .ignoresSafeArea()

               VStack(spacing: 16) {
                   Image("magnifyingglass")
                       .resizable()
                       .padding()
                   TextField("Search for a plant...", text: $query)
                       .padding()
                       .background(Color.white)
                       .cornerRadius(12)
                       .padding(.horizontal)
                       .onSubmit {
                           performSearch()
                       }

                   if isLoading {
                       ProgressView("Searching...")
                   } else {
                       if let error = errorMessage {
                           Text(error)
                               .foregroundColor(.orange)
                               .padding()
                       }

                       ScrollView {
                           LazyVStack(spacing: 12) {
                               ForEach(searchResults) { plant in
                                   NavigationLink(destination: TreflePlantView(plant: plant)) {
                                       // your existing row code
                                   }
                               }
                           }
                           .padding(.horizontal)
                       }
                   }

                   ScrollView {
                       LazyVStack(spacing: 12) {
                           ForEach(searchResults) { plant in
                               NavigationLink(destination: TreflePlantView(plant: plant)) {
                                   HStack(spacing: 12) {
                                       KFImage(URL(string: plant.image_url ?? ""))
                                           .placeholder {
                                               Image(systemName: "leaf").resizable().scaledToFit()
                                           }
                                           .resizable()
                                           .scaledToFill()
                                           .frame(width: 60, height: 60)
                                           .cornerRadius(8)
                                           .clipped()

                                       VStack(alignment: .leading) {
                                           Text(plant.common_name ?? "Unknown")
                                               .font(.headline)
                                               .foregroundColor(.black)
                                           Text(plant.scientific_name)
                                               .font(.subheadline)
                                               .foregroundColor(.gray)
                                       }

                                       Spacer()
                                   }
                                   .padding()
                                   .background(Color.white.opacity(0.95))
                                   .cornerRadius(12)
                                   .shadow(radius: 3)
                               }
                           }
                       }
                       .padding(.horizontal)
                   }

               }
               .navigationTitle("Search Plants")
               .navigationBarTitleDisplayMode(.inline)
           }
       }

    private func performSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil

        TrefleAPI.shared.searchPlants(query: trimmed) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let results):
                    searchResults = results
                    print("🔍 Found \(results.count) results for '\(trimmed)'")
                case .failure(let error):
                    print("❌ Search failed: \(error.localizedDescription)")
                    // ✅ Always fallback on failure
                    searchResults = fallbackPlants.filter {
                        $0.common_name?.localizedCaseInsensitiveContains(trimmed) == true ||
                        $0.scientific_name.localizedCaseInsensitiveContains(trimmed)
                    }

                    if searchResults.isEmpty {
                        errorMessage = "No matches found locally for '\(trimmed)'"
                    } else {
                        errorMessage = "🌿 Plant search is offline — showing local matches"
                    }
                }
            }
        }
    }


   }


#Preview {
    TrefleSearchView()
}
