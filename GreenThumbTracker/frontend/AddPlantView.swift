//
//  AddPlantView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/22/25.
//

import SwiftUI

struct AddPlantView: View {
    var existingPlant: Plant? = nil
    var isEditing: Bool { existingPlant != nil }
    
    @Environment(\.dismiss) private var dismiss
    var showSuccessBanner: Binding<Bool>? = nil
    
    @State private var successMessage: String?
    @State private var errorMessage: String?
    @State private var name: String = ""
    @State private var species: String = ""
    private var plantId: Int
    var buttonTitle: String
    
    // init to prefill fields if editing
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
                if(isEditing == true){
                    Text("Edit Plant")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                } else {
                    Text("Add a New Plant")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
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
                
                else{
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
                }//end else
                if !isEditing {
                    GreenButton(title: buttonTitle) {
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
                    }//end green button
                }
                else {
                    GreenButton(title: buttonTitle) {
                        APIManager.shared.updatePlant(id: self.plantId , name: name, species: species) { result in
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
                    }//end green button
                }
                Spacer()
            }
            .padding()
        }
    }
    private func handleResult(_ result: Result<String, Error>) {
        DispatchQueue.main.async {
            withAnimation {
                switch result {
                case .success(let message):
                    successMessage = message
                    errorMessage = nil
                    if !isEditing {
                        name = ""
                        species = ""
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
