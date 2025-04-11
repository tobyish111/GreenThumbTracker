//
//  TrefleAPI.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/3/25.
//

import Foundation

//trefle api handling model
struct TreflePlant: Identifiable, Codable {
    let id: Int
    let common_name: String?
    let scientific_name: String
    let image_url: String?
}

//more detailed structs for encyclopedia
struct SingleTrefleResponse: Codable {
    let data: TreflePlantDetails
}

struct TreflePlantDetails: Codable {
    let id: Int
    let common_name: String?
    let scientific_name: String
    let image_url: String?
    
    let family_common_name: String?
    let family: Family?
    let genus: Genus?
    
    let vegetable: Bool?
    let edible_part: String?
    let medicinal: Bool?
    let toxicity: String?

    let growth: Growth?
    let specifications: Specifications?
    let flower: Flower?
}

struct Family: Codable {
    let id: Int?
    let name: String?
    let slug: String?
}

struct Genus: Codable {
    let id: Int?
    let name: String?
    let slug: String?
}

struct Growth: Codable {
    let light: Int?
    let atmospheric_humidity: Double?
    let minimum_temperature: Temperature?
    let maximum_temperature: Temperature?
    let ph_minimum: Double?
    let ph_maximum: Double?
    let soil_humidity: String?
    let soil_texture: String?
    let soil_nutriments: String?
    let soil_salinity: String?
    let growth_rate: String?
    let growth_form: String?
    let lifespan: String?
}

struct Temperature: Codable {
    let deg_c: Double?
}

struct Specifications: Codable {
    let average_height: Height?
}

struct Height: Codable {
    let cm: Double?
}

struct Flower: Codable {
    let color: String?
    let conspicuous: Bool?
}
//distribution data models
struct DistributionRegion: Codable, Identifiable {
    let id: Int
    let name: String
    let tdwg_code: String?
    let native: Bool
    let introduced: Bool
}

struct DistributionResponse: Codable {
    let data: [DistributionRegion]
}

//struct for the json response
struct TrefleResponse: Codable {
    let data: [TreflePlant]
}
//class for trefle api handling
class TrefleAPI {
    static let shared = TrefleAPI()
    private let baseURL = "https://trefle.io/api/v1"
    private let token = "X2-PP5itzEF85qDb4Xp6O-68S9T49xFK632ZUDZ8N3Y" // Replace with your token

    // Generic request handler
    private func request(urlString: String, completion: @escaping (Result<[TreflePlant], Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }

            do {
                let result = try JSONDecoder().decode(TrefleResponse.self, from: data)
                completion(.success(result.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    // Fetch all plants
    func getAllPlants(page: Int, completion: @escaping (Result<[TreflePlant], Error>) -> Void) {
        let urlString = "\(baseURL)/plants?token=\(token)&page=\(page)&per_page=20"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0)))
                return
            }

            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 0)))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(TrefleResponse.self, from: data)
                    completion(.success(result.data))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
    }
    //get plant details (for encyclopedia)
    func getPlantDetails(id: Int, completion: @escaping (Result<TreflePlantDetails, Error>) -> Void) {
        let urlString = "\(baseURL)/plants/\(id)?token=\(token)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let result = try JSONDecoder().decode(SingleTrefleResponse.self, from: data)
                completion(.success(result.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    // Search by query
    func searchPlants(query: String, completion: @escaping (Result<[TreflePlant], Error>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = "\(baseURL)/plants/search?token=\(token)&q=\(encodedQuery)"
        request(urlString: urlString, completion: completion)
    }
    //getting the map location
    func getPlantDistributions(id: Int, completion: @escaping (Result<[DistributionRegion], Error>) -> Void) {
        let urlString = "\(baseURL)/plants/\(id)/distributions?token=\(token)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let jsonStr = String(data: data, encoding: .utf8)
                   print("Raw Distribution JSON: \(jsonStr ?? "None")")
                let result = try JSONDecoder().decode(DistributionResponse.self, from: data)
                completion(.success(result.data))
            } catch {
                print("Decoding failed: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }


    
}
