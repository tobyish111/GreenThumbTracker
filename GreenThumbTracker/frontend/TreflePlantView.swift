//
//  TreflePlantView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/3/25.
//

import SwiftUI

struct TreflePlantView: View {
    let plant: TreflePlant

       var body: some View {
           ZStack {
               LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2), .green.opacity(0.7)],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
               .ignoresSafeArea()

               ScrollView {
                   VStack(spacing: 20) {
                       if let url = URL(string: plant.image_url ?? "") {
                           AsyncImage(url: url) { phase in
                               switch phase {
                               case .empty: ProgressView()
                               case .success(let image): image.resizable().scaledToFit()
                               default: Image(systemName: "leaf")
                               }
                           }
                           .frame(height: 200)
                           .cornerRadius(12)
                           .shadow(radius: 5)
                       }

                       Text(plant.common_name ?? "Unknown Plant")
                           .font(.largeTitle)
                           .fontWeight(.bold)
                           .foregroundColor(.green)

                       Text(plant.scientific_name)
                           .font(.title2)
                           .foregroundColor(.gray)

                       // Placeholder for extended info once Trefle premium is used
                       Text("More information about this plant can be retrieved with Trefle's extended data endpoints.")
                           .font(.body)
                           .multilineTextAlignment(.center)
                           .padding()
                           .foregroundColor(.black)
                           .background(Color.white.opacity(0.9))
                           .cornerRadius(10)
                           .shadow(radius: 2)
                   }
                   .padding()
               }
           }
           .navigationTitle("Details")
           .navigationBarTitleDisplayMode(.inline)
       }
   }
#Preview {
    let mockPlant = TreflePlant(
           id: 1,
           common_name: "Mock Lavender",
           scientific_name: "Lavandula angustifolia",
           image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Lavandula_angustifolia_%28English_Lavender%29.jpg/800px-Lavandula_angustifolia_%28English_Lavender%29.jpg"
       )
       
    TreflePlantView(plant: mockPlant)
}
