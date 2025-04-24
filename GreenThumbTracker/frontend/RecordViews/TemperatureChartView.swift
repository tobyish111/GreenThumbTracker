//
//  TemperatureChartView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/22/25.
//

import SwiftUI
import Charts

struct TemperatureChartView: View {
    let temperatureRecords: [TemperatureRecord]
        @State private var selectedRange: TimeRange = .week
        @Environment(\.dismiss) private var dismiss

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

        private var filteredRecords: [TemperatureRecord] {
            let now = Date()
            let calendar = Calendar.current
            return temperatureRecords.filter {
                guard let date = isoFormatter.date(from: $0.date) else { return false }
                switch selectedRange {
                case .week: return date > calendar.date(byAdding: .day, value: -7, to: now)!
                case .month: return date > calendar.date(byAdding: .month, value: -1, to: now)!
                case .year: return date > calendar.date(byAdding: .year, value: -1, to: now)!
                }
            }
        }

        var body: some View {
            TemperatureChartContainerView()
        }

        @ViewBuilder
        private func TemperatureChartContainerView() -> some View {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 20) {
                    Text("Temperature Over \(selectedRange.rawValue)")
                        .font(.headline)
                        .foregroundColor(.red)

                    Picker("Time Range", selection: $selectedRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    Chart {
                        ForEach(filteredRecords.sorted(by: { $0.date < $1.date })) { record in
                            if let date = isoFormatter.date(from: record.date) {
                                LineMark(
                                    x: .value("Date", date),
                                    y: .value("Temperature", record.temperature)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(.red)
                                .symbol(Circle())
                            }
                        }
                    }
                    .chartYAxisLabel("°C / °F")
                    .frame(height: 300)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 4)

                    HStack(spacing: 20) {
                        Button(action: {
                            let renderer = ImageRenderer(content: TemperatureChartContainerView().frame(width: 400, height: 400))
                            if let image = renderer.uiImage {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            }
                        }) {
                            Label("Save as Photo", systemImage: "square.and.arrow.down")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }

                        Button(action: {
                            let renderer = ImageRenderer(content: TemperatureChartContainerView().frame(width: 400, height: 400))
                            if let image = renderer.uiImage {
                                let printController = UIPrintInteractionController.shared
                                let printInfo = UIPrintInfo(dictionary: nil)
                                printInfo.outputType = .photo
                                printController.printInfo = printInfo
                                printController.printingItem = image
                                printController.present(animated: true, completionHandler: nil)
                            }
                        }) {
                            Label("Print", systemImage: "printer")
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.bottom)

                    Spacer()
                }
                .padding()
                .background(
                    LinearGradient(colors: [.zenBeige.opacity(0.7), .zenGreen.opacity(0.6)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
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
    TemperatureChartView()
}
*/
