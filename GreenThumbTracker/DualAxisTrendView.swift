//
//  DualAxisTrendView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/23/25.
//
import SwiftUI
import Foundation
import DGCharts

struct DualAxisTrendView: UIViewRepresentable {
    var leftEntries: [ChartDataEntry]
    var rightEntries: [ChartDataEntry]
    var leftLabel: String
    var rightLabel: String
    var leftColor: UIColor
    var rightColor: UIColor
    
    static var chartViewRef: LineChartView? = nil //store shared ref
    
    func makeUIView(context: Context) -> LineChartView {
        let chartView = LineChartView()
        chartView.rightAxis.enabled = true
        chartView.leftAxis.enabled = true
        chartView.xAxis.labelPosition = .bottom
        chartView.legend.enabled = true
        chartView.chartDescription.enabled = false
        chartView.backgroundColor = .clear
        chartView.xAxis.labelRotationAngle = -45
        chartView.xAxis.valueFormatter = DateValueFormatter()
        chartView.xAxis.drawGridLinesEnabled = false
        
        // Left axis title
        chartView.leftAxis.labelTextColor = leftColor
        chartView.leftAxis.axisLineColor = leftColor
        chartView.leftAxis.labelFont = .systemFont(ofSize: 12)
        
        // Right axis title
        chartView.rightAxis.labelTextColor = rightColor
        chartView.rightAxis.axisLineColor = rightColor
        chartView.rightAxis.labelFont = .systemFont(ofSize: 12)
        
        DualAxisTrendView.chartViewRef = chartView //set ref
        return chartView
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        let xAxis = uiView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = DateValueFormatter()
        xAxis.drawGridLinesEnabled = false
        xAxis.labelRotationAngle = -45
        
        // ✅ Color the Y-axis labels to match the dataset
        uiView.leftAxis.labelTextColor = leftColor
        uiView.rightAxis.labelTextColor = rightColor
        
        // (Optional) Axis lines and grid color matching too:
        uiView.leftAxis.axisLineColor = leftColor
        uiView.rightAxis.axisLineColor = rightColor
        
        // Configure left dataset
        let leftSet = LineChartDataSet(entries: leftEntries, label: leftLabel)
        leftSet.axisDependency = .left
        leftSet.setColor(leftColor)
        leftSet.setCircleColor(leftColor)
        leftSet.lineWidth = 2
        leftSet.circleRadius = 3
        leftSet.drawCircleHoleEnabled = false
        
        // Configure right dataset
        let rightSet = LineChartDataSet(entries: rightEntries, label: rightLabel)
        rightSet.axisDependency = .right
        rightSet.setColor(rightColor)
        rightSet.setCircleColor(rightColor)
        rightSet.lineWidth = 2
        rightSet.circleRadius = 3
        rightSet.drawCircleHoleEnabled = false
        
        let data = LineChartData(dataSets: [leftSet, rightSet])
        uiView.data = data
    }
}

  class DateValueFormatter: AxisValueFormatter {
      private let formatter: DateFormatter

      init() {
          self.formatter = DateFormatter()
          self.formatter.dateFormat = "MM/dd"
      }

      func stringForValue(_ value: Double, axis: AxisBase?) -> String {
          let date = Date(timeIntervalSince1970: value)
          return formatter.string(from: date)
      }
  }

extension LineChartView {
    func exportAsPDF(to url: URL) -> Bool {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: bounds)

        do {
            try pdfRenderer.writePDF(to: url, withActions: { context in
                context.beginPage()
                layer.render(in: context.cgContext)
            })
            return true
        } catch {
            print("❌ Failed to write chart PDF:", error.localizedDescription)
            return false
        }
    }
}

