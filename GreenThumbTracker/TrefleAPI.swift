//
//  TrefleAPI.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/3/25.
//

import Foundation

struct StringOrInt: Codable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let intValue = try? container.decode(Int.self) {
            value = String(intValue)
        } else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected String or Int"))
        }
    }
}


// private let token = "X2-PP5itzEF85qDb4Xp6O-68S9T49xFK632ZUDZ8N3Y" // Replace with your own token
// MARK: - API Handler
class TrefleAPI {
    static let shared = TrefleAPI()
    private let baseURL = "https://trefle.io/api/v1"
    private let token = "X2-PP5itzEF85qDb4Xp6O-68S9T49xFK632ZUDZ8N3Y"

    private func request<T: Decodable>(urlString: String, decodeAs: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
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
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("Decoding failed: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    func getAllPlants(page: Int, completion: @escaping (Result<[TreflePlant], Error>) -> Void) {
        let urlString = "\(baseURL)/plants?token=\(token)&page=\(page)&per_page=20"
        request(urlString: urlString, decodeAs: TrefleResponse.self) { result in
            completion(result.map { $0.data })
        }
    }

    func getPlantDetails(id: Int, completion: @escaping (Result<TreflePlantDetails, Error>) -> Void) {
        let urlString = "\(baseURL)/plants/\(id)?token=\(token)"
        request(urlString: urlString, decodeAs: SingleTrefleResponse.self) { result in
            completion(result.map { $0.data })
        }
    }


    func getPlantDistributions(slug: String, completion: @escaping (Result<[DistributionRegion], Error>) -> Void) {
        let urlString = "\(baseURL)/plants/\(slug)/distributions?token=\(token)"
        request(urlString: urlString, decodeAs: DistributionResponse.self) { result in
            completion(result.map { $0.data })
        }
    }

    func searchPlants(query: String, completion: @escaping (Result<[TreflePlant], Error>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = "\(baseURL)/plants/search?token=\(token)&q=\(encodedQuery)"
        request(urlString: urlString, decodeAs: TrefleResponse.self) { result in
            completion(result.map { $0.data })
        }
    }
}
