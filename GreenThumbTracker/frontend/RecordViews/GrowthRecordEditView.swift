//
//  GrowthRecordEditView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/10/25.
//

import SwiftUI

struct GrowthRecordEditView: View {
    let plant: Plant
       @Binding var growthRecords: [GrowthRecord]
       let unitMap: [Int: UnitOfMeasure]
       let refreshData: () -> Void
       let deleteGrowthRecord: (Int, Int) -> Void

       @State private var successMessage: String?
       @State private var selectedRecordForEdit: GrowthRecord?
       @State private var showConfirmationPrompt = false
       @State private var recordToDelete: GrowthRecord?

       var body: some View {
           ZStack {
               LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2), .green.opacity(0.7)],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
                   .ignoresSafeArea()

               VStack(spacing: 16) {
                   Text("Growth Records")
                       .font(.title2)
                       .bold()
                       .foregroundColor(.green)
                       .padding(.top)

                   if growthRecords.isEmpty {
                       Text("No growth records yet. Add one from the plant page!")
                           .foregroundColor(.gray)
                           .padding()
                   } else {
                       List {
                           ForEach(growthRecords.sorted(by: { $0.date > $1.date })) { record in
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

                                       Text("\(record.height, specifier: "%.2f") \(unitMap[record.uom.id]?.symbol ?? "")")
                                           .font(.subheadline)
                                           .foregroundColor(.green)
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
                       Text("Delete Growth Record?")
                           .font(.title3)
                           .fontWeight(.bold)
                           .foregroundColor(.red)

                       Text("Are you sure you want to delete the record from \(formattedDate(record.date))?")
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
                                   deleteGrowthRecord(plant.id, record.id)
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
           .navigationTitle("Edit Growth Records")
           .navigationBarTitleDisplayMode(.inline)
           .sheet(item: $selectedRecordForEdit) { record in
               AddGrowthSheetView(
                   plant: plant,
                   existingRecord: record
               ) {
                   selectedRecordForEdit = nil
                   refreshData()
                   successMessage = "Growth record updated!"
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
    let testPlant = Plant(id: 1, name: "Test Plant", species: "Aloe Vera", userID: 1)

       let nestedPlant = GrowthRecord.NestedPlant(id: 1, name: "Test Plant", species: "Aloe Vera")
       let nestedUOM = GrowthRecord.NestedUOM(id: 1, name: "Centimeters", symbol: "cm")

       let mockRecords: Binding<[GrowthRecord]> = .constant([
           GrowthRecord(id: 1, height: 12.5, date: "2025-03-25T10:00:00Z", plant: nestedPlant, uom: nestedUOM),
           GrowthRecord(id: 2, height: 15.3, date: "2025-03-30T14:30:00Z", plant: nestedPlant, uom: nestedUOM),
           GrowthRecord(id: 3, height: 17.8, date: "2025-04-06T09:15:00Z", plant: nestedPlant, uom: nestedUOM)
       ])

       let unitMap: [Int: UnitOfMeasure] = [
           1: UnitOfMeasure(id: 1, name: "Centimeters", symbol: "cm")
       ]
    GrowthRecordEditView(plant: testPlant, growthRecords: mockRecords, unitMap: unitMap, refreshData: {}, deleteGrowthRecord: {_, _ in})
}
