//
//  AddGrowthSheetView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/10/25.
//

import SwiftUI

struct AddGrowthSheetView: View {
    let plant: Plant
       var existingRecord: GrowthRecord? = nil
       var onSubmit: () -> Void
       @State private var heightText: String = ""
       @State private var selectedDate: Date = Date()
       @State private var errorMessage: String?
       @State private var isSubmitting = false

       var body: some View {
           NavigationStack {
               ZStack {
                   LinearGradient(colors: [.zenGreen.opacity(0.3), .zenBeige.opacity(0.2), .green.opacity(0.8)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
                       .ignoresSafeArea()

                   VStack(spacing: 24) {
                       Text(existingRecord == nil ? "Add Growth Record" : "Edit Growth Record")
                           .font(.title2)
                           .fontWeight(.bold)
                           .foregroundColor(.green)

                       TextField("Height", text: $heightText)
                           .keyboardType(.decimalPad)
                           .padding()
                           .background(Color.white.opacity(0.95))
                           .cornerRadius(10)

                       DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                           .datePickerStyle(.graphical)
                           .padding()
                           .background(Color.white.opacity(0.95))
                           .cornerRadius(10)
                           .tint(.green)

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
                               .background(Color.green)
                               .foregroundColor(.white)
                               .cornerRadius(10)
                       }

                       Spacer()
                   }
                   .padding()
               }
               .onAppear {
                   if let existing = existingRecord {
                       heightText = "\(existing.height)"
                       selectedDate = ISO8601DateFormatter().date(from: existing.date) ?? Date()
                   }
               }
               .navigationTitle(existingRecord == nil ? "Add Growth" : "Edit Growth")
               .navigationBarTitleDisplayMode(.inline)
           }
       }

       func submit() {
           guard !isSubmitting else { return }
           isSubmitting = true

           guard let height = Double(heightText) else {
               errorMessage = "Invalid height."
               return
           }

           let isoFormatter = ISO8601DateFormatter()
           isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
           let dateString = isoFormatter.string(from: selectedDate)

           if let existing = existingRecord {
               APIManager.shared.updateGrowthRecord(
                   plantId: plant.id,
                   recordId: existing.id,
                   height: height,
                   date: dateString,
                   uomID: existing.uom.id
               ) { result in
                   if case .success = result {
                       onSubmit()
                   } else {
                       errorMessage = "Failed to update record."
                   }
               }
           } else {
               APIManager.shared.createGrowthRecord(
                   plantId: plant.id,
                   height: height,
                   date: dateString,
                   uomID: 1 // Default UOM or use a selector
               ) { result in
                   if case .success = result {
                       onSubmit()
                   } else {
                       errorMessage = "Failed to create record."
                   }
               }
           }
       }
   }

#Preview {
    let testPlant: Plant = Plant(id: 1, name: "Test Plant", species: "Test Species", userID: 1)
    AddGrowthSheetView(plant: testPlant, onSubmit: {})
}
