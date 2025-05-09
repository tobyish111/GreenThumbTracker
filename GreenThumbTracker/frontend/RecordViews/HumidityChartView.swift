//
//  HumidityChartView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/22/25.
//

import SwiftUI
import Charts
struct HumidityChartView: View {
    let humidityRecords: [HumidityRecord]
        @State private var selectedRange: TimeRange = .week
        @State private var saveConfirmationMessage: String?
        @Environment(\.dismiss) private var dismiss
    
    private var dateLabelFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd"
        return formatter
    }


        enum TimeRange: String, CaseIterable, Identifiable {
            case week = "Past Week"
            case month = "Past Month"
            case year = "Past Year"
            var id: String { self.rawValue }
        }

        private var isoFormatter: ISO8601DateFormatter {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter
        }

        private var filteredRecords: [HumidityRecord] {
            let now = Date()
            let calendar = Calendar.current
            return humidityRecords.filter {
                guard let date = isoFormatter.date(from: $0.date) else { return false }
                switch selectedRange {
                case .week: return date > calendar.date(byAdding: .day, value: -7, to: now)!
                case .month: return date > calendar.date(byAdding: .month, value: -1, to: now)!
                case .year: return date > calendar.date(byAdding: .year, value: -1, to: now)!
                }
            }
        }

        @ViewBuilder
        private var ChartContainerView: some View {
            VStack(spacing: 8) {
                Text("Humidity Over \(selectedRange.rawValue)")
                    .font(.headline)
                    .foregroundColor(.orange)

                Chart {
                    ForEach(filteredRecords.sorted(by: { $0.date < $1.date })) { record in
                        if let date = isoFormatter.date(from: record.date) {
                            LineMark(
                                x: .value("Date", date),
                                y: .value("Humidity", record.humidity)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(.orange)
                            .symbol(Circle())
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let dateValue = value.as(Date.self) {
                                Text(dateLabelFormatter.string(from: dateValue))
                                    .font(.caption2)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                }

                .chartYAxisLabel("Humidity %")
                .frame(height: 300)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 4)
            }
        }

        var body: some View {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 16) {
                    if let message = saveConfirmationMessage {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.white)
                            Text(message)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Text("Humidity Chart")
                        .font(.largeTitle.bold())
                        .foregroundColor(.orange)
                        .padding(.top)

                    Picker("Time Range", selection: $selectedRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    ChartContainerView

                    Spacer()

                    HStack {
                        Button(action: {
                            let exportView = ChartContainerView
                                .padding()
                                .background(.white)
                                .cornerRadius(20)
                                .shadow(radius: 4)

                            let renderer = ImageRenderer(content: exportView)
                            renderer.scale = 3.0 // high resolution
                            if let image = renderer.uiImage {
                                let saver = PhotoSaveHelper { success in
                                    if success {
                                        saveConfirmationMessage = "Photo saved to Photos Library!"
                                    } else {
                                        saveConfirmationMessage = "Failed to save photo."
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        saveConfirmationMessage = nil
                                    }
                                }
                                saver.save(image)
                            }
                        }) {
                            Label("Save Chart", systemImage: "square.and.arrow.down")
                        }

                        Spacer()

                        Button(action: {
                            let renderer = ImageRenderer(content: ChartContainerView)
                            if let image = renderer.uiImage {
                                let printController = UIPrintInteractionController.shared
                                let printInfo = UIPrintInfo(dictionary: nil)
                                printInfo.outputType = .photo
                                printInfo.jobName = "Humidity Chart"
                                printController.printInfo = printInfo
                                printController.printingItem = image
                                printController.present(animated: true, completionHandler: nil)
                            }
                        }) {
                            Label("Print Chart", systemImage: "printer")
                        }
                    }
                    .padding(.horizontal)
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(
                    LinearGradient(colors: [.zenBeige.opacity(0.7), .zenGreen.opacity(0.6), .orange.opacity(0.4)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                )

                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                .padding()
            }
        }
    }



/*
#Preview {
    HumidityChartView()
}
*/
