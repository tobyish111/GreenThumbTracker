//
//  localModels.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/3/25.
//

import Foundation
import SwiftData

// MARK: - Plant
@Model
class LocalPlant {
    var id: UUID
    var backendId: Int? = nil
    var name: String
    var species: String
    var userId: Int
    var createdAt: Date
    var updatedAt: Date
    var isSynced: Bool = false

    @Relationship(deleteRule: .cascade)
    var waterRecords: [LocalWaterRecord] = []
    var growthRecords: [LocalGrowthRecord] = []
    var temperatureRecords: [LocalTemperatureRecord] = []
    var lightRecords: [LocalLightRecord] = []
    var soilMoistureRecords: [LocalSoilMoistureRecord] = []
    var humidityRecords: [LocalHumidityRecord] = []

    init(
        id: UUID = UUID(),
        name: String,
        species: String,
        userId: Int,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Water
@Model
class LocalWaterRecord {
    var id: UUID
    var backendId: Int? = nil
    var plantId: UUID
    var amount: Double
    var unit: String
    var date: Date
    var isSynced: Bool = false

    @Relationship var plant: LocalPlant?

    init(
        id: UUID = UUID(),
        plantId: UUID,
        amount: Double,
        unit: String,
        date: Date = .now
    ) {
        self.id = id
        self.plantId = plantId
        self.amount = amount
        self.unit = unit
        self.date = date
    }
}

// MARK: - Growth
@Model
class LocalGrowthRecord {
    var id: UUID
    var backendId: Int? = nil
    var plantId: UUID
    var height: Double
    var unit: String
    var date: Date
    var isSynced: Bool = false

    @Relationship var plant: LocalPlant?

    init(
        id: UUID = UUID(),
        plantId: UUID,
        height: Double,
        unit: String,
        date: Date = .now
    ) {
        self.id = id
        self.plantId = plantId
        self.height = height
        self.unit = unit
        self.date = date
    }
}

// MARK: - Temperature
@Model
class LocalTemperatureRecord {
    var id: UUID
    var backendId: Int? = nil
    var plantId: UUID
    var temperature: Double
    var unit: String
    var date: Date
    var isSynced: Bool = false

    @Relationship var plant: LocalPlant?

    init(
        id: UUID = UUID(),
        plantId: UUID,
        temperature: Double,
        unit: String,
        date: Date = .now
    ) {
        self.id = id
        self.plantId = plantId
        self.temperature = temperature
        self.unit = unit
        self.date = date
    }
}

// MARK: - Light
@Model
class LocalLightRecord {
    var id: UUID
    var backendId: Int? = nil
    var plantId: UUID
    var light: Double
    var unit: String
    var date: Date
    var isSynced: Bool = false

    @Relationship var plant: LocalPlant?

    init(
        id: UUID = UUID(),
        plantId: UUID,
        light: Double,
        unit: String,
        date: Date = .now
    ) {
        self.id = id
        self.plantId = plantId
        self.light = light
        self.unit = unit
        self.date = date
    }
}

// MARK: - Soil Moisture
@Model
class LocalSoilMoistureRecord {
    var id: UUID
    var backendId: Int? = nil
    var plantId: UUID
    var soilMoisture: Double
    var unit: String
    var date: Date
    var isSynced: Bool = false

    @Relationship var plant: LocalPlant?

    init(
        id: UUID = UUID(),
        plantId: UUID,
        soilMoisture: Double,
        unit: String,
        date: Date = .now
    ) {
        self.id = id
        self.plantId = plantId
        self.soilMoisture = soilMoisture
        self.unit = unit
        self.date = date
    }
}

// MARK: - Humidity
@Model
class LocalHumidityRecord {
    var id: UUID
    var backendId: Int? = nil
    var plantId: UUID
    var humidity: Double
    var unit: String
    var date: Date
    var isSynced: Bool = false

    @Relationship var plant: LocalPlant?

    init(
        id: UUID = UUID(),
        plantId: UUID,
        humidity: Double,
        unit: String,
        date: Date = .now
    ) {
        self.id = id
        self.plantId = plantId
        self.humidity = humidity
        self.unit = unit
        self.date = date
    }
}

enum AnyPlant: Identifiable, Equatable {
    case remote(Plant)
    case local(LocalPlant)
    init(remote: Plant){
        self = .remote(remote)
    }

    // Conform to Identifiable
    var id: AnyHashable {
        switch self {
        case .remote(let p): return p.id
        case .local(let p): return p.id
        }
    }

    var name: String {
        switch self {
        case .remote(let p): return p.name
        case .local(let p): return p.name
        }
    }

    var species: String {
        switch self {
        case .remote(let p): return p.species
        case .local(let p): return p.species
        }
    }

    var userId: Int? {
        switch self {
        case .remote(let p): return p.userID // from backend
        case .local(let p): return p.userId
        }
    }

    var backendId: Int? {
        switch self {
        case .remote(let p): return p.id
        case .local(let p): return p.backendId
        }
    }

    var isLocal: Bool {
        if case .local = self { return true }
        return false
    }

    static func ==(lhs: AnyPlant, rhs: AnyPlant) -> Bool {
        return lhs.id == rhs.id
    }
}




//model conformance
extension LocalWaterRecord: RecordSyncable {}
extension LocalGrowthRecord: RecordSyncable {}
extension LocalHumidityRecord: RecordSyncable {}
extension LocalLightRecord: RecordSyncable {}
extension LocalSoilMoistureRecord: RecordSyncable {}
extension LocalTemperatureRecord: RecordSyncable {}

