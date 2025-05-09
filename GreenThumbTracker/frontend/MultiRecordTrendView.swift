//
//  MultiRecordTrendView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/23/25.
//

import SwiftUI
import DGCharts
struct MultiRecordTrendView: View {
    let plant: Plant
    let growthRecords: [GrowthRecord]
    let waterRecords: [WaterRecord]
    let humidityRecords: [HumidityRecord]
    let lightRecords: [LightRecord]
    let soilMoistureRecords: [SoilMoistureRecord]
    let temperatureRecords: [TemperatureRecord]
    let unitMap: [Int: UnitOfMeasure]
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedType1: RecordType = .water
    @State private var selectedType2: RecordType = .growth
    @State private var selectedRange: TimeRange = .week
    @State private var saveConfirmationMessage: String?
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "Past Week"
        case month = "Past Month"
        case year = "Past Year"
        var id: String { rawValue }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [.purple.opacity(0.5), .zenBeige.opacity(0.7), .zenGreen.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Compare Two Trends")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                
                Picker("Time Range", selection: $selectedRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                HStack {
                    Picker("Left Axis", selection: $selectedType1) {
                        ForEach(RecordType.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Right Axis", selection: $selectedType2) {
                        ForEach(RecordType.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                if !selectedType1.data(from: self).isEmpty && !selectedType2.data(from: self).isEmpty {
                    DualAxisTrendView(
                        leftEntries: selectedType1.filteredData(from: self, in: selectedRange),
                        rightEntries: selectedType2.filteredData(from: self, in: selectedRange),
                        leftLabel: selectedType1.label,
                        rightLabel: selectedType2.label,
                        leftColor: selectedType1.color,
                        rightColor: selectedType2.color
                    )
                    .frame(height: 350)
                    .padding(.horizontal)
                    .background(Color.clear)
                } else {
                    ProgressView("Records Empty")
                        .padding()
                }
                
                HStack {
                    Button(action: saveChartImage) {
                        Label("Save Chart", systemImage: "square.and.arrow.down")
                    }
                    
                    Button(action: exportDGChartAsPDF) {
                        Label("Download PDF", systemImage: "doc.richtext")
                    }
                    
                    Button(action: printChartImage) {
                        Label("Print Chart", systemImage: "printer")
                    }
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)
                
                if let message = saveConfirmationMessage {
                    Text(message)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green.opacity(0.9))
                        .cornerRadius(12)
                        .transition(.opacity)
                }
                
                Spacer()
            }
            .padding()
            
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
            .padding()
        }
    }
    
    // MARK: - Chart Utilities
    
    func saveChartImage() {
        guard let chart = DualAxisTrendView.chartViewRef else { return }
        let renderer = UIGraphicsImageRenderer(size: chart.bounds.size)
        let image = renderer.image { ctx in
            chart.drawHierarchy(in: chart.bounds, afterScreenUpdates: true)
        }
        
        let saver = PhotoSaveHelper { success in
            saveConfirmationMessage = success ? "Saved to Photos!" : "Failed to save."
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                saveConfirmationMessage = nil
            }
        }
        saver.save(image)
    }
    
    func printChartImage() {
        guard let chart = DualAxisTrendView.chartViewRef else { return }
        let renderer = UIGraphicsImageRenderer(size: chart.bounds.size)
        let image = renderer.image { ctx in
            chart.drawHierarchy(in: chart.bounds, afterScreenUpdates: true)
        }
        
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .photo
        printInfo.jobName = "Multi-Trend Chart"
        printController.printInfo = printInfo
        printController.printingItem = image
        printController.present(animated: true)
    }
    
    func exportDGChartAsPDF() {
        guard let chartView = DualAxisTrendView.chartViewRef else {
            print("❌ No chart view found")
            return
        }

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pdfURL = documentsURL.appendingPathComponent("ChartExport.pdf")

        if chartView.exportAsPDF(to: pdfURL) {
            // Dismiss current modal
            dismiss()

            //Wait for dismissal to finish before presenting picker
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                let picker = UIDocumentPickerViewController(forExporting: [pdfURL])
                picker.modalPresentationStyle = .formSheet

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(picker, animated: true)
                } else {
                    print("⚠️ Still couldn't present picker")
                }
            }
        }
    }
}
/*
#Preview {
    MultiRecordTrendView()
}

*/
