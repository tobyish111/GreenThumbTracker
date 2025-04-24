//
//  AddTemperatureSheet.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/22/25.
//

import SwiftUI

struct AddTemperatureSheet: View {
    let plant: Plant
        var existingRecord: TemperatureRecord? = nil
        var onSubmit: () -> Void

        @State private var temperatureText: String = ""
        @State private var selectedDate: Date = Date()
        @State private var errorMessage: String?
        @State private var isSubmitting = false

        var body: some View {
            NavigationStack {
                ZStack {
                    LinearGradient(colors: [.zenGreen.opacity(0.3), .zenBeige.opacity(0.2), .red.opacity(0.8)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .ignoresSafeArea()

                    VStack(spacing: 24) {
                        Text(existingRecord == nil ? "Add Temperature Record" : "Edit Temperature Record")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)

                        TextField("Temperature", text: $temperatureText)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(10)

                        DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(10)
                            .tint(.red)

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
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Spacer()
                    }
                    .padding()
                }
                .onAppear {
                    if let existing = existingRecord {
                        temperatureText = String(format: "%.1f", existing.temperature)
                        selectedDate = ISO8601DateFormatter().date(from: existing.date) ?? Date()
                    }
                }
                .navigationTitle(existingRecord == nil ? "Add Temperature" : "Edit Temperature")
                .navigationBarTitleDisplayMode(.inline)
            }
        }

        func submit() {
            guard !isSubmitting else { return }
            isSubmitting = true

            guard let temperature = Double(temperatureText) else {
                errorMessage = "Invalid temperature value."
                return
            }

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let dateString = formatter.string(from: selectedDate)

            if let existing = existingRecord {
                APIManager.shared.updateTemperatureRecord(
                    plantId: plant.id,
                    recordId: existing.id,
                    temperature: temperature,
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
                APIManager.shared.createTemperatureRecord(
                    plantId: plant.id,
                    temperature: temperature,
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
    AddTemperatureSheet()
}
*/
