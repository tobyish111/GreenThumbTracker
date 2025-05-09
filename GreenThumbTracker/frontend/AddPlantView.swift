//
//  AddPlantView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/22/25.
//

import SwiftUI
import SwiftData

struct AddPlantView: View {
    var existingPlant: Plant? = nil
        var isEditing: Bool { existingPlant != nil }

        @Environment(\.dismiss) private var dismiss
        var showSuccessBanner: Binding<Bool>? = nil

        @State private var successMessage: String?
        @State private var errorMessage: String?
        @State private var name: String = ""
        @State private var species: String = ""
        @State private var submissionAttempted = false
        private var plantId: Int
        var buttonTitle: String

        init(existingPlant: Plant? = nil, showSuccessBanner: Binding<Bool>? = nil) {
            self.existingPlant = existingPlant
            self._name = State(initialValue: existingPlant?.name ?? "")
            self._species = State(initialValue: existingPlant?.species ?? "")
            self.plantId = existingPlant?.id ?? 0
            self.buttonTitle = existingPlant != nil ? "Update Plant" : "Add Plant"
        }

        var body: some View {
            ZStack {
                LinearGradient(
                    colors: [.zenGreen.opacity(0.8), .zenBeige.opacity(0.6), .green.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text(isEditing ? "Edit Plant" : "Add a New Plant")
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

                    if submissionAttempted {
                        if let success = successMessage {
                            bannerView(icon: "checkmark.seal.fill", message: success, color: .green)
                        } else if let error = errorMessage {
                            bannerView(icon: "xmark.octagon.fill", message: error, color: .red)
                        }
                    }

                    GreenButton(title: buttonTitle) {
                        submissionAttempted = true
                        if isEditing {
                            APIManager.shared.updatePlant(id: self.plantId, name: name, species: species, completion: handleResult)
                        } else {
                            APIManager.shared.addPlant(name: name, species: species, completion: handleResult)
                        }
                    }

                    Spacer()
                }
                .padding()
            }
        }

        private func bannerView(icon: String, message: String, color: Color) -> some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(message)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(12)
            .shadow(radius: 4)
            .transition(.opacity)
        }

        private func handleResult(_ result: Result<String, Error>) {
            DispatchQueue.main.async {
                withAnimation {
                    switch result {
                    case .success(let message):
                        if message.lowercased().contains("error") || message.lowercased().contains("missing") {
                            errorMessage = message
                            successMessage = nil
                        } else {
                            successMessage = message
                            errorMessage = nil
                            if !isEditing {
                                name = ""
                                species = ""
                            }
                        }
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        successMessage = nil
                    }
                }
            }
        }
    }
#Preview {
    AddPlantView()
}
