//
//  SoilMoistureRecordEditView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/22/25.
//

import SwiftUI

struct SoilMoistureRecordEditView: View {
    let plant: Plant
       @Binding var soilMoistureRecords: [SoilMoistureRecord]
       let refreshData: () -> Void
       let deleteSoilMoistureRecord: (Int, Int) -> Void

       @State private var selectedRecordForEdit: SoilMoistureRecord?
       @State private var showConfirmationPrompt = false
       @State private var recordToDelete: SoilMoistureRecord?
       @State private var successMessage: String?

       var body: some View {
           ZStack {
               LinearGradient(colors: [.zenBeige.opacity(0.7), .zenGreen.opacity(0.6), .brown.opacity(0.4)],
                              startPoint: .topLeading, endPoint: .bottomTrailing)
                   .ignoresSafeArea()

               VStack(spacing: 16) {
                   Text("Soil Moisture Records")
                       .font(.title2)
                       .bold()
                       .foregroundColor(.brown)

                   if soilMoistureRecords.isEmpty {
                       Text("No records yet. Add one from the plant page!")
                           .foregroundColor(.gray)
                           .padding()
                   } else {
                       List {
                           ForEach(soilMoistureRecords.sorted(by: { $0.date > $1.date })) { record in
                               Button {
                                   selectedRecordForEdit = record
                               } label: {
                                   HStack {
                                       VStack(alignment: .leading) {
                                           Text(formattedDate(record.date))
                                               .font(.headline)
                                               .foregroundColor(.primary)
                                           Text("Tap to edit")
                                               .font(.caption)
                                               .foregroundColor(.gray)
                                       }

                                       Spacer()
                                       Text("\(record.soil_moisture, specifier: "%.1f")")
                                           .font(.subheadline)
                                           .foregroundColor(.brown)
                                   }
                                   .padding()
                                   .background(Color.white.opacity(0.95))
                                   .cornerRadius(12)
                                   .shadow(radius: 3)
                               }
                               .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                   Button(role: .destructive) {
                                       recordToDelete = record
                                       showConfirmationPrompt = true
                                   } label: {
                                       Label("Delete", systemImage: "trash")
                                   }
                               }
                               .listRowInsets(EdgeInsets())
                               .listRowBackground(Color.clear)
                               .padding(.vertical, 4)
                           }
                       }
                       .listStyle(.plain)
                       .scrollContentBackground(.hidden)
                       .padding(.horizontal)
                   }
               }

               if let message = successMessage {
                   HStack {
                       Image(systemName: "checkmark.seal.fill")
                       Text(message)
                           .fontWeight(.semibold)
                   }
                   .padding()
                   .frame(maxWidth: .infinity)
                   .background(Color.green)
                   .foregroundColor(.white)
                   .cornerRadius(12)
                   .transition(.move(edge: .top).combined(with: .opacity))
               }

               if showConfirmationPrompt, let record = recordToDelete {
                   Color.black.opacity(0.4).ignoresSafeArea()
                   VStack(spacing: 20) {
                       Text("Delete Soil Moisture Record?")
                           .font(.title3)
                           .fontWeight(.bold)
                           .foregroundColor(.red)

                       Text("Are you sure you want to delete the record from \(formattedDate(record.date))?")
                           .multilineTextAlignment(.center)
                           .foregroundColor(.primary)

                       HStack(spacing: 20) {
                           Button("Cancel") {
                               withAnimation {
                                   showConfirmationPrompt = false
                                   recordToDelete = nil
                               }
                           }
                           .padding()
                           .background(Color.gray.opacity(0.2))
                           .cornerRadius(10)

                           Button("Delete") {
                               withAnimation {
                                   deleteSoilMoistureRecord(plant.id, record.id)
                                   refreshData()
                                   showConfirmationPrompt = false
                                   recordToDelete = nil
                               }
                           }
                           .padding()
                           .background(Color.red)
                           .foregroundColor(.white)
                           .cornerRadius(10)
                       }
                   }
                   .padding()
                   .background(Color.white)
                   .cornerRadius(16)
                   .padding(.horizontal, 40)
                   .shadow(radius: 10)
               }
           }
           .navigationTitle("Edit Soil Moisture")
           .navigationBarTitleDisplayMode(.inline)
           .sheet(item: $selectedRecordForEdit) { record in
               AddSoilMoistureSheet(
                   plant: plant,
                   existingRecord: record,
                   onSubmit: {
                       selectedRecordForEdit = nil
                       refreshData()
                       successMessage = "Soil moisture record updated!"
                       DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                           withAnimation {
                               successMessage = nil
                           }
                       }
                   }
               )
           }
       }
   }
/*
#Preview {
    SoilMoistureRecordEditView()
}
*/
