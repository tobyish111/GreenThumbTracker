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

    func makeUIView(context: Context) -> LineChartView {
        let chartView = LineChartView()

        // Configure dual axes
        chartView.rightAxis.enabled = true
        chartView.leftAxis.enabled = true
        chartView.xAxis.labelPosition = .bottom
        chartView.legend.enabled = true
        chartView.chartDescription.enabled = false

        return chartView
    }

    func updateUIView(_ uiView: LineChartView, context: Context) {
        let xAxis = uiView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = DateValueFormatter()
        xAxis.drawGridLinesEnabled = false
        xAxis.labelRotationAngle = -45
        // Left axis line
        let leftSet = LineChartDataSet(entries: leftEntries, label: leftLabel)
        leftSet.axisDependency = .left
        leftSet.setColor(leftColor)
        leftSet.setCircleColor(leftColor)
        leftSet.lineWidth = 2
        leftSet.circleRadius = 3
        leftSet.drawCircleHoleEnabled = false

        // Right axis line
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
         self.formatter.dateFormat = "MM/dd"  // or "HH:mm" or anything else you want
     }

     func stringForValue(_ value: Double, axis: AxisBase?) -> String {
         let date = Date(timeIntervalSince1970: value)
         return formatter.string(from: date)
     }
}
