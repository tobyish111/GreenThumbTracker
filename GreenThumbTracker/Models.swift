//
//  Models.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/20/25.
//

import Foundation

//users table
struct User: Codable {
    let id: Int
    let username: String
    let email: String
}

//login response
struct LoginResponse: Codable {
    let id: Int
    let username: String
    let email: String
    let token: String
}

//user role table
struct UserRole: Codable {
    let id: Int
    let roleName: String
}

//plants table owned by users
struct Plant: Codable, Identifiable {
    let id: Int
    let name: String
    let species: String
    let userID: Int? //foreign key to User table, optional for now
}

//water records table
struct WaterRecord: Codable, Identifiable{
    let id: Int
    let amount: Int
    let date: String
    let plant: NestedPlant
    let uom: NestedUOM

    var plantId: Int { plant.id }
    var uomID: Int { uom.id }

    struct NestedPlant: Codable {
        let id: Int
        let name: String
        let species: String
    }

    struct NestedUOM: Codable {
        let id: Int
        let name: String
        let symbol: String
    }
}

//growth record
struct GrowthRecord: Codable, Identifiable {
    let id: Int
    let plantId: Int
    let height: Double
    let date: String
    let uomID: Int
}

//unit of measure table
struct UnitOfMeasure: Codable{
    let id: Int
    let name: String
    let symbol: String
}

//email tracking table
struct EmailTracking: Codable {
    let id: Int
    let email: String
    let sentDate: String
}
