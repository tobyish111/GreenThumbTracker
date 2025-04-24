//
//  RecordType.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/23/25.
//

import Foundation
import DGCharts
enum RecordType: String, CaseIterable {
    case growth, water, humidity, light, soilMoisture, temperature

    var label: String {
        switch self {
        case .growth: return "Growth"
        case .water: return "Water"
        case .humidity: return "Humidity"
        case .light: return "Light"
        case .soilMoisture: return "Soil Moisture"
        case .temperature: return "Temperature"
        }
    }

    var color: NSUIColor {
        switch self {
        case .growth: return .systemGreen
        case .water: return .systemBlue
        case .humidity: return .systemOrange
        case .light: return .systemYellow
        case .soilMoisture: return .brown
        case .temperature: return .systemRed
        }
    }
    func filteredData(from context: MultiRecordTrendView, in range: MultiRecordTrendView.TimeRange) -> [ChartDataEntry] {
            let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let now = Date()
            let calendar = Calendar.current

            func isWithinRange(_ date: Date) -> Bool {
                switch range {
                case .week:
                    return date > calendar.date(byAdding: .day, value: -7, to: now)!
                case .month:
                    return date > calendar.date(byAdding: .month, value: -1, to: now)!
                case .year:
                    return date > calendar.date(byAdding: .year, value: -1, to: now)!
                }
            }

            func entry(from iso: String, y: Double) -> ChartDataEntry? {
                if let date = isoFormatter.date(from: iso), isWithinRange(date) {
                    return ChartDataEntry(x: date.timeIntervalSince1970, y: y)
                }
                return nil
            }

            switch self {
            case .growth:
                return context.growthRecords.compactMap { entry(from: $0.date, y: $0.height) }
            case .water:
                return context.waterRecords.compactMap { entry(from: $0.date, y: Double($0.amount)) }
            case .humidity:
                return context.humidityRecords.compactMap { entry(from: $0.date, y: $0.humidity) }
            case .light:
                return context.lightRecords.compactMap { entry(from: $0.date, y: $0.light) }
            case .soilMoisture:
                return context.soilMoistureRecords.compactMap { entry(from: $0.date, y: $0.soil_moisture) }
            case .temperature:
                return context.temperatureRecords.compactMap { entry(from: $0.date, y: $0.temperature) }
            }
        }
    
    func data(from context: MultiRecordTrendView) -> [ChartDataEntry] {
           let isoFormatter = ISO8601DateFormatter()
           isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let entries: [ChartDataEntry]
           switch self {
           case .growth:
               return context.growthRecords.compactMap {
                   guard let date = isoFormatter.date(from: $0.date) else { return nil }
                   return ChartDataEntry(x: date.timeIntervalSince1970, y: $0.height)
               }

           case .water:
               return context.waterRecords.compactMap {
                   guard let date = isoFormatter.date(from: $0.date) else { return nil }
                   return ChartDataEntry(x: date.timeIntervalSince1970, y: Double($0.amount))
               }

           case .humidity:
               return context.humidityRecords.compactMap {
                   guard let date = isoFormatter.date(from: $0.date) else { return nil }
                   return ChartDataEntry(x: date.timeIntervalSince1970, y: $0.humidity)
               }

           case .light:
               return context.lightRecords.compactMap {
                   guard let date = isoFormatter.date(from: $0.date) else { return nil }
                   return ChartDataEntry(x: date.timeIntervalSince1970, y: $0.light)
               }

           case .soilMoisture:
               return context.soilMoistureRecords.compactMap {
                   guard let date = isoFormatter.date(from: $0.date) else { return nil }
                   return ChartDataEntry(x: date.timeIntervalSince1970, y: $0.soil_moisture)
               }

           case .temperature:
               return context.temperatureRecords.compactMap {
                   guard let date = isoFormatter.date(from: $0.date) else { return nil }
                   return ChartDataEntry(x: date.timeIntervalSince1970, y: $0.temperature)
               }
           }
        print("📈 \(self.label) data() has \(entries.count) entries")

        return entries
       }
}
