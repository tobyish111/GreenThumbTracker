//
//  TrefleSearchView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/24/25.
//

import SwiftUI

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
                   } else if let error = errorMessage {
                       Text(error)
                           .foregroundColor(.red)
                           .padding()
                   } else {
                       ScrollView {
                           LazyVStack(spacing: 12) {
                               ForEach(searchResults) { plant in
                                   NavigationLink(destination: TreflePlantView(plant: plant)) {
                                       HStack(spacing: 12) {
                                           AsyncImage(url: URL(string: plant.image_url ?? "")) { phase in
                                               switch phase {
                                               case .empty:
                                                   ProgressView()
                                               case .success(let image):
                                                   image.resizable().scaledToFill()
                                               default:
                                                   Image(systemName: "leaf")
                                               }
                                           }
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
                       errorMessage = "Failed to search: \(error.localizedDescription)"
                   }
               }
           }
       }
   }


#Preview {
    TrefleSearchView()
}
