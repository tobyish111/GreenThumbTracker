//
//  TemperatureRecordEditView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/22/25.
//

import SwiftUI

struct TemperatureRecordEditView: View {
    let plant: Plant
       @Binding var temperatureRecords: [TemperatureRecord]
       var refreshData: () -> Void
       var deleteTemperatureRecord: (Int, Int) -> Void
       
       @Environment(\.dismiss) private var dismiss

       var body: some View {
           NavigationStack {
               ZStack {
                   LinearGradient(colors: [.zenGreen.opacity(0.2), .zenBeige.opacity(0.2), .red.opacity(0.4)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
                       .ignoresSafeArea()
                   
                   List {
                       ForEach(temperatureRecords.sorted(by: { $0.date > $1.date })) { record in
                           NavigationLink {
                               AddTemperatureSheet(
                                   plant: plant,
                                   existingRecord: record,
                                   onSubmit: {
                                       refreshData()
                                       dismiss()
                                   }
                               )
                           } label: {
                               HStack {
                                   Text(formattedDate(record.date))
                                   Spacer()
                                   Text("\(record.temperature, specifier: "%.1f")°")
                                       .foregroundColor(.black)
                               }
                           }
                           .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                               Button(role: .destructive) {
                                   deleteTemperatureRecord(plant.id, record.id)
                               } label: {
                                   Label("Delete", systemImage: "trash")
                               }
                           }
                       }
                   }
                   .listStyle(.insetGrouped)
               }
               .navigationTitle("Edit Temperature")
               .navigationBarTitleDisplayMode(.inline)
               .toolbar {
                   ToolbarItem(placement: .cancellationAction) {
                       Button("Close") {
                           dismiss()
                       }
                   }
               }
           }
       }

       private func formattedDate(_ isoString: String) -> String {
           let formatter = ISO8601DateFormatter()
           formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
           if let date = formatter.date(from: isoString) {
               let displayFormatter = DateFormatter()
               displayFormatter.dateStyle = .medium
               displayFormatter.timeStyle = .short
               return displayFormatter.string(from: date)
           }
           return "Invalid Date"
       }
   }
/*
#Preview {
    TemperatureRecordEditView()
}
*/
