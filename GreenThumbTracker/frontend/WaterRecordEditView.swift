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
    @State private var successMessage: String?
    @State private var selectedRecordForEdit: WaterRecord?
    @State private var showConfirmationDialog = false
    @State private var recordToDelete: WaterRecord?
    
    var body: some View {
        ZStack {
            // Garden-style background
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
                    ScrollView {
                        LazyVStack(spacing: 12) {
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
                                .contextMenu {
                                    Button(role: .destructive) {
                                        recordToDelete = record
                                        showConfirmationDialog = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Edit Water Records")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Are you sure you want to delete this record?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let record = recordToDelete {
                    APIManager.shared.deleteWaterRecord(
                        plantId: plant.id,
                        recordId: record.id
                    ) { result in
                        if case .success = result {
                            refreshData()
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
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
        //confirmation message to user
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

    }//end body
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


    WaterRecordEditView(plant: testPlant, waterRecords: mockRecords, unitMap: unitMap, refreshData: {})
}
