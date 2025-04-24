//
//  AddSoilMoistureSheet.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/22/25.
//

import SwiftUI

struct AddSoilMoistureSheet: View {
    let plant: Plant
        var existingRecord: SoilMoistureRecord? = nil
        var onSubmit: () -> Void

        @State private var moistureText: String = ""
        @State private var selectedDate: Date = Date()
        @State private var errorMessage: String?
        @State private var isSubmitting = false

        var body: some View {
            NavigationStack {
                ZStack {
                    LinearGradient(colors: [.zenGreen.opacity(0.3), .zenBeige.opacity(0.2), .brown.opacity(0.8)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .ignoresSafeArea()

                    VStack(spacing: 24) {
                        Text(existingRecord == nil ? "Add Soil Moisture Record" : "Edit Soil Moisture Record")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.brown)

                        TextField("Soil Moisture", text: $moistureText)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(10)

                        DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(10)
                            .tint(.brown)

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
                                .background(Color.brown)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Spacer()
                    }
                    .padding()
                }
                .onAppear {
                    if let existing = existingRecord {
                        moistureText = String(format: "%.1f", existing.soil_moisture)
                        selectedDate = ISO8601DateFormatter().date(from: existing.date) ?? Date()
                    }
                }
                .navigationTitle(existingRecord == nil ? "Add Soil Moisture" : "Edit Soil Moisture")
                .navigationBarTitleDisplayMode(.inline)
            }
        }

        func submit() {
            guard !isSubmitting else { return }
            isSubmitting = true

            guard let moisture = Double(moistureText) else {
                errorMessage = "Invalid moisture value."
                return
            }

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let dateString = isoFormatter.string(from: selectedDate)

            if let existing = existingRecord {
                APIManager.shared.updateSoilMoistureRecord(
                    plantId: plant.id,
                    recordId: existing.id,
                    moisture: moisture,
                    date: dateString,
                    uomID: 1
                ) { result in
                    if case .success = result {
                        onSubmit()
                    } else {
                        errorMessage = "Failed to update record."
                    }
                }
            } else {
                APIManager.shared.createSoilMoistureRecord(
                    plantId: plant.id,
                    moisture: moisture,
                    date: dateString,
                    uomID: 1
                ) { result in
                    if case .success = result {
                        onSubmit()
                    } else {
                        errorMessage = "Failed to add record."
                    }
                }
            }
        }
    }
/*
#Preview {
    AddSoilMoistureSheet()
}

*/
