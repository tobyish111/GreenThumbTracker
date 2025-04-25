//
//  FamilyDetailView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/24/25.
//

import SwiftUI

struct FamilyDetailView: View {
    let slug: String
       @State private var details: FamilyDetails?
       @State private var error: String?

       var body: some View {
           ZStack {
               LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2)],
                              startPoint: .topLeading, endPoint: .bottomTrailing)
                   .ignoresSafeArea()

               if let details = details {
                   ScrollView {
                       VStack(spacing: 20) {
                           // Basic Info
                           VStack(spacing: 12) {
                               Text(details.common_name ?? details.name)
                                   .font(.largeTitle.bold())
                                   .foregroundColor(.green)
                               Text("Scientific name: \(details.name)")
                                   .font(.title2)

                               if let author = details.author {
                                   Text("👤 Author: \(author)")
                               }
                               if let year = details.year {
                                   Text("📅 Year: \(year)")
                               }
                               if let bibliography = details.bibliography {
                                   Text("📚 Bibliography: \(bibliography)")
                                       .multilineTextAlignment(.center)
                                       .padding(.horizontal)
                               }
                           }
                           .padding()
                           .background(Color.white.opacity(0.9))
                           .cornerRadius(12)
                           .shadow(radius: 4)

                           // Taxonomy Hierarchy
                           if let hierarchy = details.division_order {
                               VStack(alignment: .leading, spacing: 8) {
                                   Label("Taxonomy Hierarchy", systemImage: "tree")
                                       .font(.headline)
                                       .foregroundColor(.green)

                                   Text("📘 Order: \(hierarchy.name)")
                                       .font(.subheadline)

                                   if let divisionClass = hierarchy.division_class {
                                       Text("📗 Class: \(divisionClass.name)")
                                           .font(.subheadline)

                                       if let division = divisionClass.division {
                                           Text("📙 Division: \(division.name)")
                                               .font(.subheadline)

                                           if let subkingdom = division.subkingdom {
                                               Text("📕 Subkingdom: \(subkingdom.name)")
                                                   .font(.subheadline)

                                               if let kingdom = subkingdom.kingdom {
                                                   Text("👑 Kingdom: \(kingdom.name)")
                                                       .font(.subheadline)
                                               }
                                           }
                                       }
                                   }
                               }
                               .padding()
                               .background(Color.white.opacity(0.9))
                               .cornerRadius(12)
                               .shadow(radius: 4)
                           }

                           Spacer()
                       }
                       .padding()
                   }
               } else if let error = error {
                   Text("❌ \(error)")
                       .foregroundColor(.red)
                       .padding()
               } else {
                   ProgressView("Loading family details...")
               }
           }
           .onAppear {
               if let cached = TrefleFamilyDetailsCache.shared.familyDetailsMap[slug] {
                   self.details = cached
                   return
               }

               TrefleAPI.shared.getFamilyDetails(slug: slug) { result in
                   DispatchQueue.main.async {
                       switch result {
                       case .success(let data):
                           TrefleFamilyDetailsCache.shared.familyDetailsMap[slug] = data
                           self.details = data
                       case .failure(let err):
                           self.error = err.localizedDescription
                       }
                   }
               }
           }
           .navigationTitle("Family Info")
           .navigationBarTitleDisplayMode(.inline)
       }
   }
/*
#Preview {
    FamilyDetailView()
}
*/
