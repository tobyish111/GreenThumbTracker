//
//  AddWaterSheetView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/23/25.
//

import SwiftUI

struct AddWaterSheet: View {
        let plant: Plant
        var existingRecord: WaterRecord? = nil
        var onSubmit: () -> Void
        @State private var amountText: String = ""
        @State private var selectedDate: Date = Date()
        @State private var errorMessage: String?
        @State private var isSubmitting = false


        var body: some View {
            NavigationStack {
                ZStack {
                    LinearGradient(colors: [.zenGreen.opacity(0.3), .zenBeige.opacity(0.2), .blue.opacity(0.8)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .ignoresSafeArea()

                    VStack(spacing: 24) {
                        Text(existingRecord == nil ? "Add Water Record" : "Edit Water Record")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)

                        TextField("Amount", text: $amountText)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(10)

                        DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(10)

                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }

                        Button(action: submit) {
                            Label("Submit", systemImage: "checkmark.circle.fill")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Spacer()
                    }
                    .padding()
                }
                .onAppear {
                    if let existing = existingRecord {
                        amountText = "\(existing.amount)"
                        selectedDate = ISO8601DateFormatter().date(from: existing.date) ?? Date()
                    }
                }
                .navigationTitle(existingRecord == nil ? "Add Water" : "Edit Water")
                .navigationBarTitleDisplayMode(.inline)
            }
        }

        func submit() {
            guard !isSubmitting else { return }
            isSubmitting = true
            
            guard let amount = Int(amountText) else {
                withAnimation {
                    errorMessage = "Invalid amount."
                    isSubmitting = false
                }
                return
            }

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let dateString = isoFormatter.string(from: selectedDate)

            if let existing = existingRecord {
                APIManager.shared.updateWaterRecord(
                    plantId: plant.id,
                    recordId: existing.id,
                    amount: amount,
                    date: dateString,
                    uomID: existing.uomID // reuse same unit
                ) { result in
                    if case .success = result {
                        onSubmit()
                    } else {
                        errorMessage = "Failed to update record."
                    }
                }
            } else {
                APIManager.shared.createWaterRecord(
                    plantId: plant.id,
                    amount: amount,
                    date: dateString
                ) { result in
                    switch result {
                    case .success:
                        isSubmitting = false
                        onSubmit()
                    case .failure(let error):
                        DispatchQueue.main.async {
                            isSubmitting = false
                            errorMessage = error.localizedDescription
                        }
                    }

                }
            }
        }
    }

#Preview {
    let testPlant: Plant = Plant(id: 1, name: "Test Plant", species: "Test Species", userID: 1)

    AddWaterSheet(plant: testPlant, onSubmit: {})
}
