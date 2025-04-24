//
//  AddHumiditySheetView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/22/25.
//

import SwiftUI

struct AddHumiditySheetView: View {
    let plant: Plant
        var existingRecord: HumidityRecord? = nil
        var onSubmit: () -> Void

        @State private var humidityText: String = ""
        @State private var selectedDate: Date = Date()
        @State private var errorMessage: String?
        @State private var isSubmitting = false

        var body: some View {
            NavigationStack {
                ZStack {
                    LinearGradient(colors: [.zenGreen.opacity(0.3), .zenBeige.opacity(0.2), .orange.opacity(0.8)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .ignoresSafeArea()

                    VStack(spacing: 24) {
                        Text(existingRecord == nil ? "Add Humidity Record" : "Edit Humidity Record")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)

                        TextField("Humidity %", text: $humidityText)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(10)

                        DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(10)
                            .tint(Color.orange)

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
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Spacer()
                    }
                    .padding()
                }
                .onAppear {
                    if let existing = existingRecord {
                        humidityText = String(format: "%.1f", existing.humidity)
                        selectedDate = ISO8601DateFormatter().date(from: existing.date) ?? Date()
                    }
                }
                .navigationTitle(existingRecord == nil ? "Add Humidity" : "Edit Humidity")
                .navigationBarTitleDisplayMode(.inline)
            }
        }

        func submit() {
            guard !isSubmitting else { return }
            isSubmitting = true

            guard let humidity = Double(humidityText) else {
                withAnimation {
                    errorMessage = "Invalid humidity value."
                }
                return
            }

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let dateString = isoFormatter.string(from: selectedDate)

            if let existing = existingRecord {
                APIManager.shared.updateHumidityRecord(
                    plantId: plant.id,
                    recordId: existing.id,
                    humidity: humidity,
                    date: dateString,
                    uomID: 1 // fixed UOM for now
                ) { result in
                    DispatchQueue.main.async {
                        if case .success = result {
                            onSubmit()
                        } else {
                            errorMessage = "Failed to update record."
                        }
                    }
                }
            } else {
                APIManager.shared.createHumidityRecord(
                    plantId: plant.id,
                    humidity: humidity,
                    date: dateString,
                    uomID: 1 // fixed UOM for now
                ) { result in
                    DispatchQueue.main.async {
                        if case .success = result {
                            onSubmit()
                        } else {
                            errorMessage = "Failed to add record."
                        }
                    }
                }
            }
        }
    }

/*
#Preview {
    AddHumiditySheetView()
}

*/
