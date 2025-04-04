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


    // Search by query
    func searchPlants(query: String, completion: @escaping (Result<[TreflePlant], Error>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = "\(baseURL)/plants/search?token=\(token)&q=\(encodedQuery)"
        request(urlString: urlString, completion: completion)
    }

    
}
