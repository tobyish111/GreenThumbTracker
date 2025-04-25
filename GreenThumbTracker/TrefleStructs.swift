//
//  TrefleStructs.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/17/25.
//

import Foundation

// MARK: - Summary Model (for plant list)
struct TreflePlant: Identifiable, Codable {
    let id: Int
    let slug: String
    let common_name: String?
    let scientific_name: String
    let image_url: String?
    let genus: String?
    let family: String?
}

// MARK: - Detailed Model (for tapped plant)
struct TreflePlantDetails: Codable {
    let id: Int
    let slug: String
    let common_name: String?
    let scientific_name: String
    let image_url: String?
    let main_species: MainSpecies
    let observations: String?
}

struct MainSpecies: Codable {
    let specifications: Specifications?
    let distributions: Distributions?
    let family: FlexibleFamily? //use wrapper structs to account for json response structure w/fields
    let genus: FlexibleGenus?

}


struct NativeDistributionWrapper: Codable {
    let native: [String]?
}


struct Temperature: Codable {
    let deg_c: Double?
}

struct Specifications: Codable {
    let average_height: Height?
    let maximum_height: Height?
    let growth_form: String?
    let growth_habit: String?
    let growth_rate: String?
    let toxicity: String?
}

struct Height: Codable {
    let cm: Double?
}

struct Distributions: Codable {
    let native: [DistributionRegion]?
}

struct DistributionRegion: Codable, Identifiable {
    let id: Int
    let name: String
    let slug: String
    let tdwg_code: String
    let tdwg_level: Int
}

// MARK: - Genus and Family Details
struct GenusData: Codable {
    let id: Int
    let name: String
    let slug: String
}

struct FamilyData: Codable {
    let id: Int
    let name: String
    let common_name: String?
    let slug: String
}
//MARK: For searching
struct TrefleFamily: Identifiable, Codable {
    let id: Int
    let name: String
    let slug: String
    let common_name: String?
    var imageURL: String? = nil
}

struct FamilyResponse: Codable {
    let data: [TrefleFamily]
    let links: PaginationLinks?
    let meta: MetaData?
}
struct MetaData: Codable {
    let total: Int?
    let currentPage: Int?
    let totalPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case total
        case currentPage = "current_page"
        case totalPages = "total_pages"
    }
}

struct PaginationLinks: Codable {
    let next: String?
}
struct FamilyDetails: Codable {
    let id: Int
    let name: String
    let slug: String
    let common_name: String?
    let bibliography: String?
    let author: String?
    let year: Int?
    let links: [String: String?]?
    let division_order: DivisionOrder?
}

struct DivisionOrder: Codable {
    let id: Int
    let name: String
    let slug: String
    let division_class: DivisionClass?
}

struct DivisionClass: Codable {
    let id: Int
    let name: String
    let slug: String
    let division: Division?
}

struct Division: Codable {
    let id: Int
    let name: String
    let slug: String
    let subkingdom: Subkingdom?
}

struct Subkingdom: Codable {
    let id: Int
    let name: String
    let slug: String
    let kingdom: Kingdom?
}

struct Kingdom: Codable {
    let id: Int
    let name: String
    let slug: String
}

struct SingleFamilyResponse: Codable {
    let data: FamilyDetails
}
// MARK: - Trefle Plant Family Model
struct PlantFamily: Identifiable, Codable {
    let id: Int
    let name: String
    let slug: String
    let common_name: String?
    let image_url: String? // Optional: In case we can associate a visual, you can later fetch or map one
}
struct FamilyListResponse: Codable {
    let data: [PlantFamily]
}


//wrapper structs for inconsistent json responses
struct FlexibleFamily: Codable {
    let name: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let name = try? container.decode(String.self) {
            self.name = name
        } else if let family = try? container.decode(FamilyData.self) {
            self.name = family.name
        } else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected family to be a string or an object with a name"))
        }
    }
}
struct FlexibleGenus: Codable {
    let name: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let name = try? container.decode(String.self) {
            self.name = name
        } else if let genus = try? container.decode(GenusData.self) {
            self.name = genus.name
        } else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected genus to be a string or an object with a name"))
        }
    }
}


// MARK: - API JSON Wrappers
struct TrefleResponse: Codable {
    let data: [TreflePlant]
      let links: PaginationLinks?
      let meta: MetaData?
}

struct SingleTrefleResponse: Codable {
    let data: TreflePlantDetails
}

struct DistributionResponse: Codable {
    let data: [DistributionRegion]
}

//MARK: CACHING
class TrefleFamilyCache {
    static let shared = TrefleFamilyCache()
    private init() {}
    var allFamilies: [TrefleFamily] = []
    var isLoaded = false
}

class TreflePlantCache {
    static let shared = TreflePlantCache()
    private init(){}
    //house all plants in this var
    var allPlants: [TreflePlant] = []
    var isLoaded = false
}

class TrefleFamilyDetailsCache {
    static let shared = TrefleFamilyDetailsCache()
    private init() {}
    var familyDetailsMap: [String: FamilyDetails] = [:]
}
class TrefleRegionCache {
    static let shared = TrefleRegionCache()
    private init() {}

    var allRegions: [TrefleDistributionRegion] = []
    var isLoaded = false
}
class TrefleRegionDetailsCache {
    static let shared = TrefleRegionDetailsCache()
    private init() {}

    var regionDetailsMap: [String: TrefleDistributionRegionDetails] = [:] // slug → details
}
