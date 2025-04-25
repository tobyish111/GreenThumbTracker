//
//  FamilySearchView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/24/25.
//

import SwiftUI
import Kingfisher
struct FamilySearchView: View {
    @State private var query = ""
       @State private var allFamilies: [TrefleFamily] = []
       @State private var filteredFamilies: [TrefleFamily] = []
    @State private var isLoading = true
    @State private var currentPage = 0
    @State private var totalPages = 1
    @State private var familiesLoaded = 0
    @State private var totalFamilies = 1


       var body: some View {
           ZStack {
               LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2), .green.opacity(0.7)],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
                   .ignoresSafeArea()

               VStack {
                   TextField("Search families...", text: $query)
                       .padding(12)
                       .background(Color.white)
                       .cornerRadius(10)
                       .padding(.horizontal)
                       .onChange(of: query) {
                           filterFamilies()
                       }
                   if isLoading {
                       VStack(spacing: 16) {
                          
                            ProgressView(value: Double(familiesLoaded), total: Double(max(totalFamilies, 1)))
                                           .progressViewStyle(LinearProgressViewStyle())
                                           .tint(.green)
                            Text("Families Loaded: \(familiesLoaded)/\(totalFamilies)")
                                .foregroundColor(.black)
                                .font(.subheadline)
                                .bold()
                                   }
                       
                       .padding()
                   }


                   ScrollView {
                       LazyVStack(spacing: 16) {
                           ForEach(filteredFamilies) { family in
                               NavigationLink(destination: FamilyDetailView(slug: family.slug)) {
                                   FamilyCardView(family: family)
                               }

                           }
                       }
                       .padding()
                   }
               }
               .navigationTitle("Search Families")
           }
           .onAppear {
               if !TrefleFamilyCache.shared.isLoaded {
                      print("🌱 Fetching all families from Trefle...")
                      TrefleAPI.shared.preloadAllFamilies(
                          delay: 0.4,
                          progress: { loadedCount, totalFamilies, currentPage, totalPages in
                              DispatchQueue.main.async {
                                  self.familiesLoaded = loadedCount
                                  self.totalFamilies = totalFamilies
                                  self.currentPage = currentPage
                                  self.totalPages = totalPages
                              }
                          }
                          ,
                          completion: { result in
                              DispatchQueue.main.async {
                                  switch result {
                                  case .success(let families):
                                      TrefleFamilyCache.shared.allFamilies = families
                                      TrefleFamilyCache.shared.isLoaded = true
                                      self.totalFamilies = families.count
                                      self.allFamilies = families
                                      self.filteredFamilies = families
                                      self.isLoading = false
                                      print("✅ Loaded \(families.count) families.")
                                  case .failure(let error):
                                      print("❌ Failed to load families: \(error)")
                                      self.isLoading = false
                                  }
                              }
                          }
                      )
                  } else {
                      print("📦 Using cached families")
                      allFamilies = TrefleFamilyCache.shared.allFamilies
                      filteredFamilies = allFamilies
                      isLoading = false
                  }
           }


       }

       private func filterFamilies() {
           let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
           if trimmed.isEmpty {
               filteredFamilies = allFamilies
           } else {
               filteredFamilies = allFamilies.filter {
                   $0.name.localizedCaseInsensitiveContains(trimmed)
               }
           }
       }
   }
struct FamilyCardView: View {
    let family: TrefleFamily

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(family.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
            }

            Spacer()

            if let imgUrl = family.imageURL, let url = URL(string: imgUrl) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.green.opacity(0.9))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    FamilySearchView()
}
