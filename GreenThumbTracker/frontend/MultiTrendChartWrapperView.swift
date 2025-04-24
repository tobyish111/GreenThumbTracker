//
//  MultiTrendChartWrapperView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/23/25.
//

import SwiftUI

struct MultiTrendChartWrapperView: View {
    let plant: Plant
       let growthRecords: [GrowthRecord]
       let waterRecords: [WaterRecord]
       let humidityRecords: [HumidityRecord]
       let lightRecords: [LightRecord]
       let soilMoistureRecords: [SoilMoistureRecord]
       let temperatureRecords: [TemperatureRecord]
       let unitMap: [Int: UnitOfMeasure]
       let loadAll: () -> Void

       var body: some View {
           NavigationView {
               MultiRecordTrendView(
                   plant: plant,
                   growthRecords: growthRecords,
                   waterRecords: waterRecords,
                   humidityRecords: humidityRecords,
                   lightRecords: lightRecords,
                   soilMoistureRecords: soilMoistureRecords,
                   temperatureRecords: temperatureRecords,
                   unitMap: unitMap
               )
           }
           .onAppear {
               loadAll()
           }
       }
   }

/*
#Preview {
    MultiTrendChartWrapperView()
}
*/
