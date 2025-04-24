//
//  WaterRecordEditView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/23/25.
//

import SwiftUI
import Foundation

struct WaterRecordEditView: View {
    let plant: Plant
       @Binding var waterRecords: [WaterRecord]
       let unitMap: [Int: UnitOfMeasure]
       let refreshData: () -> Void
       let deleteWaterRecord: (Int, Int) -> Void

       @State private var successMessage: String?
       @State private var selectedRecordForEdit: WaterRecord?
       @State private var showConfirmationPrompt = false
       @State private var recordToDelete: WaterRecord?

       var body: some View {
           ZStack {
               LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2), .blue.opacity(0.7)],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
                   .ignoresSafeArea()

               VStack(spacing: 16) {
                   Text("Watering Records")
                       .font(.title2)
                       .bold()
                       .foregroundColor(.blue)
                       .padding(.top)

                   if waterRecords.isEmpty {
                       Text("No records yet. Add one from the plant page!")
                           .foregroundColor(.gray)
                           .padding()
                   } else {
                       List {
                           ForEach(waterRecords.sorted(by: { $0.date > $1.date })) { record in
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

                                       Text("\(record.amount) \(unitMap[record.uomID]?.symbol ?? "")")
                                           .font(.subheadline)
                                           .foregroundColor(.blue)
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
                       Text("Delete Water Record?")
                           .font(.title3)
                           .fontWeight(.bold)
                           .foregroundColor(.red)

                       Text("Are you sure you want to delete the water record from \(formattedDate(record.date))?")
                           .multilineTextAlignment(.center)
                           .foregroundColor(.primary)
                           .padding(.horizontal)

                       HStack(spacing: 20) {
                           Button("Cancel") {
                               withAnimation {
                                   showConfirmationPrompt = false
                                   recordToDelete = nil
                               }
                           }
                           .padding()
                           .frame(maxWidth: .infinity)
                           .background(Color.gray.opacity(0.2))
                           .cornerRadius(10)

                           Button("Delete") {
                               withAnimation {
                                   deleteWaterRecord(plant.id, record.id)
                                   refreshData()
                                   showConfirmationPrompt = false
                                   recordToDelete = nil
                               }
                           }
                           .padding()
                           .frame(maxWidth: .infinity)
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
                   .transition(.scale)
               }
           }
           .navigationTitle("Edit Water Records")
           .navigationBarTitleDisplayMode(.inline)
           .sheet(item: $selectedRecordForEdit) { record in
               AddWaterSheet(
                   plant: plant,
                   existingRecord: record
               ) {
                   selectedRecordForEdit = nil
                   refreshData()
                   successMessage = "Water record updated!"
                   DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                       withAnimation {
                           successMessage = nil
                       }
                   }
               }
           }
       }
   }


#Preview {
    let testPlant = Plant(id: 1, name: "Test Plant", species: "Test Species", userID: 1)

        let nestedPlant = WaterRecord.NestedPlant(id: 1, name: "Test Plant", species: "Test Species")
        let nestedUOM = WaterRecord.NestedUOM(id: 1, name: "Milliliters", symbol: "mL")

        let mockRecords: Binding<[WaterRecord]> = .constant([
            WaterRecord(id: 1, amount: 250, date: "2025-03-23T12:00:00Z", plant: nestedPlant, uom: nestedUOM),
            WaterRecord(id: 2, amount: 100, date: "2025-03-22T08:30:00Z", plant: nestedPlant, uom: nestedUOM)
        ])

        let unitMap: [Int: UnitOfMeasure] = [
            1: UnitOfMeasure(id: 1, name: "Milliliters", symbol: "mL")
        ]


    WaterRecordEditView(plant: testPlant, waterRecords: mockRecords, unitMap: unitMap, refreshData: {}, deleteWaterRecord: {_,_ in })
}
