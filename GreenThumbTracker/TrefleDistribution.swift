//
//  TrefleDistribution.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/24/25.
//

import Foundation

// MARK: - Distribution Region List Response
struct TrefleDistributionListResponse: Codable {
    let data: [TrefleDistributionRegion]
    let links: TreflePaginationLinks?
    let meta: TrefleMetaData?
}

// MARK: - Single Distribution Region Detail Response
struct TrefleSingleDistributionResponse: Codable {
    let data: TrefleDistributionRegionDetails
    let meta: TrefleMetaData?
}

// MARK: - Distribution Region Model (from list)
struct TrefleDistributionRegion: Identifiable, Codable {
    let id: Int
    let name: String
    let slug: String
    let tdwg_code: String
    let tdwg_level: Int
    let species_count: Int
    let links: TrefleDistributionLinks
    let parent: TrefleParentRegion?
    let children: [TrefleChildRegion]
}

// MARK: - Detailed Distribution Region Model
struct TrefleDistributionRegionDetails: Codable {
    let id: Int
    let name: String
    let slug: String
    let tdwg_code: String
    let tdwg_level: Int
    let species_count: Int
    let links: TrefleDistributionLinks
    let parent: TrefleParentRegion?
    let children: [TrefleChildRegion]
}

// MARK: - Links and Relationships
struct TrefleDistributionLinks: Codable {
    let selfLink: String
    let plants: String
    let species: String

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case plants
        case species
    }
}

struct TrefleParentRegion: Codable {
    let id: Int
    let name: String
    let slug: String
    let tdwg_code: String
    let tdwg_level: Int
    let species_count: Int
    let links: TrefleDistributionLinks
}

struct TrefleChildRegion: Codable {
    let id: Int
    let name: String
    let slug: String
    let tdwg_code: String
    let tdwg_level: Int
    let species_count: Int
    let links: TrefleDistributionLinks
}

// MARK: - Meta and Pagination
struct TreflePaginationLinks: Codable {
    let selfLink: String
    let first: String?
    let next: String?
    let last: String?

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case first
        case next
        case last
    }
}

struct TrefleMetaData: Codable {
    let total: Int?
    let currentPage: Int?
    let totalPages: Int?
    let last_modified: String?

    enum CodingKeys: String, CodingKey {
        case total
        case currentPage = "current_page"
        case totalPages = "total_pages"
        case last_modified
    }
}

