//
//  AddPlantView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/22/25.
//

import SwiftUI

struct AddPlantView: View {
    @State private var successMessage: String?
    @State private var errorMessage: String?
    @State private var name: String = ""
    @State private var species: String = ""

      var body: some View {
          ZStack {
              LinearGradient(
                  colors: [.zenGreen.opacity(0.8), .zenBeige.opacity(0.6), .green.opacity(0.7)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
              )
              .ignoresSafeArea()

              VStack(spacing: 20) {
                  Text("Add a New Plant")
                      .font(.title)
                      .fontWeight(.bold)
                      .foregroundColor(.green)

                  TextField("Plant Name", text: $name)
                      .padding()
                      .background(Color.white.opacity(0.9))
                      .cornerRadius(10)

                  TextField("Species", text: $species)
                      .padding()
                      .background(Color.white.opacity(0.9))
                      .cornerRadius(10)
                  //display status for visual confirmation
                  if let success = successMessage {
                      HStack {
                          Image(systemName: "checkmark.seal.fill")
                              .foregroundColor(.white)
                          Text(success)
                              .foregroundStyle(.white)
                              .fontWeight(.semibold)
                              .multilineTextAlignment(.center)
                      }
                      .padding()
                      .frame(maxWidth: .infinity)
                      .background(Color.green)
                      .cornerRadius(12)
                      .shadow(radius: 4)
                      .transition(.opacity)
                  }

                  else {
                      HStack {
                          Image(systemName: "xmark.octagon.fill")
                              .foregroundColor(.white)
                          Text("There was an error adding this plant!")
                              .fontWeight(.semibold)
                              .multilineTextAlignment(.center)
                              .foregroundColor(.white)
                      }
                      .padding()
                      .frame(maxWidth: .infinity)
                      .background(Color.red)
                      .cornerRadius(12)
                      .shadow(radius: 4)
                      .transition(.opacity)
                  }



                  GreenButton(title: "Submit") {
                      APIManager.shared.addPlant(name: name, species: species) { result in
                          DispatchQueue.main.async {
                              withAnimation{
                                  switch result {
                                  case .success(let message):
                                      successMessage = message
                                      errorMessage = nil
                                      name = ""
                                      species = ""
                                  case .failure(let error):
                                      errorMessage = error.localizedDescription
                                      successMessage = nil
                                  }
                              }
                          }
                      }
                  }

                  Text("⚠️ Add plant feature is coming soon!")
                      .font(.caption)
                      .foregroundColor(.gray)

                  Spacer()
              }
              .padding()
          }
      }
  }
#Preview {
    AddPlantView()
}
