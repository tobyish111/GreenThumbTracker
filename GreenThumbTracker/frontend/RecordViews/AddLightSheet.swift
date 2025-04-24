//
//  AddLightSheet.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/22/25.
//

import SwiftUI

struct AddLightSheet: View {
    let plant: Plant
        var existingRecord: LightRecord? = nil
        var onSubmit: () -> Void

        @State private var lightText: String = ""
        @State private var selectedDate: Date = Date()
        @State private var errorMessage: String?
        @State private var isSubmitting = false

        var body: some View {
            NavigationStack {
                ZStack {
                    LinearGradient(colors: [.zenGreen.opacity(0.3), .zenBeige.opacity(0.2), .yellow.opacity(0.8)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .ignoresSafeArea()

                    VStack(spacing: 24) {
                        Text(existingRecord == nil ? "Add Light Record" : "Edit Light Record")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)

                        TextField("Light Exposure", text: $lightText)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(10)

                        DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(10)
                            .tint(.yellow)

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
                                .background(Color.yellow)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Spacer()
                    }
                    .padding()
                }
                .onAppear {
                    if let existing = existingRecord {
                        lightText = String(format: "%.1f", existing.light)
                        selectedDate = ISO8601DateFormatter().date(from: existing.date) ?? Date()
                    }
                }
                .navigationTitle(existingRecord == nil ? "Add Light" : "Edit Light")
                .navigationBarTitleDisplayMode(.inline)
            }
        }

        func submit() {
            guard !isSubmitting else { return }
            isSubmitting = true

            guard let light = Double(lightText) else {
                errorMessage = "Invalid light value."
                return
            }

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let dateString = isoFormatter.string(from: selectedDate)

            if let existing = existingRecord {
                APIManager.shared.updateLightRecord(
                    plantId: plant.id,
                    recordId: existing.id,
                    light: light,
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
                APIManager.shared.createLightRecord(
                    plantId: plant.id,
                    light: light,
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
    AddLightSheet()
}

*/
