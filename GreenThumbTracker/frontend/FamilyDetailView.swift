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
        @State private var wikiSummary: WikipediaSummary?

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

                            // Wikipedia Summary
                            if let summary = wikiSummary {
                                VStack(alignment: .leading, spacing: 12) {
                                    if let imageUrl = summary.thumbnail?.source,
                                       let url = URL(string: imageUrl) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .cornerRadius(10)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(maxHeight: 200)
                                    }

                                    Text(summary.extract)
                                        .font(.body)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
                                .shadow(radius: 4)
                            }

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
                // Trefle Family Details
                if let cached = TrefleFamilyDetailsCache.shared.familyDetailsMap[slug] {
                    self.details = cached
                } else {
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

                // Wikipedia Summary
                let capitalizedSlug = slug.prefix(1).uppercased() + slug.dropFirst()
                if let cached = WikipediaSummaryCache.shared.get(for: capitalizedSlug) {
                    self.wikiSummary = cached
                } else {
                    fetchWikipediaSummary(for: capitalizedSlug) { result in
                        DispatchQueue.main.async {
                            if let summary = result {
                                WikipediaSummaryCache.shared.set(summary, for: capitalizedSlug)
                                self.wikiSummary = summary
                            }
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
