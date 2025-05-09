//
//  WaterChartView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/10/25.
//

import SwiftUI
import Charts

struct WaterChartView: View {
    let waterRecords: [WaterRecord]
      let unitMap: [Int: UnitOfMeasure]

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

      var filteredRecords: [WaterRecord] {
          let now = Date()
          let calendar = Calendar.current
          return waterRecords.filter {
              guard let date = isoFormatter.date(from: $0.date) else { return false }
              switch selectedRange {
              case .week: return date > calendar.date(byAdding: .day, value: -7, to: now)!
              case .month: return date > calendar.date(byAdding: .month, value: -1, to: now)!
              case .year: return date > calendar.date(byAdding: .year, value: -1, to: now)!
              }
          }
      }

      // This chart and its title will be snapshotted
      @ViewBuilder
    private var ChartContainerView: some View {
        VStack(spacing: 8) {
            Text("Watering Over \(selectedRange.rawValue)")
                .font(.headline)
                .foregroundColor(.blue)
            
            Chart {
                ForEach(filteredRecords.sorted(by: { $0.date < $1.date })) { record in
                    if let date = isoFormatter.date(from: record.date) {
                        LineMark(
                            x: .value("Date", date),
                            y: .value("Amount", record.amount)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.blue)
                        .symbol(Circle())
                    }
                }
            }
            .chartYAxisLabel("Amount")
            .frame(height: 300)
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(12)
            .shadow(radius: 4)
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

            .chartXAxis{
                AxisMarks(values: .stride(by: .day, count: selectedRange == .week ? 1 : (selectedRange == .month ? 7 : 30))) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                }
            }
        }
    }
      var body: some View {
          ZStack(alignment: .topTrailing) {
              VStack(spacing: 16) {
                  // Confirmation banner
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

                  Text("Water Chart")
                      .font(.largeTitle.bold())
                      .foregroundColor(.blue)
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
                          let renderer = ImageRenderer(content: ChartContainerView)
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
                              printInfo.jobName = "Water Chart"
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
                  LinearGradient(colors: [.zenBeige.opacity(0.7), .zenGreen.opacity(0.6), .blue.opacity(0.4)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                  .ignoresSafeArea()
              )

              // Close button
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
 WaterChartView()
 }
 */
